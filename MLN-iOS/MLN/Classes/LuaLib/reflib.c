//
// Created by XiongFangyu on 2020/10/29.
//

#include "reflib.h"
#include "lauxlib.h"
#include "cache.h"

/**
 * 调用方法local sobj = strong(obj)
 * 将obj放入全局表，并返回obj本身
 * obj取值: table|function|userdata
 */
static int ref_strong(lua_State *L);
/*
 * 调用方法weak(obj)
 * 将obj从全局表中移除，并执行gc
 * obj取值: table|function|userdata
 */
static int ref_weak(lua_State *L);

static const luaL_Reg libs[] = {
        {REF_LIB_STRONG, ref_strong},
        {REF_LIB_WEAK, ref_weak},
        {NULL, NULL}
};

int ref_open(lua_State *L) {
    lua_pushglobaltable(L);
    luaL_setfuncs(L, libs, 0);
    lua_pop(L, 1);
}

static int _check_type(lua_State *L, const char *method) {
    int t = lua_type(L, 1);
    switch (t) {
        case LUA_TTABLE:
        case LUA_TFUNCTION:
        case LUA_TUSERDATA:
            return 0;
        default:
            return luaL_error(L,
                    "%s method only support table|function|userdata, current param type is %s",
                              method, lua_typename(L, t));
    }
}
static int ref_strong(lua_State *L) {
    if (_check_type(L, REF_LIB_STRONG) != 0)
        return 1;
    copyValueToGNV(L, 1);
    return 1;
}
static int ref_weak(lua_State *L) {
    if (_check_type(L, REF_LIB_WEAK) != 0)
        return 1;
    removeValueFromGNVByIndex(L, 1);
    return 0;
}
