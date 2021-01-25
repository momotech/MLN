/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-23
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
#define LUA_CLASS_NAME "_BaseFlexGroup"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
//<editor-fold desc="method definition">
static jmethodID addViewID;
static int _addView(lua_State *L);
static jmethodID removeAllSubviewsID;
static int _removeAllSubviews(lua_State *L);
static jmethodID childrenID;
static int _children(lua_State *L);
static jmethodID setMainAxisID;
static jmethodID getMainAxisID;
static int _mainAxis(lua_State *L);
static jmethodID setCrossAxisID;
static jmethodID getCrossAxisID;
static int _crossAxis(lua_State *L);
static jmethodID setCrossContentID;
static jmethodID getCrossContentID;
static int _crossContent(lua_State *L);
static jmethodID setWrapID;
static jmethodID getWrapID;
static int _wrap(lua_State *L);
static jmethodID dispatchTouchTargetID;
static int _dispatchTouchTarget(lua_State *L);
static jmethodID insertViewID;
static int _insertView(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"addView", _addView},
            {"removeAllSubviews", _removeAllSubviews},
            {"children", _children},
            {"mainAxis", _mainAxis},
            {"crossAxis", _crossAxis},
            {"crossContent", _crossContent},
            {"wrap", _wrap},
            {"dispatchTouchTarget", _dispatchTouchTarget},
            {"insertView", _insertView},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDNodeGroup_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZ)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    addViewID = (*env)->GetMethodID(env, clz, "addView", "(Lcom/immomo/mmui/ud/UDView;)V");
    removeAllSubviewsID = (*env)->GetMethodID(env, clz, "removeAllSubviews", "()V");
    childrenID = (*env)->GetMethodID(env, clz, "children", "(Lorg/luaj/vm2/LuaTable;)V");
    setMainAxisID = (*env)->GetMethodID(env, clz, "setMainAxis", "(I)V");
    getMainAxisID = (*env)->GetMethodID(env, clz, "getMainAxis", "()I");
    setCrossAxisID = (*env)->GetMethodID(env, clz, "setCrossAxis", "(I)V");
    getCrossAxisID = (*env)->GetMethodID(env, clz, "getCrossAxis", "()I");
    setCrossContentID = (*env)->GetMethodID(env, clz, "setCrossContent", "(I)V");
    getCrossContentID = (*env)->GetMethodID(env, clz, "getCrossContent", "()I");
    setWrapID = (*env)->GetMethodID(env, clz, "setWrap", "(I)V");
    getWrapID = (*env)->GetMethodID(env, clz, "getWrap", "()I");
    dispatchTouchTargetID = (*env)->GetMethodID(env, clz, "dispatchTouchTarget", "(FFI)V");
    insertViewID = (*env)->GetMethodID(env, clz, "insertView", "(Lcom/immomo/mmui/ud/UDView;I)V");
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
 * void addView(com.immomo.mmui.ud.UDView)
 */
static int _addView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, addViewID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".addView")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeAllSubviews()
 */
static int _removeAllSubviews(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeAllSubviewsID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeAllSubviews")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeAllSubviews", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void children(org.luaj.vm2.LuaTable)
 */
static int _children(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, childrenID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".children")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "children", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getMainAxis()
 * void setMainAxis(int)
 */
static int _mainAxis(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getMainAxisID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMainAxis")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMainAxis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMainAxisID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMainAxis")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMainAxis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getCrossAxis()
 * void setCrossAxis(int)
 */
static int _crossAxis(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getCrossAxisID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getCrossAxis")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getCrossAxis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setCrossAxisID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCrossAxis")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCrossAxis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getCrossContent()
 * void setCrossContent(int)
 */
static int _crossContent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getCrossContentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getCrossContent")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getCrossContent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setCrossContentID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCrossContent")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCrossContent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getWrap()
 * void setWrap(int)
 */
static int _wrap(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getWrapID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getWrap")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getWrap", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setWrapID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setWrap")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setWrap", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void dispatchTouchTarget(float,float,int)
 */
static int _dispatchTouchTarget(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, dispatchTouchTargetID, (jfloat)p1, (jfloat)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".dispatchTouchTarget")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "dispatchTouchTarget", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void insertView(com.immomo.mmui.ud.UDView,int)
 */
static int _insertView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, insertViewID, p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertView")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertView", _get_milli_second(&end) - _get_milli_second(&start));
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
    int pc = lua_gettop(L);
    jobject javaObj = NULL;
    if (pc == 1) {
        int p1 = lua_toboolean(L, 1);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jboolean)p1);
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