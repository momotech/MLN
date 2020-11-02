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
#define LUA_CLASS_NAME "Label"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID setTextID;
static jmethodID getTextID;
static int _text(lua_State *L);
static jmethodID setTextAlignID;
static jmethodID getTextAlignID;
static int _textAlign(lua_State *L);
static jmethodID setFontSizeID;
static jmethodID getFontSizeID;
static int _fontSize(lua_State *L);
static jmethodID setTextColorID;
static jmethodID getTextColorID;
static int _textColor(lua_State *L);
static jmethodID setLinesID;
static jmethodID getLinesID;
static int _lines(lua_State *L);
static jmethodID setBreakModeID;
static jmethodID getBreakModeID;
static int _breakMode(lua_State *L);
static jmethodID setStyleTextID;
static jmethodID getStyleTextID;
static int _styleText(lua_State *L);
static jmethodID fontNameSizeID;
static int _fontNameSize(lua_State *L);
static jmethodID setLineSpacingID;
static int _setLineSpacing(lua_State *L);
static jmethodID setTextFontStyleID;
static int _setTextFontStyle(lua_State *L);
static jmethodID a_setIncludeFontPaddingID;
static int _a_setIncludeFontPadding(lua_State *L);
static jmethodID addTapTextsID;
static int _addTapTexts(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"text", _text},
            {"textAlign", _textAlign},
            {"fontSize", _fontSize},
            {"textColor", _textColor},
            {"lines", _lines},
            {"breakMode", _breakMode},
            {"styleText", _styleText},
            {"fontNameSize", _fontNameSize},
            {"setLineSpacing", _setLineSpacing},
            {"setTextFontStyle", _setTextFontStyle},
            {"a_setIncludeFontPadding", _a_setIncludeFontPadding},
            {"addTapTexts", _addTapTexts},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDLabel_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    setTextID = (*env)->GetMethodID(env, clz, "setText", "(Ljava/lang/String;)V");
    getTextID = (*env)->GetMethodID(env, clz, "getText", "()Ljava/lang/String;");
    setTextAlignID = (*env)->GetMethodID(env, clz, "setTextAlign", "(I)V");
    getTextAlignID = (*env)->GetMethodID(env, clz, "getTextAlign", "()I");
    setFontSizeID = (*env)->GetMethodID(env, clz, "setFontSize", "(F)V");
    getFontSizeID = (*env)->GetMethodID(env, clz, "getFontSize", "()F");
    setTextColorID = (*env)->GetMethodID(env, clz, "setTextColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getTextColorID = (*env)->GetMethodID(env, clz, "getTextColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setLinesID = (*env)->GetMethodID(env, clz, "setLines", "(I)V");
    getLinesID = (*env)->GetMethodID(env, clz, "getLines", "()I");
    setBreakModeID = (*env)->GetMethodID(env, clz, "setBreakMode", "(I)V");
    getBreakModeID = (*env)->GetMethodID(env, clz, "getBreakMode", "()I");
    setStyleTextID = (*env)->GetMethodID(env, clz, "setStyleText", "(Lcom/immomo/mmui/ud/UDStyleString;)V");
    getStyleTextID = (*env)->GetMethodID(env, clz, "getStyleText", "()Lcom/immomo/mmui/ud/UDStyleString;");
    fontNameSizeID = (*env)->GetMethodID(env, clz, "fontNameSize", "(Ljava/lang/String;F)V");
    setLineSpacingID = (*env)->GetMethodID(env, clz, "setLineSpacing", "(F)V");
    setTextFontStyleID = (*env)->GetMethodID(env, clz, "setTextFontStyle", "(I)V");
    a_setIncludeFontPaddingID = (*env)->GetMethodID(env, clz, "a_setIncludeFontPadding", "(Z)V");
    addTapTextsID = (*env)->GetMethodID(env, clz, "addTapTexts", "(Lcom/immomo/mls/fun/ud/UDArray;Lorg/luaj/vm2/LuaFunction;Lcom/immomo/mmui/ud/UDColor;)V");
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
 * java.lang.String getText()
 * void setText(java.lang.String)
 */
static int _text(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jstring ret = (*env)->CallObjectMethod(env, jobj, getTextID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getText")) {
            return lua_error(L);
        }
        pushJavaString(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getText", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setTextID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setText")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setText", _get_milli_second(&end) - _get_milli_second(&start));
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
 * float getFontSize()
 * void setFontSize(float)
 */
static int _fontSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getFontSizeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFontSize")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFontSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setFontSizeID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontSize")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getTextColor()
 * void setTextColor(com.immomo.mmui.ud.UDColor)
 */
static int _textColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getTextColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getTextColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getTextColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setTextColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setTextColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setTextColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getLines()
 * void setLines(int)
 */
static int _lines(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getLinesID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getLines")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getLines", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setLinesID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLines")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLines", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getBreakMode()
 * void setBreakMode(int)
 */
static int _breakMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getBreakModeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBreakMode")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBreakMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setBreakModeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBreakMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBreakMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDStyleString getStyleText()
 * void setStyleText(com.immomo.mmui.ud.UDStyleString)
 */
static int _styleText(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getStyleTextID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getStyleText")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getStyleText", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setStyleTextID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStyleText")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStyleText", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void fontNameSize(java.lang.String,float)
 */
static int _fontNameSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, fontNameSizeID, p1, (jfloat)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".fontNameSize")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "fontNameSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setLineSpacing(float)
 */
static int _setLineSpacing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setLineSpacingID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLineSpacing")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLineSpacing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setTextFontStyle(int)
 */
static int _setTextFontStyle(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setTextFontStyleID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setTextFontStyle")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setTextFontStyle", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void a_setIncludeFontPadding(boolean)
 */
static int _a_setIncludeFontPadding(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, a_setIncludeFontPaddingID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".a_setIncludeFontPadding")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "a_setIncludeFontPadding", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void addTapTexts(com.immomo.mls.fun.ud.UDArray,org.luaj.vm2.LuaFunction,com.immomo.mmui.ud.UDColor)
 */
static int _addTapTexts(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    jobject p3 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallVoidMethod(env, jobj, addTapTextsID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".addTapTexts")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, p3);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addTapTexts", _get_milli_second(&end) - _get_milli_second(&start));
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