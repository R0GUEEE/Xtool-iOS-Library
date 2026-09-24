#include "NativeToolchainSupport.h"
#include "CXtoolCompilerBridge.h"

#ifndef XTOOL_ENABLE_EMBEDDED_LLD
#define XTOOL_ENABLE_EMBEDDED_LLD 0
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
#if XTOOL_ENABLE_EMBEDDED_LLD
    xtool_register_lld_macho(
        xtool_lld_macho_entrypoint
    );
#endif
}

int32_t xtool_native_toolchain_has_lld_macho(void) {
#if XTOOL_ENABLE_EMBEDDED_LLD
    return 1;
#else
    return 0;
#endif
}
