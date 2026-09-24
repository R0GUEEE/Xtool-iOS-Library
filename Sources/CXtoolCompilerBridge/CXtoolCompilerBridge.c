#include "CXtoolCompilerBridge.h"

static xtool_compiler_entrypoint_t g_swift_frontend = 0;
static xtool_compiler_entrypoint_t g_clang = 0;
static xtool_compiler_entrypoint_t g_lld_macho = 0;

void xtool_register_swift_frontend(
    xtool_compiler_entrypoint_t entrypoint
) {
    g_swift_frontend = entrypoint;
}

void xtool_register_clang(
    xtool_compiler_entrypoint_t entrypoint
) {
    g_clang = entrypoint;
}

void xtool_register_lld_macho(
    xtool_compiler_entrypoint_t entrypoint
) {
    g_lld_macho = entrypoint;
}

int32_t xtool_has_swift_frontend(void) {
    return g_swift_frontend != 0;
}

int32_t xtool_has_clang(void) {
    return g_clang != 0;
}

int32_t xtool_has_lld_macho(void) {
    return g_lld_macho != 0;
}

int32_t xtool_run_swift_frontend(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    if (!g_swift_frontend) {
        return -127;
    }

    return g_swift_frontend(
        argc,
        argv,
        working_directory
    );
}

int32_t xtool_run_clang(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    if (!g_clang) {
        return -127;
    }

    return g_clang(
        argc,
        argv,
        working_directory
    );
}

int32_t xtool_run_lld_macho(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
) {
    if (!g_lld_macho) {
        return -127;
    }

    return g_lld_macho(
        argc,
        argv,
        working_directory
    );
}
