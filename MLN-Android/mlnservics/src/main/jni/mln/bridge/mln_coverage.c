/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  mln_coverage.c
//  MLNDebugger
//
//  Created by xindong on 2019/11/14.
//  Copyright © 2019 com.test. All rights reserved.
//

#include <string.h>
#include "lualib.h"
#include "mln_coverage.h"
#include "lauxlib.h"
#include "../utils.h"
#include "../m_mem.h"
#include "../jinfo.h"

static jclass HotReloadHelper = NULL;
static jmethodID HotReloadHelper_onReportFromLua = NULL;

static int mil_clearCodeCoverageResult(lua_State *L);

static int mil_reportCodeCoverageSummary(lua_State *L);

static int mil_luaBundlePath(lua_State *L) {
    lua_getglobal(L, LUA_LOADLIBNAME);  //-1 package table
    lua_getfield(L, -1, "path");        //-1 path -2 package table
    lua_remove(L, -2);
    return 1;
}

static void initJavaClass() {
    JNIEnv *env;
    getEnv(&env);

    HotReloadHelper = (*env)->FindClass(env, "com/immomo/mls/HotReloadHelper");
    if ((*env)->ExceptionCheck(env)) {
        ExceptionDescribe(env);
        (*env)->ExceptionClear(env);
        return;
    }
    if (!HotReloadHelper)
        return;
    HotReloadHelper = GLOBAL(env, HotReloadHelper);
    HotReloadHelper_onReportFromLua = (*env)->GetStaticMethodID(env, HotReloadHelper, "onReportFromLua", "(J" STRING_CLASS STRING_CLASS ")V");
    if ((*env)->ExceptionCheck(env)) {
        ExceptionDescribe(env);
        (*env)->ExceptionClear(env);
        return;
    }
}

void mln_opencoveragec(lua_State *L) {
    if (!L) return;
    initJavaClass();
    lua_pushcfunction(L, mil_clearCodeCoverageResult);
    lua_setglobal(L, "MLNCodeCovClearPreviousResult");
    lua_pushcfunction(L, mil_luaBundlePath);
    lua_setglobal(L, "MLNBundlePath");
    lua_pushcfunction(L, mil_reportCodeCoverageSummary);
    lua_setglobal(L, "reportCoverageSummary");
}

#include "../mlog.h"
static int mil_clearCodeCoverageResult(lua_State *L) {
    if (lua_type(L, -1) != LUA_TTABLE) {
        return 0;
    }
    mil_luaBundlePath(L);
    const char *path = lua_tostring(L, -1);
    if (!path)
        return 0;
    lua_pop(L, 1);

    lua_pushnil(L);
    while (lua_istable(L, -2) && lua_next(L, -2)) {
        const char *fileName = lua_tostring(L, -1);
        lua_pop(L, 1); // remove value and reserve key
        if (!fileName) continue;
        char *p = join3str(path, "/", fileName);
        LOGE("remove %s", p);
        remove(p);
        m_malloc(p, sizeof(char) * (strlen(p) + 1), 0);
    }
    return 0;
}

static int mil_reportCodeCoverageSummary(lua_State *L) {
    if (!HotReloadHelper || !HotReloadHelper_onReportFromLua) {
        return 0;
    }
    const char *summaryFilePath = lua_tostring(L, 1);
    const char *detailFilePath = lua_tostring(L, 2);
    JNIEnv *env;
    getEnv(&env);
    jstring sfp = summaryFilePath ? newJString(env, summaryFilePath) : NULL;
    jstring dfp = detailFilePath ? newJString(env, detailFilePath) : NULL;
    (*env)->CallStaticVoidMethod(env, HotReloadHelper, HotReloadHelper_onReportFromLua, (jlong) L, sfp, dfp);
    if ((*env)->ExceptionCheck(env)) {
        ExceptionDescribe(env);
        (*env)->ExceptionClear(env);
        return 0;
    }
    if (sfp)
        (*env)->DeleteLocalRef(env, sfp);
    if (dfp)
        (*env)->DeleteLocalRef(env, dfp);

    return 0;
}