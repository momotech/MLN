/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-07-04.
//

#include "lapi.h"
#include "lua.h"
#include "lauxlib.h"


static int check_first_table(lua_State *L) {
    if (!lua_istable(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        return lua_error(L);
    }
    return 0;
}

/**
 * MBit:bor(int a,int b,[int ...])
 * @return a | b | ...
 */
static int bor(lua_State *L) {
    check_first_table(L);

    lua_Integer ret = 0;
    int index = lua_gettop(L);
    while (index >= 2) {
        ret |= lua_tointeger(L, index--);
    }
    lua_pushinteger(L, ret);
    return 1;
}

/**
 * MBit:band(int a,int b,[int ...])
 * @return a & b & ...
 */
static int band(lua_State *L) {
    check_first_table(L);

    lua_Integer ret = lua_tointeger(L, 2);
    int index = lua_gettop(L);
    while (index >= 3) {
        ret &= lua_tointeger(L, index--);
    }
    lua_pushinteger(L, ret);
    return 1;
}

/**
 * MBit:bxor(int a,int b,[int ...])
 * @return a ^ b ^ ...
 */
static int bxor(lua_State *L) {
    check_first_table(L);

    lua_Integer ret = lua_tointeger(L, 2);
    int index = lua_gettop(L);
    while (index >= 3) {
        ret ^= lua_tointeger(L, index--);
    }
    lua_pushinteger(L, ret);
    return 1;
}

/**
 * MBit:neg(int a)
 * @return ~a
 */
static int neg(lua_State *L) {
    check_first_table(L);

    lua_Integer ret = lua_tointeger(L, 2);
    lua_pushinteger(L, ~ret);
    return 1;
}

/**
 * MBit:shl(int a, int b)
 * @return a << b
 */
static int shl(lua_State *L) {
    check_first_table(L);

    lua_Integer a = lua_tointeger(L, 2);
    lua_Integer b = lua_isnumber(L, 3) ? lua_tointeger(L, 3) : 0;
    lua_pushinteger(L, a << b);
    return 1;
}

/**
 * MBit:shr(int a, int b)
 * @return a >> b
 */
static int shr(lua_State *L) {
    check_first_table(L);

    lua_Integer a = lua_tointeger(L, 2);
    lua_Integer b = lua_isnumber(L, 3) ? lua_tointeger(L, 3) : 0;
    lua_pushinteger(L, a >> b);
    return 1;
}

static const luaL_Reg funcs[] = {
        {"bor",  bor},
        {"band", band},
        {"bxor", bxor},
        {"neg",  neg},
        {"shl",  shl},
        {"shr",  shr},
        {NULL, NULL}
};

extern int mm_open_bit(lua_State *L) {
    luaL_newlib(L, funcs);
    return 1;
}