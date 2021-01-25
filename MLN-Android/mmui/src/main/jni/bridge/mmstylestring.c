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
#define LUA_CLASS_NAME "StyleString"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
//<editor-fold desc="method definition">
static jmethodID setFontNameID;
static jmethodID getFontNameID;
static int _fontName(lua_State *L);
static jmethodID setFontSizeID;
static jmethodID getFontSizeID;
static int _fontSize(lua_State *L);
static jmethodID setFontWeightID;
static jmethodID getFontWeightID;
static int _fontWeight(lua_State *L);
static jmethodID setFontStyleID;
static jmethodID getFontStyleID;
static int _fontStyle(lua_State *L);
static jmethodID setFontColorID;
static jmethodID getFontColorID;
static int _fontColor(lua_State *L);
static jmethodID setBackgroundColorID;
static jmethodID getBackgroundColorID;
static int _backgroundColor(lua_State *L);
static jmethodID setUnderlineID;
static jmethodID getUnderlineID;
static int _underline(lua_State *L);
static jmethodID appendID;
static int _append(lua_State *L);
static jmethodID calculateSizeID;
static int _calculateSize(lua_State *L);
static jmethodID setFontNameForRangeID;
static int _setFontNameForRange(lua_State *L);
static jmethodID setFontSizeForRangeID;
static int _setFontSizeForRange(lua_State *L);
static jmethodID setFontStyleForRangeID;
static int _setFontStyleForRange(lua_State *L);
static jmethodID setFontColorForRangeID;
static int _setFontColorForRange(lua_State *L);
static jmethodID setBackgroundColorForRangeID;
static int _setBackgroundColorForRange(lua_State *L);
static jmethodID setUnderlineForRangeID;
static int _setUnderlineForRange(lua_State *L);
static jmethodID showAsImageID;
static int _showAsImage(lua_State *L);
static jmethodID setTextID;
static int _setText(lua_State *L);
static jmethodID imageAlign0ID;
static jmethodID imageAlign1ID;
static int _imageAlign(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"fontName", _fontName},
            {"fontSize", _fontSize},
            {"fontWeight", _fontWeight},
            {"fontStyle", _fontStyle},
            {"fontColor", _fontColor},
            {"backgroundColor", _backgroundColor},
            {"underline", _underline},
            {"append", _append},
            {"calculateSize", _calculateSize},
            {"setFontNameForRange", _setFontNameForRange},
            {"setFontSizeForRange", _setFontSizeForRange},
            {"setFontStyleForRange", _setFontStyleForRange},
            {"setFontColorForRange", _setFontColorForRange},
            {"setBackgroundColorForRange", _setBackgroundColorForRange},
            {"setUnderlineForRange", _setUnderlineForRange},
            {"showAsImage", _showAsImage},
            {"setText", _setText},
            {"imageAlign", _imageAlign},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDStyleString_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JLjava/lang/String;)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    setFontNameID = (*env)->GetMethodID(env, clz, "setFontName", "(Ljava/lang/String;)V");
    getFontNameID = (*env)->GetMethodID(env, clz, "getFontName", "()Ljava/lang/String;");
    setFontSizeID = (*env)->GetMethodID(env, clz, "setFontSize", "(F)V");
    getFontSizeID = (*env)->GetMethodID(env, clz, "getFontSize", "()F");
    setFontWeightID = (*env)->GetMethodID(env, clz, "setFontWeight", "(I)V");
    getFontWeightID = (*env)->GetMethodID(env, clz, "getFontWeight", "()I");
    setFontStyleID = (*env)->GetMethodID(env, clz, "setFontStyle", "(I)V");
    getFontStyleID = (*env)->GetMethodID(env, clz, "getFontStyle", "()I");
    setFontColorID = (*env)->GetMethodID(env, clz, "setFontColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getFontColorID = (*env)->GetMethodID(env, clz, "getFontColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setBackgroundColorID = (*env)->GetMethodID(env, clz, "setBackgroundColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getBackgroundColorID = (*env)->GetMethodID(env, clz, "getBackgroundColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setUnderlineID = (*env)->GetMethodID(env, clz, "setUnderline", "(I)V");
    getUnderlineID = (*env)->GetMethodID(env, clz, "getUnderline", "()I");
    appendID = (*env)->GetMethodID(env, clz, "append", "(Lcom/immomo/mmui/ud/UDStyleString;)V");
    calculateSizeID = (*env)->GetMethodID(env, clz, "calculateSize", "(F)Lcom/immomo/mls/fun/ud/UDSize;");
    setFontNameForRangeID = (*env)->GetMethodID(env, clz, "setFontNameForRange", "(Ljava/lang/String;II)V");
    setFontSizeForRangeID = (*env)->GetMethodID(env, clz, "setFontSizeForRange", "(FII)V");
    setFontStyleForRangeID = (*env)->GetMethodID(env, clz, "setFontStyleForRange", "(III)V");
    setFontColorForRangeID = (*env)->GetMethodID(env, clz, "setFontColorForRange", "(Lcom/immomo/mmui/ud/UDColor;II)V");
    setBackgroundColorForRangeID = (*env)->GetMethodID(env, clz, "setBackgroundColorForRange", "(Lcom/immomo/mmui/ud/UDColor;II)V");
    setUnderlineForRangeID = (*env)->GetMethodID(env, clz, "setUnderlineForRange", "(III)V");
    showAsImageID = (*env)->GetMethodID(env, clz, "showAsImage", "(Lcom/immomo/mls/fun/ud/UDSize;)V");
    setTextID = (*env)->GetMethodID(env, clz, "setText", "(Ljava/lang/String;)V");
    imageAlign0ID = (*env)->GetMethodID(env, clz, "imageAlign", "()V");
    imageAlign1ID = (*env)->GetMethodID(env, clz, "imageAlign", "(I)V");
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
 * java.lang.String getFontName()
 * void setFontName(java.lang.String)
 */
static int _fontName(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jstring ret = (*env)->CallObjectMethod(env, jobj, getFontNameID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFontName")) {
            return lua_error(L);
        }
        pushJavaString(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFontName", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setFontNameID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontName")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontName", _get_milli_second(&end) - _get_milli_second(&start));
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
 * int getFontWeight()
 * void setFontWeight(int)
 */
static int _fontWeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getFontWeightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFontWeight")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFontWeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setFontWeightID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontWeight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontWeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getFontStyle()
 * void setFontStyle(int)
 */
static int _fontStyle(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getFontStyleID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFontStyle")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFontStyle", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setFontStyleID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontStyle")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontStyle", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getFontColor()
 * void setFontColor(com.immomo.mmui.ud.UDColor)
 */
static int _fontColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getFontColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getFontColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getFontColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setFontColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getBackgroundColor()
 * void setBackgroundColor(com.immomo.mmui.ud.UDColor)
 */
static int _backgroundColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getBackgroundColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBackgroundColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBackgroundColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setBackgroundColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBackgroundColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBackgroundColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getUnderline()
 * void setUnderline(int)
 */
static int _underline(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getUnderlineID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getUnderline")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getUnderline", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setUnderlineID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setUnderline")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setUnderline", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void append(com.immomo.mmui.ud.UDStyleString)
 */
static int _append(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, appendID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".append")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "append", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDSize calculateSize(float)
 */
static int _calculateSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    jobject ret = (*env)->CallObjectMethod(env, jobj, calculateSizeID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".calculateSize")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "calculateSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setFontNameForRange(java.lang.String,int,int)
 */
static int _setFontNameForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setFontNameForRangeID, p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontNameForRange")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontNameForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setFontSizeForRange(float,int,int)
 */
static int _setFontSizeForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setFontSizeForRangeID, (jfloat)p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontSizeForRange")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontSizeForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setFontStyleForRange(int,int,int)
 */
static int _setFontStyleForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setFontStyleForRangeID, (jint)p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontStyleForRange")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontStyleForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setFontColorForRange(com.immomo.mmui.ud.UDColor,int,int)
 */
static int _setFontColorForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setFontColorForRangeID, p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFontColorForRange")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFontColorForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setBackgroundColorForRange(com.immomo.mmui.ud.UDColor,int,int)
 */
static int _setBackgroundColorForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setBackgroundColorForRangeID, p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBackgroundColorForRange")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBackgroundColorForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setUnderlineForRange(int,int,int)
 */
static int _setUnderlineForRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setUnderlineForRangeID, (jint)p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setUnderlineForRange")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setUnderlineForRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void showAsImage(com.immomo.mls.fun.ud.UDSize)
 */
static int _showAsImage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, showAsImageID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".showAsImage")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "showAsImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setText(java.lang.String)
 */
static int _setText(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
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
 * void imageAlign()
 * void imageAlign(int)
 */
static int _imageAlign(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            (*env)->CallVoidMethod(env, jobj, imageAlign1ID, (jint)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".imageAlign")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "imageAlign", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".imageAlign函数1个参数有: (int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 1) {
        (*env)->CallVoidMethod(env, jobj, imageAlign0ID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".imageAlign")) {
            return lua_error(L);
        }
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "imageAlign", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
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
    int pc = lua_gettop(L);
    jobject javaObj = NULL;
    if (pc == 1) {
        jstring p1 = newJString(env, lua_tostring(L, 1));
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, p1);
        FREE(env, p1);

    } else {
        javaObj = (*env)->NewObject(env, _globalClass, _constructor1, (jlong) L);
    }
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