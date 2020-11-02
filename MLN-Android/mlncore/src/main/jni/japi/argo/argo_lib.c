/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/6/4.
//

#include "argo_lib.h"
#include "lauxlib.h"
#include "databindengine.h"
#include "m_mem.h"

/**
 * 库名称，使用方法
 * require('Argo')
 */
#define LIB_NAME "Argo"

/**
 * 检查类型，目前只支持基本类型：boolean|number|string|table
 * 其他类型返回类型type
 */
static inline int checkType(lua_State *L, int index) {
    int type = lua_type(L, index);
    switch(type) {
        case LUA_TBOOLEAN:
        case LUA_TNUMBER:
        case LUA_TSTRING:
        case LUA_TTABLE:
        case LUA_TNIL:
            return 0;
        default:
            return luaL_error(L,
                              "Type %s is invalid",
                              lua_typename(L, type));
    }
}

//<editor-fold desc="lua接口">
/**
 * params: string, table
 * 使用方法:
 *  data = Argo.bind("key", data)
 */
static int argo_bind(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    luaL_checktype(L, 2, LUA_TTABLE);
    DB_Bind(L, key, 2);
    return 1;
}
/**
 * params: string, type, function(new, old)
 * 使用方法:
 *  Argo.watch("key", type, function(new, old) end)
 */
static int argo_watch(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    int type = luaL_checkint(L, 2);
    luaL_checktype(L, 3, LUA_TFUNCTION);
    DB_Watch(L, key, type, 3);
    return 0;
}
/**
 * params: string, type, function(new, old)
 * 使用方法:
 *  Argo.watchTable("key", function(type, key, new, old) end)
 */
static int argo_watchTable(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    DB_WatchTable(L, key, 2);
    return 0;
}
/**
 * params: string
 * 使用方法:
 *  Argo.unwatch("key")
 */
static int argo_unwatch(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    DB_UnWatch(L, key);
    return 0;
}
/**
 * params: string, boolean|number|string|table
 * 使用方法:
 *  Argo.update("key", data)
 */
static int argo_update(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    checkType(L, 2);
    DB_Update(L, key, 2);
    return 0;
}
/**
 * params: key
 * return: boolean|number|string|table
 * 使用方法:
 *  data = Argo.get("key")
 */
static int argo_get(lua_State *L) {
    const char *key=luaL_checkstring(L,1);
    DB_Get(L, key);
    return 1;
}
/**
 * params: key, number, boolean|number|string|table
 * 使用方法:
 *  Argo.insert("key", index, data)
 * index为-1时，在数组末尾添加数据
 */
static int argo_insert(lua_State *L) {
    const  char *key=luaL_checkstring(L,1);
    checkType(L, 3);
    DB_Insert(L, key, luaL_checkint(L, 2), 3);
    return 0;
}
/**
 * params: key, number
 * 使用方法:
 *  Argo.remove("key", index)
 * index为-1时，移除数组末尾数据
 */
static int argo_remove(lua_State *L) {
    const  char *key=luaL_checkstring(L,1);
    DB_Remove(L, key, luaL_checkint(L, 2));
    return 0;
}
/**
 * params: key
 * return: number
 * 使用方法:
 *  len = Argo.len("key")
 */
static int argo_len(lua_State *L) {
    const char *key = luaL_checkstring(L, 1);
    DB_Len(L, key);
    return 1;
}
//</editor-fold>

//<editor-fold desc="register">

static const luaL_Reg libs[] = {
        {"bind", argo_bind},
        {"watch", argo_watch},
        {"watchTable", argo_watchTable},
        {"unwatch", argo_unwatch},
        {"update", argo_update},
        {"get", argo_get},
        {"insert", argo_insert},
        {"remove", argo_remove},
        {"len", argo_len},
        {NULL, NULL}
};

int argo_open(lua_State *L) {
    luaL_newlib(L, libs);
    DataBindInit(m_malloc);
    return 1;
}

void argo_preload(lua_State *L) {
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    lua_pushcfunction(L, argo_open);
    lua_setfield(L, -2, LIB_NAME);
    lua_pop(L, 1);
}

void argo_close(lua_State *L) {
    DB_Close(L);
}
//</editor-fold>