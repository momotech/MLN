/*
** $Id: lualib.h,v 1.43.1.1 2013/04/12 18:48:47 roberto Exp $
** Lua standard libraries
** See Copyright Notice in lua.h
*/


#ifndef lualib_h
#define lualib_h

#include "mln_lua.h"


#define luaopen_base mln_luaopen_base
LUAMOD_API int (luaopen_base) (lua_State *L);

#define LUA_COLIBNAME	"coroutine"
#define luaopen_coroutine mln_luaopen_coroutine
LUAMOD_API int (luaopen_coroutine) (lua_State *L);

#define LUA_TABLIBNAME	"table"
#define luaopen_table mln_luaopen_table
LUAMOD_API int (luaopen_table) (lua_State *L);

#define LUA_IOLIBNAME	"io"
#define luaopen_io mln_luaopen_io
LUAMOD_API int (luaopen_io) (lua_State *L);

#define LUA_OSLIBNAME	"os"
#define luaopen_os mln_luaopen_os
LUAMOD_API int (luaopen_os) (lua_State *L);

#define LUA_STRLIBNAME	"string"
#define luaopen_string mln_luaopen_string
LUAMOD_API int (luaopen_string) (lua_State *L);

#define LUA_BITLIBNAME	"bit32"
#define luaopen_bit32 mln_luaopen_bit32
LUAMOD_API int (luaopen_bit32) (lua_State *L);

#define LUA_MATHLIBNAME	"math"
#define luaopen_math mln_luaopen_math
LUAMOD_API int (luaopen_math) (lua_State *L);

#define LUA_DBLIBNAME	"debug"
#define luaopen_debug mln_luaopen_debug
LUAMOD_API int (luaopen_debug) (lua_State *L);

#define LUA_LOADLIBNAME	"package"
#define luaopen_package mln_luaopen_package
LUAMOD_API int (luaopen_package) (lua_State *L);


/* open all previous libraries */
#define luaL_openlibs mln_luaL_openlibs
LUALIB_API void (luaL_openlibs) (lua_State *L);



#if !defined(lua_assert)
#define lua_assert(x)	((void)0)
#endif


#endif
