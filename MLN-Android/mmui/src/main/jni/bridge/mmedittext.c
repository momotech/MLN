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
#define LUA_CLASS_NAME "EditTextView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID setPlaceholderID;
static jmethodID getPlaceholderID;
static int _placeholder(lua_State *L);
static jmethodID setPlaceholderColorID;
static jmethodID getPlaceholderColorID;
static int _placeholderColor(lua_State *L);
static jmethodID setInputModeID;
static jmethodID getInputModeID;
static int _inputMode(lua_State *L);
static jmethodID setSingleLineID;
static jmethodID isSingleLineID;
static int _singleLine(lua_State *L);
static jmethodID setTextAlignID;
static jmethodID getTextAlignID;
static int _textAlign(lua_State *L);
static jmethodID setPasswordModeID;
static jmethodID isPasswordModeID;
static int _passwordMode(lua_State *L);
static jmethodID setMaxLengthID;
static jmethodID getMaxLengthID;
static int _maxLength(lua_State *L);
static jmethodID setMaxBytesID;
static jmethodID getMaxBytesID;
static int _maxBytes(lua_State *L);
static jmethodID setReturnModeID;
static int _setReturnMode(lua_State *L);
static jmethodID returnModeID;
static int _returnMode(lua_State *L);
static jmethodID setBeginChangingCallbackID;
static int _setBeginChangingCallback(lua_State *L);
static jmethodID setDidChangingCallbackID;
static int _setDidChangingCallback(lua_State *L);
static jmethodID setEndChangedCallbackID;
static int _setEndChangedCallback(lua_State *L);
static jmethodID setReturnCallbackID;
static int _setReturnCallback(lua_State *L);
static jmethodID setCursorColorID;
static int _setCursorColor(lua_State *L);
static jmethodID setCanEditID;
static int _setCanEdit(lua_State *L);
static jmethodID setShouldChangeCallbackID;
static int _setShouldChangeCallback(lua_State *L);
static jmethodID nShowKeyboardID;
static int _showKeyboard(lua_State *L);
static jmethodID dismissKeyboardID;
static int _dismissKeyboard(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"placeholder", _placeholder},
            {"placeholderColor", _placeholderColor},
            {"inputMode", _inputMode},
            {"singleLine", _singleLine},
            {"textAlign", _textAlign},
            {"passwordMode", _passwordMode},
            {"maxLength", _maxLength},
            {"maxBytes", _maxBytes},
            {"setReturnMode", _setReturnMode},
            {"returnMode", _returnMode},
            {"setBeginChangingCallback", _setBeginChangingCallback},
            {"setDidChangingCallback", _setDidChangingCallback},
            {"setEndChangedCallback", _setEndChangedCallback},
            {"setReturnCallback", _setReturnCallback},
            {"setCursorColor", _setCursorColor},
            {"setCanEdit", _setCanEdit},
            {"setShouldChangeCallback", _setShouldChangeCallback},
            {"showKeyboard", _showKeyboard},
            {"dismissKeyboard", _dismissKeyboard},
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

static int _execute_new_ud(lua_State *L);
static int _new_java_obj(JNIEnv *env, lua_State *L);
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDEditText_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    setPlaceholderID = (*env)->GetMethodID(env, clz, "setPlaceholder", "(Ljava/lang/String;)V");
    getPlaceholderID = (*env)->GetMethodID(env, clz, "getPlaceholder", "()Ljava/lang/String;");
    setPlaceholderColorID = (*env)->GetMethodID(env, clz, "setPlaceholderColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getPlaceholderColorID = (*env)->GetMethodID(env, clz, "getPlaceholderColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setInputModeID = (*env)->GetMethodID(env, clz, "setInputMode", "(I)V");
    getInputModeID = (*env)->GetMethodID(env, clz, "getInputMode", "()I");
    setSingleLineID = (*env)->GetMethodID(env, clz, "setSingleLine", "(Z)V");
    isSingleLineID = (*env)->GetMethodID(env, clz, "isSingleLine", "()Z");
    setTextAlignID = (*env)->GetMethodID(env, clz, "setTextAlign", "(I)V");
    getTextAlignID = (*env)->GetMethodID(env, clz, "getTextAlign", "()I");
    setPasswordModeID = (*env)->GetMethodID(env, clz, "setPasswordMode", "(Z)V");
    isPasswordModeID = (*env)->GetMethodID(env, clz, "isPasswordMode", "()Z");
    setMaxLengthID = (*env)->GetMethodID(env, clz, "setMaxLength", "(I)V");
    getMaxLengthID = (*env)->GetMethodID(env, clz, "getMaxLength", "()I");
    setMaxBytesID = (*env)->GetMethodID(env, clz, "setMaxBytes", "(I)V");
    getMaxBytesID = (*env)->GetMethodID(env, clz, "getMaxBytes", "()I");
    setReturnModeID = (*env)->GetMethodID(env, clz, "setReturnMode", "(I)V");
    returnModeID = (*env)->GetMethodID(env, clz, "returnMode", "()I");
    setBeginChangingCallbackID = (*env)->GetMethodID(env, clz, "setBeginChangingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setDidChangingCallbackID = (*env)->GetMethodID(env, clz, "setDidChangingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setEndChangedCallbackID = (*env)->GetMethodID(env, clz, "setEndChangedCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setReturnCallbackID = (*env)->GetMethodID(env, clz, "setReturnCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setCursorColorID = (*env)->GetMethodID(env, clz, "setCursorColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    setCanEditID = (*env)->GetMethodID(env, clz, "setCanEdit", "(Z)V");
    setShouldChangeCallbackID = (*env)->GetMethodID(env, clz, "setShouldChangeCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    nShowKeyboardID = (*env)->GetMethodID(env, clz, "nShowKeyboard", "()V");
    dismissKeyboardID = (*env)->GetMethodID(env, clz, "dismissKeyboard", "()V");
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

    lua_pushcfunction(L, _execute_new_ud);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * java.lang.String getPlaceholder()
 * void setPlaceholder(java.lang.String)
 */
static int _placeholder(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jstring ret = (*env)->CallObjectMethod(env, jobj, getPlaceholderID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPlaceholder")) {
            return lua_error(L);
        }
        pushJavaString(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPlaceholder", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setPlaceholderID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPlaceholder")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPlaceholder", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getPlaceholderColor()
 * void setPlaceholderColor(com.immomo.mmui.ud.UDColor)
 */
static int _placeholderColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getPlaceholderColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPlaceholderColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPlaceholderColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setPlaceholderColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPlaceholderColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPlaceholderColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getInputMode()
 * void setInputMode(int)
 */
static int _inputMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getInputModeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getInputMode")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getInputMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setInputModeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setInputMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setInputMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isSingleLine()
 * void setSingleLine(boolean)
 */
static int _singleLine(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isSingleLineID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isSingleLine")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isSingleLine", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setSingleLineID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setSingleLine")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setSingleLine", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getTextAlign()
 * void setTextAlign(int)
 */
static int _textAlign(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getTextAlignID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getTextAlign")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getTextAlign", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setTextAlignID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setTextAlign")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setTextAlign", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isPasswordMode()
 * void setPasswordMode(boolean)
 */
static int _passwordMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isPasswordModeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isPasswordMode")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isPasswordMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPasswordModeID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPasswordMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPasswordMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getMaxLength()
 * void setMaxLength(int)
 */
static int _maxLength(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getMaxLengthID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxLength")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxLength", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxLengthID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxLength")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxLength", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getMaxBytes()
 * void setMaxBytes(int)
 */
static int _maxBytes(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getMaxBytesID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxBytes")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxBytes", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxBytesID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxBytes")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxBytes", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setReturnMode(int)
 */
static int _setReturnMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setReturnModeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setReturnMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setReturnMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int returnMode()
 */
static int _returnMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, returnModeID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".returnMode")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "returnMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setBeginChangingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setBeginChangingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setBeginChangingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBeginChangingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBeginChangingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setDidChangingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setDidChangingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setDidChangingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDidChangingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setDidChangingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setEndChangedCallback(org.luaj.vm2.LuaFunction)
 */
static int _setEndChangedCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setEndChangedCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEndChangedCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setEndChangedCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setReturnCallback(org.luaj.vm2.LuaFunction)
 */
static int _setReturnCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setReturnCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setReturnCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setReturnCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setCursorColor(com.immomo.mmui.ud.UDColor)
 */
static int _setCursorColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setCursorColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCursorColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCursorColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setCanEdit(boolean)
 */
static int _setCanEdit(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setCanEditID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCanEdit")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCanEdit", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setShouldChangeCallback(org.luaj.vm2.LuaFunction)
 */
static int _setShouldChangeCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setShouldChangeCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShouldChangeCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShouldChangeCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void nShowKeyboard()
 */
static int _showKeyboard(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, nShowKeyboardID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nShowKeyboard")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nShowKeyboard", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void dismissKeyboard()
 */
static int _dismissKeyboard(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, dismissKeyboardID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".dismissKeyboard")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "dismissKeyboard", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>

static int _execute_new_ud(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif

    JNIEnv *env;
    int need = getEnv(&env);

    if (_new_java_obj(env, L)) {
        if (need) detachEnv();
        lua_error(L);
        return 1;
    }

    luaL_getmetatable(L, META_NAME);
    lua_setmetatable(L, -2);

    if (need) detachEnv();

#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(LUA_CLASS_NAME, InitMethodName, offset);
#endif

    return 1;
}
static int _new_java_obj(JNIEnv *env, lua_State *L) {
    jobject javaObj = NULL;
    javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L);

    char *info = joinstr(LUA_CLASS_NAME, InitMethodName);

    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);
        FREE(env, javaObj);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);

    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));
    ud->id = getUserdataId(env, javaObj);
    if (isStrongUserdata(env, _globalClass)) {
        setUDFlag(ud, JUD_FLAG_STRONG);
        copyUDToGNV(env, L, ud, -1, javaObj);
    }
    FREE(env, javaObj);
    ud->refCount = 0;

    ud->name = lua_pushstring(L, META_NAME);
    lua_pop(L, 1);
    return 0;
}