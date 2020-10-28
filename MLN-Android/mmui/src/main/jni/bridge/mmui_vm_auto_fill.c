/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by MOMO on 2020/8/20.
//



#include <jni.h>
#include <lua_include/lapi.h>
#include <jfunction.h>
#include <lua_include/lauxlib.h>

extern jclass LuaValue;

#if defined(J_API_INFO)

/// 为了在开发阶段调用 luaTableKeyPathTrackCode 代码里的
/// lua函数：getAllKeyPath，并且获取全局变量：KeyPathMap。
/// 此时栈顶是全局变量 KeyPathMap
/// \param LS lua 虚拟机指针
/// \param erridx 从lua虚拟机中获取的 getErrorFunctionIndex
void getOriginKeyPath(lua_State *LS, int erridx) {
    lua_pushvalue(LS, -1);
    lua_getglobal(LS, "getAllKeyPath");
    lua_insert(LS, -2);
    lua_pcall(LS, 1, 0, erridx);
    lua_getglobal(LS, "KeyPathMap");
}

#endif

JNIEXPORT jobjectArray JNICALL
Java_com_immomo_mmui_MMUIAutoFillCApi__1autoFill(JNIEnv *env, jclass clazz, jlong L,
                                                 jstring function, jboolean compareSwitch, jobjectArray params,
                                                 jint rc) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int erridx = getErrorFunctionIndex(LS);
    int oldTop = lua_gettop(LS);
    const char *_function = GetString(env, function);
    int res = luaL_loadstring(LS, _function);
    if (res != 0) { // error occur
        throwJavaError(env, LS);
        lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }
    lua_pcall(LS, 0, -1, erridx); // 先返回真正的function，此时在栈顶

    int len = pushJavaArray(env, LS, params);
    int ret = lua_pcall(LS, len, (int) rc, erridx);
    if (ret != 0) {
        throwJavaError(env, LS);
        lua_settop(LS, oldTop);
        lua_unlock(LS);
        return NULL;
    }

#if defined(J_API_INFO)
    if (compareSwitch) {
        getOriginKeyPath(LS, erridx);
    }
#endif

    int returnCount = lua_gettop(LS) - oldTop;
    if (returnCount == 0) {
        lua_settop(LS, oldTop);
        // lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }
    int i;
    jobjectArray r = (*env)->NewObjectArray(env, returnCount, LuaValue, NULL);
    for (i = returnCount - 1; i >= 0; i--) {
        jobject v = toJavaValue(env, LS, oldTop + i + 1);
        (*env)->SetObjectArrayElement(env, r, i, v);
        FREE(env, v);
    }
    lua_settop(LS, oldTop);
    lua_unlock(LS);
    return r;
}