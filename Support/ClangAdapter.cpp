// Reference implementation for embedding Clang in a host application.
//
// The Clang driver is used only to translate normal driver arguments into an
// in-process cc1 CompilerInvocation. No subprocess is created.

#include "CXtoolCompilerBridge.h"

#include "clang/Basic/Diagnostic.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "clang/FrontendTool/Utils.h"
#include "clang/Serialization/PCHContainerOperations.h"
#include "llvm/ADT/IntrusiveRefCntPtr.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/VirtualFileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/TargetParser/Host.h"

#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

static int32_t xtool_run_clang_driver_in_process(
    int32_t argc,
    const char * const *argv
) {
    static std::once_flag initialize_once;
    std::call_once(
        initialize_once,
        [] {
            llvm::InitializeAllTargets();
            llvm::InitializeAllTargetMCs();
            llvm::InitializeAllAsmPrinters();
            llvm::InitializeAllAsmParsers();
        }
    );

    std::vector<const char *> arguments;
    arguments.reserve(static_cast<size_t>(argc) + 1);
    arguments.push_back("clang");

    for (int32_t index = 0; index < argc; ++index) {
        arguments.push_back(argv[index]);
    }

    // DiagnosticOptions is refcounted in the revision this is built against
    // (swiftlang/llvm-project swift/release/6.2), the printer takes the raw
    // pointer inside that reference, and the engine takes both:
    //
    //   DiagnosticsEngine(IntrusiveRefCntPtr<DiagnosticIDs>,
    //                     IntrusiveRefCntPtr<DiagnosticOptions>,
    //                     DiagnosticConsumer *client = nullptr,
    //                     bool ShouldOwnClient = true)
    //   TextDiagnosticPrinter(raw_ostream &os, DiagnosticOptions *diags, ...)
    auto diagnosticOptions =
        llvm::makeIntrusiveRefCnt<clang::DiagnosticOptions>();
    auto fileSystem = llvm::vfs::getRealFileSystem();
    std::string diagnosticText;
    llvm::raw_string_ostream diagnosticStream(diagnosticText);
    auto diagnosticPrinter =
        std::make_unique<clang::TextDiagnosticPrinter>(
            diagnosticStream,
            diagnosticOptions.get()
        );
    auto diagnosticIDs =
        llvm::IntrusiveRefCntPtr<clang::DiagnosticIDs>(
            new clang::DiagnosticIDs()
        );
    clang::DiagnosticsEngine diagnostics(
        diagnosticIDs,
        diagnosticOptions,
        diagnosticPrinter.get(),
        false
    );

    clang::driver::Driver driver(
        arguments[0],
        llvm::sys::getDefaultTargetTriple(),
        diagnostics
    );
    driver.setCheckInputsExist(true);

    std::unique_ptr<clang::driver::Compilation> compilation(
        driver.BuildCompilation(arguments)
    );
    if (!compilation) {
        return 1;
    }

    const clang::driver::JobList &jobs = compilation->getJobs();
    auto command = llvm::find_if(
        jobs,
        [](const clang::driver::Command &candidate) {
            return llvm::StringRef(
                candidate.getCreator().getName()
            ) == "clang";
        }
    );

    if (command == jobs.end()) {
        return 1;
    }

    const llvm::opt::ArgStringList &cc1Arguments =
        command->getArguments();

    auto invocation =
        std::make_shared<clang::CompilerInvocation>();

    if (!clang::CompilerInvocation::CreateFromArgs(
            *invocation,
            cc1Arguments,
            diagnostics,
            arguments[0]
        )) {
        return 1;
    }

    auto pchOperations =
        std::make_shared<clang::PCHContainerOperations>();

    // The instance takes the PCH container factory in its constructor and the
    // invocation through setInvocation(); there is no constructor that takes a
    // CompilerInvocation, refcounted or otherwise.
    auto compiler = std::make_unique<clang::CompilerInstance>(
        std::move(pchOperations)
    );
    compiler->setInvocation(std::move(invocation));
    compiler->setVirtualFileSystem(fileSystem);
    compiler->createDiagnostics();

    const bool success =
        clang::ExecuteCompilerInvocation(compiler.get());

    compiler->clearOutputFiles(false);
    return success ? 0 : 1;
}

static int32_t xtool_host_clang(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    (void)working_directory;
    return xtool_run_clang_driver_in_process(argc, argv);
}

extern "C" void xtool_register_host_clang(void) {
    xtool_register_clang(
        xtool_host_clang
    );
}

__attribute__((constructor))
static void xtool_auto_register_host_clang(void) {
    xtool_register_host_clang();
}
