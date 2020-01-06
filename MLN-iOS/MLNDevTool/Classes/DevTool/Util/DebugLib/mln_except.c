/*=========================================================================*\
* Simple exception support
* LuaSocket toolkit
\*=========================================================================*/
#include <stdio.h>

#include "mln_lua.h"
#include "mln_lauxlib.h"

#include "mln_except.h"

/*=========================================================================*\
* Internal function prototypes.
\*=========================================================================*/
static int mln_global_protect(lua_State *L);
static int mln_global_newtry(lua_State *L);
static int mln_protected_(lua_State *L);
static int mln_finalize(lua_State *L);
static int mln_do_nothing(lua_State *L);

/* except functions */
static luaL_Reg mln_func[] = {
    {"newtry",    mln_global_newtry},
    {"protect",   mln_global_protect},
    {NULL,        NULL}
};

/*-------------------------------------------------------------------------*\
* Try factory
\*-------------------------------------------------------------------------*/
static void mln_wrap(lua_State *L) {
    lua_newtable(L);
    lua_pushnumber(L, 1);
    lua_pushvalue(L, -3);
    lua_settable(L, -3);
    lua_insert(L, -2);
    lua_pop(L, 1);
}

static int mln_finalize(lua_State *L) {
    if (!lua_toboolean(L, 1)) {
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_pcall(L, 0, 0, 0);
        lua_settop(L, 2);
        mln_wrap(L);
        lua_error(L);
        return 0;
    } else return lua_gettop(L);
}

static int mln_do_nothing(lua_State *L) { 
    (void) L;
    return 0; 
}

static int mln_global_newtry(lua_State *L) {
    lua_settop(L, 1);
    if (lua_isnil(L, 1)) lua_pushcfunction(L, mln_do_nothing);
    lua_pushcclosure(L, mln_finalize, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Protect factory
\*-------------------------------------------------------------------------*/
static int unwrap(lua_State *L) {
    if (lua_istable(L, -1)) {
        lua_pushnumber(L, 1);
        lua_gettable(L, -2);
        lua_pushnil(L);
        lua_insert(L, -2);
        return 1;
    } else return 0;
}

static int mln_protected_(lua_State *L) {
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    if (lua_pcall(L, lua_gettop(L) - 1, LUA_MULTRET, 0) != 0) {
        if (unwrap(L)) return 2;
        else lua_error(L);
        return 0;
    } else return lua_gettop(L);
}

static int mln_global_protect(lua_State *L) {
    lua_pushcclosure(L, mln_protected_, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Init module
\*-------------------------------------------------------------------------*/
int mln_except_open(lua_State *L) {
#if LUA_VERSION_NUM > 501 && !defined(LUA_COMPAT_MODULE)
    luaL_setfuncs(L, func, 0);
#else
    luaL_openlib(L, NULL, mln_func, 0);
#endif
    return 0;
}
