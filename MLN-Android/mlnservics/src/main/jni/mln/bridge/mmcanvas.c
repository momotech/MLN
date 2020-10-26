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
#define LUA_CLASS_NAME "CCanvas"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID saveID;
static int _save(lua_State *L);
static jmethodID restoreID;
static int _restore(lua_State *L);
static jmethodID restoreToCountID;
static int _restoreToCount(lua_State *L);
static jmethodID translateID;
static int _translate(lua_State *L);
static jmethodID clipRectID;
static int _clipRect(lua_State *L);
static jmethodID clipPathID;
static int _clipPath(lua_State *L);
static jmethodID drawColorID;
static int _drawColor(lua_State *L);
static jmethodID drawRectID;
static int _drawRect(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"save", _save},
            {"restore", _restore},
            {"restoreToCount", _restoreToCount},
            {"translate", _translate},
            {"clipRect", _clipRect},
            {"clipPath", _clipPath},
            {"drawColor", _drawColor},
            {"drawRect", _drawRect},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mls_fun_ud_UDCCanvas_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    saveID = (*env)->GetMethodID(env, clz, "save", "()I");
    restoreID = (*env)->GetMethodID(env, clz, "restore", "()V");
    restoreToCountID = (*env)->GetMethodID(env, clz, "restoreToCount", "(I)V");
    translateID = (*env)->GetMethodID(env, clz, "translate", "(DD)V");
    clipRectID = (*env)->GetMethodID(env, clz, "clipRect", "(DDDD)V");
    clipPathID = (*env)->GetMethodID(env, clz, "clipPath", "(Lcom/immomo/mls/fun/ud/UDPath;)V");
    drawColorID = (*env)->GetMethodID(env, clz, "drawColor", "(I)V");
    drawRectID = (*env)->GetMethodID(env, clz, "drawRect", "(DDDDLcom/immomo/mls/fun/ud/UDPaint;)V");
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
 * int save()
 */
static int _save(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, saveID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".save")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "save", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void restore()
 */
static int _restore(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, restoreID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".restore")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "restore", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void restoreToCount(int)
 */
static int _restoreToCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, restoreToCountID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".restoreToCount")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "restoreToCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void translate(double,double)
 */
static int _translate(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, translateID, (jdouble)p1, (jdouble)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".translate")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "translate", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clipRect(double,double,double,double)
 */
static int _clipRect(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    (*env)->CallVoidMethod(env, jobj, clipRectID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clipRect")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clipRect", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clipPath(com.immomo.mls.fun.ud.UDPath)
 */
static int _clipPath(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, clipPathID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clipPath")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clipPath", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void drawColor(int)
 */
static int _drawColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, drawColorID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".drawColor")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "drawColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void drawRect(double,double,double,double,com.immomo.mls.fun.ud.UDPaint)
 */
static int _drawRect(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    jobject p5 = lua_isnil(L, 6) ? NULL : toJavaValue(env, L, 6);
    (*env)->CallVoidMethod(env, jobj, drawRectID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4, p5);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".drawRect")) {
        FREE(env, p5);
        return lua_error(L);
    }
    FREE(env, p5);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "drawRect", _get_milli_second(&end) - _get_milli_second(&start));
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