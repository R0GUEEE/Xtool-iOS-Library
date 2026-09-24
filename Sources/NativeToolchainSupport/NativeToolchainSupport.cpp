#include "NativeToolchainSupport.h"
#include "CXtoolCompilerBridge.h"

#ifndef XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND
#define XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND 0
#endif

#ifndef XTOOL_ENABLE_EMBEDDED_CLANG
#define XTOOL_ENABLE_EMBEDDED_CLANG 0
#endif

#ifndef XTOOL_ENABLE_EMBEDDED_LLD
#define XTOOL_ENABLE_EMBEDDED_LLD 0
#endif

#if XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND

#include "swift/Basic/InitializeSwiftModules.h"
#include "swift/FrontendTool/FrontendTool.h"
#include "llvm/ADT/ArrayRef.h"

#include <cstring>
#include <mutex>
#include <vector>

static int32_t xtool_swift_frontend_entrypoint(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    (void)working_directory;

    static std::once_flag initialize_once;
    std::call_once(
        initialize_once,
        [] {
            swift::initializeSwiftModules();
        }
    );

    int32_t start = 0;
    if (argc > 0 && std::strcmp(argv[0], "-frontend") == 0) {
        start = 1;
    }

    std::vector<const char *> arguments;
    arguments.reserve(
        static_cast<size_t>(argc - start)
    );

    for (int32_t index = start; index < argc; ++index) {
        arguments.push_back(argv[index]);
    }

    return static_cast<int32_t>(
        swift::performFrontend(
            llvm::ArrayRef<const char *>(
                arguments.data(),
                arguments.size()
            ),
            "swift-frontend",
            reinterpret_cast<void *>(
                reinterpret_cast<uintptr_t>(
                    &xtool_swift_frontend_entrypoint
                )
            )
        )
    );
}

#endif

#if XTOOL_ENABLE_EMBEDDED_CLANG

#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/FrontendTool/Utils.h"
#include "clang/Serialization/PCHContainerOperations.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/VirtualFileSystem.h"
#include "llvm/TargetParser/Host.h"

#include <memory>
#include <mutex>
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

    clang::DiagnosticOptions diagnosticOptions;
    auto fileSystem = llvm::vfs::getRealFileSystem();
    auto diagnostics = clang::CompilerInstance::createDiagnostics(
        *fileSystem,
        diagnosticOptions
    );

    clang::driver::Driver driver(
        arguments[0],
        llvm::sys::getDefaultTargetTriple(),
        *diagnostics
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
            *diagnostics,
            arguments[0]
        )) {
        return 1;
    }

    auto pchOperations =
        std::make_shared<clang::PCHContainerOperations>();

    auto compiler = std::make_unique<clang::CompilerInstance>(
        std::move(invocation),
        std::move(pchOperations)
    );
    compiler->setVirtualFileSystem(fileSystem);
    compiler->createDiagnostics();

    const bool success =
        clang::ExecuteCompilerInvocation(compiler.get());

    compiler->clearOutputFiles(false);
    return success ? 0 : 1;
}


static int32_t xtool_clang_entrypoint(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    (void)working_directory;
    return xtool_run_clang_driver_in_process(argc, argv);
}

#endif

#if XTOOL_ENABLE_EMBEDDED_LLD

#include "lld/Common/Driver.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/Support/raw_ostream.h"

#include <vector>

LLD_HAS_DRIVER(macho)

static int32_t xtool_lld_macho_entrypoint(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    (void)working_directory;

    std::vector<const char *> arguments;
    arguments.reserve(static_cast<size_t>(argc) + 1);
    arguments.push_back("ld64.lld");

    for (int32_t index = 0; index < argc; ++index) {
        arguments.push_back(argv[index]);
    }

    const lld::DriverDef drivers[] = {
        { lld::Darwin, &lld::macho::link }
    };

    const lld::Result result = lld::lldMain(
        llvm::ArrayRef<const char *>(
            arguments.data(),
            arguments.size()
        ),
        llvm::outs(),
        llvm::errs(),
        llvm::ArrayRef<lld::DriverDef>(
            drivers,
            1
        )
    );

    return static_cast<int32_t>(result.retCode);
}

#endif

void xtool_native_toolchain_register_available_backends(void) {
#if XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND
    xtool_register_swift_frontend(
        xtool_swift_frontend_entrypoint
    );
#endif

#if XTOOL_ENABLE_EMBEDDED_CLANG
    xtool_register_clang(
        xtool_clang_entrypoint
    );
#endif

#if XTOOL_ENABLE_EMBEDDED_LLD
    xtool_register_lld_macho(
        xtool_lld_macho_entrypoint
    );
#endif
}

int32_t xtool_native_toolchain_has_swift_frontend(void) {
#if XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND
    return 1;
#else
    return 0;
#endif
}

int32_t xtool_native_toolchain_has_clang(void) {
#if XTOOL_ENABLE_EMBEDDED_CLANG
    return 1;
#else
    return 0;
#endif
}

int32_t xtool_native_toolchain_has_lld_macho(void) {
#if XTOOL_ENABLE_EMBEDDED_LLD
    return 1;
#else
    return 0;
#endif
}
