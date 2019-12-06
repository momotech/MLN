//
// Created by MoMo on 2019-08-14.
//

#ifndef MMLUA4ANDROID_MM_UTILS_H
#define MMLUA4ANDROID_MM_UTILS_H

#ifdef __APPLE__
#include "mln_lua.h"
#else
#include "lua.h"
#endif

LUALIB_API int luaopen_mmos (lua_State *L);


#endif //MMLUA4ANDROID_MM_UTILS_H
