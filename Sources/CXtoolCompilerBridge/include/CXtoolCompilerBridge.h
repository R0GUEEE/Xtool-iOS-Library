#ifndef CXTOOL_COMPILER_BRIDGE_H
#define CXTOOL_COMPILER_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef int32_t (*xtool_compiler_entrypoint_t)(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
);

void xtool_register_swift_frontend(xtool_compiler_entrypoint_t entrypoint);
void xtool_register_clang(xtool_compiler_entrypoint_t entrypoint);
void xtool_register_lld_macho(xtool_compiler_entrypoint_t entrypoint);

int32_t xtool_has_swift_frontend(void);
int32_t xtool_has_clang(void);
int32_t xtool_has_lld_macho(void);

int32_t xtool_run_swift_frontend(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
);

int32_t xtool_run_clang(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
);

int32_t xtool_run_lld_macho(
    int32_t argc,
    const char * const *argv,
    const char *working_directory
);

#ifdef __cplusplus
}
#endif

#endif
