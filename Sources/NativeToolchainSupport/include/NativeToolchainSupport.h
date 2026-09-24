#ifndef XTOOL_NATIVE_TOOLCHAIN_SUPPORT_H
#define XTOOL_NATIVE_TOOLCHAIN_SUPPORT_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void xtool_native_toolchain_register_available_backends(void);

int32_t xtool_native_toolchain_has_lld_macho(void);

#ifdef __cplusplus
}
#endif

#endif
