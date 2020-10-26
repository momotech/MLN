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
#define LUA_CLASS_NAME "Array"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
//<editor-fold desc="method definition">
static jmethodID add0ID;
static jmethodID add1ID;
static jmethodID add2ID;
static jmethodID add3ID;
static int _add(lua_State *L);
static jmethodID addAllID;
static int _addAll(lua_State *L);
static jmethodID removeID;
static int _remove(lua_State *L);
static jmethodID removeObject0ID;
static jmethodID removeObject1ID;
static jmethodID removeObject2ID;
static jmethodID removeObject3ID;
static int _removeObject(lua_State *L);
static jmethodID removeObjectsID;
static int _removeObjects(lua_State *L);
static jmethodID removeObjectsAtRangeID;
static int _removeObjectsAtRange(lua_State *L);
static jmethodID removeAllID;
static int _removeAll(lua_State *L);
static jmethodID getID;
static int _get(lua_State *L);
static jmethodID sizeID;
static int _size(lua_State *L);
static jmethodID contains0ID;
static jmethodID contains1ID;
static jmethodID contains2ID;
static jmethodID contains3ID;
static int _contains(lua_State *L);
static jmethodID insert0ID;
static jmethodID insert1ID;
static jmethodID insert2ID;
static jmethodID insert3ID;
static int _insert(lua_State *L);
static jmethodID insertObjectsID;
static int _insertObjects(lua_State *L);
static jmethodID replace0ID;
static jmethodID replace1ID;
static jmethodID replace2ID;
static jmethodID replace3ID;
static int _replace(lua_State *L);
static jmethodID replaceObjectsID;
static int _replaceObjects(lua_State *L);
static jmethodID exchangeID;
static int _exchange(lua_State *L);
static jmethodID subArrayID;
static int _subArray(lua_State *L);
static jmethodID copyArrayID;
static int _copyArray(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"add", _add},
            {"addAll", _addAll},
            {"remove", _remove},
            {"removeObject", _removeObject},
            {"removeObjects", _removeObjects},
            {"removeObjectsAtRange", _removeObjectsAtRange},
            {"removeAll", _removeAll},
            {"get", _get},
            {"size", _size},
            {"contains", _contains},
            {"insert", _insert},
            {"insertObjects", _insertObjects},
            {"replace", _replace},
            {"replaceObjects", _replaceObjects},
            {"exchange", _exchange},
            {"subArray", _subArray},
            {"copyArray", _copyArray},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mls_fun_ud_UDArray_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JI)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    add0ID = (*env)->GetMethodID(env, clz, "add", "(Z)V");
    add1ID = (*env)->GetMethodID(env, clz, "add", "(D)V");
    add2ID = (*env)->GetMethodID(env, clz, "add", "(Ljava/lang/String;)V");
    add3ID = (*env)->GetMethodID(env, clz, "add", "(Lorg/luaj/vm2/LuaValue;)V");
    addAllID = (*env)->GetMethodID(env, clz, "addAll", "(Lcom/immomo/mls/fun/ud/UDArray;)V");
    removeID = (*env)->GetMethodID(env, clz, "remove", "(I)V");
    removeObject0ID = (*env)->GetMethodID(env, clz, "removeObject", "(D)V");
    removeObject1ID = (*env)->GetMethodID(env, clz, "removeObject", "(Z)V");
    removeObject2ID = (*env)->GetMethodID(env, clz, "removeObject", "(Ljava/lang/String;)V");
    removeObject3ID = (*env)->GetMethodID(env, clz, "removeObject", "(Lorg/luaj/vm2/LuaValue;)V");
    removeObjectsID = (*env)->GetMethodID(env, clz, "removeObjects", "(Lcom/immomo/mls/fun/ud/UDArray;)V");
    removeObjectsAtRangeID = (*env)->GetMethodID(env, clz, "removeObjectsAtRange", "(II)V");
    removeAllID = (*env)->GetMethodID(env, clz, "removeAll", "()V");
    getID = (*env)->GetMethodID(env, clz, "get", "(I)Lorg/luaj/vm2/LuaValue;");
    sizeID = (*env)->GetMethodID(env, clz, "size", "()I");
    contains0ID = (*env)->GetMethodID(env, clz, "contains", "(D)Z");
    contains1ID = (*env)->GetMethodID(env, clz, "contains", "(Z)Z");
    contains2ID = (*env)->GetMethodID(env, clz, "contains", "(Ljava/lang/String;)Z");
    contains3ID = (*env)->GetMethodID(env, clz, "contains", "(Lorg/luaj/vm2/LuaValue;)Z");
    insert0ID = (*env)->GetMethodID(env, clz, "insert", "(ID)V");
    insert1ID = (*env)->GetMethodID(env, clz, "insert", "(IZ)V");
    insert2ID = (*env)->GetMethodID(env, clz, "insert", "(ILjava/lang/String;)V");
    insert3ID = (*env)->GetMethodID(env, clz, "insert", "(ILorg/luaj/vm2/LuaValue;)V");
    insertObjectsID = (*env)->GetMethodID(env, clz, "insertObjects", "(ILcom/immomo/mls/fun/ud/UDArray;)V");
    replace0ID = (*env)->GetMethodID(env, clz, "replace", "(ID)V");
    replace1ID = (*env)->GetMethodID(env, clz, "replace", "(IZ)V");
    replace2ID = (*env)->GetMethodID(env, clz, "replace", "(ILjava/lang/String;)V");
    replace3ID = (*env)->GetMethodID(env, clz, "replace", "(ILorg/luaj/vm2/LuaValue;)V");
    replaceObjectsID = (*env)->GetMethodID(env, clz, "replaceObjects", "(ILcom/immomo/mls/fun/ud/UDArray;)V");
    exchangeID = (*env)->GetMethodID(env, clz, "exchange", "(II)V");
    subArrayID = (*env)->GetMethodID(env, clz, "subArray", "(II)Lcom/immomo/mls/fun/ud/UDArray;");
    copyArrayID = (*env)->GetMethodID(env, clz, "copyArray", "()Lcom/immomo/mls/fun/ud/UDArray;");
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
 * void add(boolean)
 * void add(double)
 * void add(java.lang.String)
 * void add(org.luaj.vm2.LuaValue)
 */
static int _add(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 2) {
        if (lua_isboolean(L, 2)) {
            int p1 = lua_toboolean(L, 2);
            (*env)->CallVoidMethod(env, jobj, add0ID, (jboolean)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".add")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "add", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            (*env)->CallVoidMethod(env, jobj, add1ID, (jdouble)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".add")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "add", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            (*env)->CallVoidMethod(env, jobj, add2ID, p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".add")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "add", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        (*env)->CallVoidMethod(env, jobj, add3ID, p1);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".add")) {
            FREE(env, p1);
            return lua_error(L);
        }
        FREE(env, p1);
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "add", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void addAll(com.immomo.mls.fun.ud.UDArray)
 */
static int _addAll(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, addAllID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".addAll")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addAll", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void remove(int)
 */
static int _remove(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, removeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".remove")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "remove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeObject(double)
 * void removeObject(boolean)
 * void removeObject(java.lang.String)
 * void removeObject(org.luaj.vm2.LuaValue)
 */
static int _removeObject(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 2) {
        if (lua_isboolean(L, 2)) {
            int p1 = lua_toboolean(L, 2);
            (*env)->CallVoidMethod(env, jobj, removeObject1ID, (jboolean)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObject")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObject", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            (*env)->CallVoidMethod(env, jobj, removeObject0ID, (jdouble)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObject")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObject", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            (*env)->CallVoidMethod(env, jobj, removeObject2ID, p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObject")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObject", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        (*env)->CallVoidMethod(env, jobj, removeObject3ID, p1);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObject")) {
            FREE(env, p1);
            return lua_error(L);
        }
        FREE(env, p1);
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObject", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void removeObjects(com.immomo.mls.fun.ud.UDArray)
 */
static int _removeObjects(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, removeObjectsID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObjects")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObjects", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeObjectsAtRange(int,int)
 */
static int _removeObjectsAtRange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, removeObjectsAtRangeID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObjectsAtRange")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObjectsAtRange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeAll()
 */
static int _removeAll(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeAllID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeAll")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeAll", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaValue get(int)
 */
static int _get(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    jobject ret = (*env)->CallObjectMethod(env, jobj, getID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".get")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "get", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int size()
 */
static int _size(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, sizeID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".size")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "size", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean contains(double)
 * boolean contains(boolean)
 * boolean contains(java.lang.String)
 * boolean contains(org.luaj.vm2.LuaValue)
 */
static int _contains(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 2) {
        if (lua_isboolean(L, 2)) {
            int p1 = lua_toboolean(L, 2);
            jboolean ret = (*env)->CallBooleanMethod(env, jobj, contains1ID, (jboolean)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".contains")) {
                return lua_error(L);
            }
            lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "contains", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jboolean ret = (*env)->CallBooleanMethod(env, jobj, contains0ID, (jdouble)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".contains")) {
                return lua_error(L);
            }
            lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "contains", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jboolean ret = (*env)->CallBooleanMethod(env, jobj, contains2ID, p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".contains")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "contains", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, contains3ID, p1);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".contains")) {
            FREE(env, p1);
            return lua_error(L);
        }
        FREE(env, p1);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "contains", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void insert(int,double)
 * void insert(int,boolean)
 * void insert(int,java.lang.String)
 * void insert(int,org.luaj.vm2.LuaValue)
 */
static int _insert(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_isboolean(L, 3)) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            int p2 = lua_toboolean(L, 3);
            (*env)->CallVoidMethod(env, jobj, insert1ID, (jint)p1, (jboolean)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insert")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insert", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, insert0ID, (jint)p1, (jdouble)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insert")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insert", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TSTRING) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            jstring p2 = newJString(env, lua_tostring(L, 3));
            (*env)->CallVoidMethod(env, jobj, insert2ID, (jint)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insert")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insert", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, insert3ID, (jint)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insert")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insert", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".insert函数2个参数有: (int,boolean) (int,double) (int,String) (int,any)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void insertObjects(int,com.immomo.mls.fun.ud.UDArray)
 */
static int _insertObjects(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallVoidMethod(env, jobj, insertObjectsID, (jint)p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertObjects")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertObjects", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void replace(int,double)
 * void replace(int,boolean)
 * void replace(int,java.lang.String)
 * void replace(int,org.luaj.vm2.LuaValue)
 */
static int _replace(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_isboolean(L, 3)) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            int p2 = lua_toboolean(L, 3);
            (*env)->CallVoidMethod(env, jobj, replace1ID, (jint)p1, (jboolean)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".replace")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "replace", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, replace0ID, (jint)p1, (jdouble)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".replace")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "replace", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TSTRING) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            jstring p2 = newJString(env, lua_tostring(L, 3));
            (*env)->CallVoidMethod(env, jobj, replace2ID, (jint)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".replace")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "replace", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, replace3ID, (jint)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".replace")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "replace", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".replace函数2个参数有: (int,boolean) (int,double) (int,String) (int,any)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void replaceObjects(int,com.immomo.mls.fun.ud.UDArray)
 */
static int _replaceObjects(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallVoidMethod(env, jobj, replaceObjectsID, (jint)p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".replaceObjects")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "replaceObjects", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void exchange(int,int)
 */
static int _exchange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, exchangeID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".exchange")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "exchange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDArray subArray(int,int)
 */
static int _subArray(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    jobject ret = (*env)->CallObjectMethod(env, jobj, subArrayID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".subArray")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "subArray", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDArray copyArray()
 */
static int _copyArray(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, copyArrayID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".copyArray")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "copyArray", _get_milli_second(&end) - _get_milli_second(&start));
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
        lua_Integer p1 = luaL_checkinteger(L, 1);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jint)p1);
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