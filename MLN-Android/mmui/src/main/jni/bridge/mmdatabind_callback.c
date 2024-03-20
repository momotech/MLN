//
// Created by Generator on 2021-03-03
//

#include "lua.h"
#include "jfunction.h"
#include <jni.h>
#define _Call(R) JNIEXPORT R JNICALL
#define _Method(s) Java_com_immomo_mmui_databinding_DataBindingCallback_ ## s
#define _PRE4PARAMS JNIEnv *env, jobject jobj, jlong Ls, jlong function

static inline void push_number(lua_State *L, jdouble num) {
    lua_Integer li1 = (lua_Integer) num;
    if (li1 == num) {
        lua_pushinteger(L, li1);
    } else {
        lua_pushnumber(L, num);
    }
}

static inline void push_string(JNIEnv *env, lua_State *L, jstring s) {
    const char *str = GetString(env, s);
    if (str)
        lua_pushstring(L, str);
    else
        lua_pushnil(L);
    ReleaseChar(env, s, str);
}
_Call(jboolean) _Method(BnativeInvokeII)(_PRE4PARAMS,jint p1,jint p2) {
    lua_State *L = (lua_State *) Ls;
    jboolean fr = 0;
    call_method_return(L, 2, 1, {
        lua_pushinteger(L, (lua_Integer)p1);
        lua_pushinteger(L, (lua_Integer)p2);
    },{
        fr = lua_toboolean(L, -1);
    }, return fr)
    return fr;
}
