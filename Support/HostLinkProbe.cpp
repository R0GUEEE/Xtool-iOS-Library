#include "CXtoolCompilerBridge.h"

#include <cstdint>

extern "C" void xtool_register_host_swift_frontend(void);
extern "C" void xtool_register_host_clang(void);
extern "C" void xtool_register_host_lld_macho(void);

int main() {
    xtool_register_host_swift_frontend();
    xtool_register_host_clang();
    xtool_register_host_lld_macho();

    const bool ready =
        xtool_has_swift_frontend() != 0 &&
        xtool_has_clang() != 0 &&
        xtool_has_lld_macho() != 0;

    return ready ? 0 : 1;
}
