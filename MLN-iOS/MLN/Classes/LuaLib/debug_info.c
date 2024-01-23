//
// Created by Xiong.Fangyu 2019/03/13.
//

#include "debug_info.h"

#if defined(J_API_INFO)

#include "mlog.h"
#include "llimits.h"
#include "mln_lauxlib.h"

static inline void addTab(char *tab, int num) {
    int i;
    for (i = 0; i < num; ++i) {
        tab[i] = '\t';
    }
    tab[i] = '\0';
}

void _printTableReverse(lua_State *L, int idx, int level) {
    const int MAX_LEVEL = 16;
    if (level >= MAX_LEVEL) {
        LOGI("level too high, stop!");
        return;
    }
    lua_lock(L);
    if (!lua_istable(L, idx)) {
        LOGE("%d in stack is not a table, it's a %s", idx, LUA_TYPENAME(L, idx));
        lua_unlock(L);
        return;
    }
    const int SIZE = 50;
    char tab[SIZE] = {0};
    idx = idx < 0 ? lua_gettop(L) + idx + 1 : idx;
    lua_pushnil(L);
    addTab(tab, level);
    LOGI("%stable-(%p)={", tab, lua_topointer(L, idx));
    int keyType;
    while (lua_next(L, idx)) {
        keyType = lua_type(L, -2);
        addTab(tab, level + 1);
        if (keyType == LUA_TNUMBER) {
            if (lua_istable(L, -1)) {
                LOGI("%s[%d]=", tab, lua_tointeger(L, -2));
                _printTableReverse(L, -1, level + 2);
            } else {
                lua_pushvalue(L, -1);
                LOGI("%s[%d]='%s',", tab, lua_tointeger(L, -3), luaL_tolstring(L, -1, NULL));
                lua_pop(L, 2);
            }
        } else {
            if (lua_istable(L, -1)) {
                LOGI("%s'%s'=", tab, lua_tostring(L, -2));
                _printTableReverse(L, -1, level + 2);
            } else {
                lua_pushvalue(L, -1);
                LOGI("%s'%s'='%s',", tab, lua_tostring(L, -3), luaL_tolstring(L, -1, NULL));
                lua_pop(L, 2);
            }
        }
        lua_pop(L, 1);
    }
    if (lua_getmetatable(L, idx)) {
        addTab(tab, level + 1);
        LOGI("%smetatable:", tab);
        _printTableReverse(L, -1, level + 2);
        lua_pop(L, 1);
    }
    tab[0] = '\0';
    addTab(tab, level);
    LOGI("%s}", tab);
    lua_unlock(L);
}

void _printTable(lua_State *L, int idx) {
    lua_lock(L);
    if (!lua_istable(L, idx)) {
        LOGE("%d in stack is not a table, it's a %s", idx, LUA_TYPENAME(L, idx));
        lua_unlock(L);
        return;
    }
    idx = idx < 0 ? lua_gettop(L) + idx + 1 : idx;
    lua_pushnil(L);
    LOGI("table-(%p):{", lua_topointer(L, idx));
    int keyType;
    while (lua_next(L, idx)) {
        keyType = lua_type(L, -2);
        if (keyType == LUA_TNUMBER) {
            lua_pushvalue(L, -1);
            LOGI("\t[%d]:'%s',", (int) lua_tonumber(L, -3), luaL_tolstring(L, -1, NULL));
            lua_pop(L, 2);
        } else {
            lua_pushvalue(L, -1);
            LOGI("\t'%s':'%s',", lua_tostring(L, -3), luaL_tolstring(L, -1, NULL));
            lua_pop(L, 2);
        }

        lua_pop(L, 1);
    }
    LOGI("}");
    lua_unlock(L);
}

void _dumpStack(lua_State *L) {
    LOGI("-------------栈顶start-------------");
    int index, type;
    lua_lock(L);
    for (index = lua_gettop(L); index > 0; --index) {
        type = lua_type(L, index);
        if (type == LUA_TNUMBER) {
            LOGI("(%d) %s %f\n", index, lua_typename(L, type), lua_tonumber(L, index));
        } else {
            lua_pushvalue(L, index);
            LOGI("(%d) %s\n", index, luaL_tolstring(L, -1, NULL));
            lua_pop(L, 2);
        }
    }
    lua_unlock(L);
    LOGI("-------------栈底end-------------");
}

LUALIB_API const char *luaL_tolstring (lua_State *L, int idx, size_t *len) {
  if (!luaL_callmeta(L, idx, "__tostring")) {  /* no metafield? */
    switch (lua_type(L, idx)) {
      case LUA_TNUMBER:
      case LUA_TSTRING:
        lua_pushvalue(L, idx);
        break;
      case LUA_TBOOLEAN:
        lua_pushstring(L, (lua_toboolean(L, idx) ? "true" : "false"));
        break;
      case LUA_TNIL:
        lua_pushliteral(L, "nil");
        break;
      default:
        lua_pushfstring(L, "%s: %p", luaL_typename(L, idx),
                                            lua_topointer(L, idx));
        break;
    }
  }
  return lua_tolstring(L, -1, len);
}

//#include <time.h>
//
//static struct timeval start;
//
//void _startTick() {
//    gettimeofday(&start, NULL);
//}
//
//void _endTick() {
//    struct timeval now;
//    gettimeofday(&now, NULL);
//    LOGI("cast: %.2f", (now.tv_usec - start.tv_usec) / 1000.0);
//}

#endif
