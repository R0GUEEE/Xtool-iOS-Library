// Reference implementation for embedding LLVM LLD's Mach-O driver.
//
// This file is intentionally outside the SwiftPM target. A host application
// links it with the revision-matched unified compiler archive.

#include "CXtoolCompilerBridge.h"

#include "lld/Common/Driver.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/Support/raw_ostream.h"

#include <cstdint>
#include <vector>

LLD_HAS_DRIVER(macho)

static int32_t xtool_host_lld_macho(
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

extern "C" void xtool_register_host_lld_macho(void) {
    xtool_register_lld_macho(
        xtool_host_lld_macho
    );
}

__attribute__((constructor))
static void xtool_auto_register_host_lld_macho(void) {
    xtool_register_host_lld_macho();
}
