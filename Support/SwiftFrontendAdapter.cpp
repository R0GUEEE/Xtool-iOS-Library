// Reference implementation for embedding the Swift compiler frontend.
//
// This file is intentionally outside the SwiftPM target. Compile it inside a
// host target that links the Swift compiler frontend and its LLVM dependencies.

#include "CXtoolCompilerBridge.h"

#include "swift/Basic/InitializeSwiftModules.h"
#include "swift/FrontendTool/FrontendTool.h"
#include "llvm/ADT/ArrayRef.h"

#include <cstdint>
#include <cstring>
#include <mutex>
#include <vector>

static int32_t xtool_host_swift_frontend(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    // XtoolMobileKit emits absolute source, SDK, resource and output paths.
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
                    &xtool_host_swift_frontend
                )
            )
        )
    );
}

extern "C" void xtool_register_host_swift_frontend(void) {
    xtool_register_swift_frontend(
        xtool_host_swift_frontend
    );
}
