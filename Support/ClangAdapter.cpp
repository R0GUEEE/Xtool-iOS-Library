// Reference implementation for embedding Clang in a host application.
//
// This file is intentionally outside the SwiftPM target. Compile it in a host
// target that already links the required Clang/LLVM driver libraries.

#include "CXtoolCompilerBridge.h"

#include "llvm/Support/LLVMDriver.h"

#include <cstdint>
#include <vector>

extern int clang_main(
    int argc,
    char **argv,
    const llvm::ToolContext &tool_context
);

static int32_t xtool_host_clang(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    // XtoolMobileKit passes absolute input/output paths, so avoid global chdir.
    (void)working_directory;

    std::vector<char *> arguments;
    arguments.reserve(static_cast<size_t>(argc) + 1);
    arguments.push_back(const_cast<char *>("clang"));

    for (int32_t index = 0; index < argc; ++index) {
        arguments.push_back(
            const_cast<char *>(argv[index])
        );
    }

    const llvm::ToolContext context {
        arguments[0],
        nullptr,
        false
    };

    return static_cast<int32_t>(
        clang_main(
            static_cast<int>(arguments.size()),
            arguments.data(),
            context
        )
    );
}

extern "C" void xtool_register_host_clang(void) {
    xtool_register_clang(
        xtool_host_clang
    );
}
