/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by XiongFangyu on 2020/7/24.
//

#include "lua.h"
#include "jfunction.h"
#include <jni.h>

#define IBC_Void_Call JNIEXPORT void JNICALL

#define IBC_Method(s) Java_com_immomo_mmui_ud_anim_InteractiveBehaviorCallback_ ## s

#define IBC_PRE4PARAMS JNIEnv *env, jobject jobj, jlong Ls, jlong function,

//<editor-fold desc="fast call">
IBC_Void_Call IBC_Method(nativeCallback)(IBC_PRE4PARAMS jint type, jfloat dis, jfloat v);
//</editor-fold>

IBC_Void_Call IBC_Method(nativeCallback)(IBC_PRE4PARAMS jint type, jfloat dis, jfloat v) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 3, {
        lua_pushinteger(L, type);
        lua_pushnumber(L, dis);
        lua_pushnumber(L, v);
    })
}