/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-16
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "statistics.h"
#include "jinfo.h"
#include "jtable.h"
#include "juserdata.h"
#include "m_mem.h"

#define PRE if (!lua_isuserdata(L, 1)) {                            \
        lua_pushstring(L, "use ':' instead of '.' to call method!!");\
        lua_error(L);                                               \
        return 1;                                                   \
    }                                                               \
            JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                lua_error(L);                                       \
                return 1;                                           \
            }

#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);

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

static inline void dumpParams(lua_State *L, int from) {
    const int SIZE = 100;
    const int MAX = SIZE - 4;
    char type[SIZE] = {0};
    int top = lua_gettop(L);
    int i;
    int idx = 0;
    for (i = from; i <= top; ++i) {
        const char *n = lua_typename(L, lua_type(L, i));
        size_t len = strlen(n);
        if (len + idx >= MAX) {
            memcpy(type + idx, "...", 3);
            break;
        }
        if (i != from) {
            type[idx ++] = ',';
        }
        memcpy(type + idx, n, len);
        idx += len;
    }
    lua_pushstring(L, type);
}
#ifdef STATISTIC_PERFORMANCE
#include <time.h>
#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)
#endif
#define LUA_CLASS_NAME "_BaseAnimation"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID getStartBlockID;
static jmethodID setStartBlockID;
static int _startBlock(lua_State *L);
static jmethodID getPauseBlockID;
static jmethodID setPauseBlockID;
static int _pauseBlock(lua_State *L);
static jmethodID getResumeBlockID;
static jmethodID setResumeBlockID;
static int _resumeBlock(lua_State *L);
static jmethodID getRepeatBlockID;
static jmethodID setRepeatBlockID;
static int _repeatBlock(lua_State *L);
static jmethodID getFinishBlockID;
static jmethodID setFinishBlockID;
static int _finishBlock(lua_State *L);
static jmethodID updateID;
static int _update(lua_State *L);
static jmethodID startID;
static int _start(lua_State *L);
static jmethodID pauseID;
static int _pause(lua_State *L);
static jmethodID resumeID;
static int _resume(lua_State *L);
static jmethodID stopID;
static int _stop(lua_State *L);
static jmethodID getDelayID;
static jmethodID setDelayID;
static int _delay(lua_State *L);
static jmethodID isAutoReversesID;
static jmethodID setAutoReversesID;
static int _autoReverses(lua_State *L);
static jmethodID isRepeatForeverID;
static jmethodID setRepeatForeverID;
static int _repeatForever(lua_State *L);
static jmethodID getRepeatCountID;
static jmethodID setRepeatCountID;
static int _repeatCount(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"startBlock", _startBlock},
            {"pauseBlock", _pauseBlock},
            {"resumeBlock", _resumeBlock},
            {"repeatBlock", _repeatBlock},
            {"finishBlock", _finishBlock},
            {"update", _update},
            {"start", _start},
            {"pause", _pause},
            {"resume", _resume},
            {"stop", _stop},
            {"delay", _delay},
            {"autoReverses", _autoReverses},
            {"repeatForever", _repeatForever},
            {"repeatCount", _repeatCount},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }

    if (parentMeta) {
        JNIEnv *env;
        getEnv(&env);
        setParentMetatable(env, L, parentMeta);
    }
}
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_anim_UDBaseAnimation_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    getStartBlockID = (*env)->GetMethodID(env, clz, "getStartBlock", "()Lorg/luaj/vm2/LuaFunction;");
    setStartBlockID = (*env)->GetMethodID(env, clz, "setStartBlock", "(Lorg/luaj/vm2/LuaFunction;)V");
    getPauseBlockID = (*env)->GetMethodID(env, clz, "getPauseBlock", "()Lorg/luaj/vm2/LuaFunction;");
    setPauseBlockID = (*env)->GetMethodID(env, clz, "setPauseBlock", "(Lorg/luaj/vm2/LuaFunction;)V");
    getResumeBlockID = (*env)->GetMethodID(env, clz, "getResumeBlock", "()Lorg/luaj/vm2/LuaFunction;");
    setResumeBlockID = (*env)->GetMethodID(env, clz, "setResumeBlock", "(Lorg/luaj/vm2/LuaFunction;)V");
    getRepeatBlockID = (*env)->GetMethodID(env, clz, "getRepeatBlock", "()Lorg/luaj/vm2/LuaFunction;");
    setRepeatBlockID = (*env)->GetMethodID(env, clz, "setRepeatBlock", "(Lorg/luaj/vm2/LuaFunction;)V");
    getFinishBlockID = (*env)->GetMethodID(env, clz, "getFinishBlock", "()Lorg/luaj/vm2/LuaFunction;");
    setFinishBlockID = (*env)->GetMethodID(env, clz, "setFinishBlock", "(Lorg/luaj/vm2/LuaFunction;)V");
    updateID = (*env)->GetMethodID(env, clz, "update", "(F)V");
    startID = (*env)->GetMethodID(env, clz, "start", "()V");
    pauseID = (*env)->GetMethodID(env, clz, "pause", "()V");
    resumeID = (*env)->GetMethodID(env, clz, "resume", "()V");
    stopID = (*env)->GetMethodID(env, clz, "stop", "()V");
    getDelayID = (*env)->GetMethodID(env, clz, "getDelay", "()F");
    setDelayID = (*env)->GetMethodID(env, clz, "setDelay", "(F)V");
    isAutoReversesID = (*env)->GetMethodID(env, clz, "isAutoReverses", "()Z");
    setAutoReversesID = (*env)->GetMethodID(env, clz, "setAutoReverses", "(Z)V");
    isRepeatForeverID = (*env)->GetMethodID(env, clz, "isRepeatForever", "()Z");
    setRepeatForeverID = (*env)->GetMethodID(env, clz, "setRepeatForever", "(Z)V");
    getRepeatCountID = (*env)->GetMethodID(env, clz, "getRepeatCount", "()I");
    setRepeatCountID = (*env)->GetMethodID(env, clz, "setRepeatCount", "(I)V");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 * @param parent 父类，可为空
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)
        (JNIEnv *env, jclass o, jlong l, jstring parent) {
    lua_State *L = (lua_State *)l;

    u_newmetatable(L, META_NAME);
    /// get metatable.__index
    lua_pushstring(L, LUA_INDEX);
    lua_rawget(L, -2);
    /// 未初始化过，创建并设置metatable.__index
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_pushstring(L, LUA_INDEX);
        lua_pushvalue(L, -2);
        /// -1:nt -2:__index -3:nt -4:mt
        /// mt.__index=nt
        lua_rawset(L, -4);
    }
    /// -1:nt -2: metatable
    const char *luaParent = GetString(env, parent);
    if (luaParent) {
        char *parentMeta = getUDMetaname(luaParent);
        fillUDMetatable(L, parentMeta);
#if defined(J_API_INFO)
        m_malloc(parentMeta, (strlen(parentMeta) + 1) * sizeof(char), 0);
#else
        free(parentMeta);
#endif
        ReleaseChar(env, parent, luaParent);
    } else {
        fillUDMetatable(L, NULL);
    }

    jclass clz = _globalClass;

    /// 设置gc方法
    pushUserdataGcClosure(env, L, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, L, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, L, clz);
    lua_pop(L, 2);

}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * org.luaj.vm2.LuaFunction getStartBlock()
 * void setStartBlock(org.luaj.vm2.LuaFunction)
 */
static int _startBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getStartBlockID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getStartBlock")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getStartBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setStartBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStartBlock")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStartBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaFunction getPauseBlock()
 * void setPauseBlock(org.luaj.vm2.LuaFunction)
 */
static int _pauseBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getPauseBlockID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPauseBlock")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPauseBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setPauseBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPauseBlock")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPauseBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaFunction getResumeBlock()
 * void setResumeBlock(org.luaj.vm2.LuaFunction)
 */
static int _resumeBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getResumeBlockID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getResumeBlock")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getResumeBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setResumeBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setResumeBlock")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setResumeBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaFunction getRepeatBlock()
 * void setRepeatBlock(org.luaj.vm2.LuaFunction)
 */
static int _repeatBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getRepeatBlockID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getRepeatBlock")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getRepeatBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setRepeatBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRepeatBlock")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRepeatBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaFunction getFinishBlock()
 * void setFinishBlock(org.luaj.vm2.LuaFunction)
 */
static int _finishBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getFinishBlockID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFinishBlock")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFinishBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setFinishBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFinishBlock")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFinishBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void update(float)
 */
static int _update(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, updateID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".update")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "update", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void start()
 */
static int _start(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, startID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".start")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "start", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void pause()
 */
static int _pause(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, pauseID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".pause")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "pause", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void resume()
 */
static int _resume(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, resumeID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".resume")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "resume", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void stop()
 */
static int _stop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, stopID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".stop")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "stop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getDelay()
 * void setDelay(float)
 */
static int _delay(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getDelayID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getDelay")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getDelay", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setDelayID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDelay")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setDelay", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isAutoReverses()
 * void setAutoReverses(boolean)
 */
static int _autoReverses(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isAutoReversesID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isAutoReverses")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isAutoReverses", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setAutoReversesID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setAutoReverses")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setAutoReverses", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isRepeatForever()
 * void setRepeatForever(boolean)
 */
static int _repeatForever(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isRepeatForeverID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isRepeatForever")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isRepeatForever", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setRepeatForeverID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRepeatForever")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRepeatForever", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getRepeatCount()
 * void setRepeatCount(int)
 */
static int _repeatCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getRepeatCountID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getRepeatCount")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getRepeatCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setRepeatCountID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRepeatCount")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRepeatCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
