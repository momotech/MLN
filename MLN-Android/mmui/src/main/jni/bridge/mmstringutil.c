//
// Created by Generator on 2021-03-03
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "statistics.h"
#include "jinfo.h"
#include "jtable.h"

#define PRE JNIEnv *env;                                                        \
            getEnv(&env);                                                       \
            if (!lua_istable(L, 1)) {                                           \
                lua_pushstring(L, "use ':' instead of '.' to call method!!");   \
                setErrorType(L, lua);                                           \
                return lua_error(L);                                            \
            }

#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);


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
#define LUA_CLASS_NAME "StringUtil"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID md5ID;
static int _md5(lua_State *L);
static jmethodID lengthID;
static int _length(lua_State *L);
static jmethodID jsonToMapID;
static int _jsonToMap(lua_State *L);
static jmethodID jsonToArrayID;
static int _jsonToArray(lua_State *L);
static jmethodID arrayToJSONID;
static int _arrayToJSON(lua_State *L);
static jmethodID mapToJSONID;
static int _mapToJSON(lua_State *L);
static jmethodID sizeWithContentFontSizeID;
static int _sizeWithContentFontSize(lua_State *L);
static jmethodID sizeWithContentFontNameSizeID;
static int _sizeWithContentFontNameSize(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"md5", _md5},
            {"length", _length},
            {"jsonToMap", _jsonToMap},
            {"jsonToArray", _jsonToArray},
            {"arrayToJSON", _arrayToJSON},
            {"mapToJSON", _mapToJSON},
            {"sizeWithContentFontSize", _sizeWithContentFontSize},
            {"sizeWithContentFontNameSize", _sizeWithContentFontNameSize},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }
}
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_sbridge_LTStringUtil_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    md5ID = (*env)->GetStaticMethodID(env, clz, "md5", "(Ljava/lang/String;)Ljava/lang/String;");
    lengthID = (*env)->GetStaticMethodID(env, clz, "length", "(Ljava/lang/String;)I");
    jsonToMapID = (*env)->GetStaticMethodID(env, clz, "jsonToMap", "(JLjava/lang/String;)Lcom/immomo/mls/fun/ud/UDMap;");
    jsonToArrayID = (*env)->GetStaticMethodID(env, clz, "jsonToArray", "(JLjava/lang/String;)Lcom/immomo/mls/fun/ud/UDArray;");
    arrayToJSONID = (*env)->GetStaticMethodID(env, clz, "arrayToJSON", "(Lcom/immomo/mls/fun/ud/UDArray;)Ljava/lang/String;");
    mapToJSONID = (*env)->GetStaticMethodID(env, clz, "mapToJSON", "(Lcom/immomo/mls/fun/ud/UDMap;)Ljava/lang/String;");
    sizeWithContentFontSizeID = (*env)->GetStaticMethodID(env, clz, "sizeWithContentFontSize", "(JLjava/lang/String;F)Lcom/immomo/mmui/ud/UDSize;");
    sizeWithContentFontNameSizeID = (*env)->GetStaticMethodID(env, clz, "sizeWithContentFontNameSize", "(JLjava/lang/String;Ljava/lang/String;F)Lcom/immomo/mmui/ud/UDSize;");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 * @param parent 父类，可为空
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)
        (JNIEnv *env, jclass o, jlong l, jstring parent) {
    lua_State *L = (lua_State *)l;

    lua_getglobal(L, LUA_CLASS_NAME);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
    }
    /// -1:table
    const char *luaParent = GetString(env, parent);
    if (luaParent) {
        lua_getglobal(L, luaParent);
        if (!lua_istable(L, -1)) {
            lua_pop(L, 1);
            lua_newtable(L);
            lua_pushvalue(L, -1);
            lua_setglobal(L, luaParent);
        }
        /// -1:parent -2:mytable
        setParentTable(L, -2, -1);
        lua_pop(L, 1);
        ReleaseChar(env, parent, luaParent);
    }
    /// -1:table
    fillUDMetatable(L);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * static java.lang.String md5(java.lang.String)
 */
static int _md5(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, md5ID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".md5")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "md5", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static int length(java.lang.String)
 */
static int _length(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, lengthID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".length")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "length", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static com.immomo.mls.fun.ud.UDMap jsonToMap(long,java.lang.String)
 */
static int _jsonToMap(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, jsonToMapID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".jsonToMap")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "jsonToMap", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static com.immomo.mls.fun.ud.UDArray jsonToArray(long,java.lang.String)
 */
static int _jsonToArray(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, jsonToArrayID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".jsonToArray")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "jsonToArray", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static java.lang.String arrayToJSON(com.immomo.mls.fun.ud.UDArray)
 */
static int _arrayToJSON(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, arrayToJSONID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".arrayToJSON")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "arrayToJSON", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static java.lang.String mapToJSON(com.immomo.mls.fun.ud.UDMap)
 */
static int _mapToJSON(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, mapToJSONID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".mapToJSON")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "mapToJSON", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static com.immomo.mmui.ud.UDSize sizeWithContentFontSize(long,java.lang.String,float)
 */
static int _sizeWithContentFontSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Number p3 = luaL_checknumber(L, 3);
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, sizeWithContentFontSizeID, p1, p2, (jfloat)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".sizeWithContentFontSize")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "sizeWithContentFontSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static com.immomo.mmui.ud.UDSize sizeWithContentFontNameSize(long,java.lang.String,java.lang.String,float)
 */
static int _sizeWithContentFontNameSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring p3 = lua_isnil(L, 3) ? NULL : newJString(env, lua_tostring(L, 3));
    lua_Number p4 = luaL_checknumber(L, 4);
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, sizeWithContentFontNameSizeID, p1, p2, p3, (jfloat)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".sizeWithContentFontNameSize")) {
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "sizeWithContentFontNameSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
