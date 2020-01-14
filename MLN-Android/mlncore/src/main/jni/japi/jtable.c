/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/03/13.
//

#include "jtable.h"
#include "debug_info.h"
#include "luaconf.h"
#include "m_mem.h"
#include "llimits.h"
#include "jinfo.h"
#include "cache.h"

extern jclass LuaValue;
extern jclass Entrys;
extern jmethodID Entrys_C;

void jni_clearTableArray(JNIEnv *env, jobject jobj, jlong L, jlong table, jint from, jint to) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
    while (from <= to) {
        lua_pushinteger(LS, from);
        lua_pushnil(LS);
        lua_rawset(LS, -3);
        from++;
    }
    lua_pop(LS, 1);
    lua_unlock(LS);
}

jlong jni_createTable(JNIEnv *env, jobject jobj, jlong L) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    lua_newtable(LS);
    ptrdiff_t key = copyValueToGNV(LS, -1);
    lua_pop(LS, 1);
    lua_unlock(LS);
    return (jlong) key;
}

jint jni_getTableSize(JNIEnv *env, jobject jobj, jlong L, jlong table) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
    jint size = (jint) lua_objlen(LS, -1);
    lua_pop(LS, 1);
    lua_unlock(LS);
    return size;
}

/// -----------------------------------------------------------------------------------------
/// -----------------------------------------------------------------------------------------
/// -----------------------------------------------------------------------------------------

#define setTableBefore(L, table, k) \
        lua_State *LS = (lua_State *) (L); \
        lua_lock(LS);\
        getValueFromGNV(LS, (ptrdiff_t) (table), LUA_TTABLE);\
        lua_pushinteger(LS, (lua_Integer) (k));

#define setTableAfter(LS) \
        lua_rawset(LS, -3);\
        lua_pop(LS, 1);\
        lua_unlock(LS);

void jni_setTableNumber(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jdouble n) {
    setTableBefore(L, table, k)

    lua_pushnumber(LS, (lua_Number) n);

    setTableAfter(LS)
}

void jni_setTableBoolean(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jboolean v) {
    setTableBefore(L, table, k)

    lua_pushboolean(LS, (int) v);

    setTableAfter(LS)
}

void jni_setTableString(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jstring v) {
    setTableBefore(L, table, k)

    const char *str = GetString(env, v);
    lua_pushstring(LS, str);
    ReleaseChar(env, v, str);

    setTableAfter(LS)
}

void jni_setTableNil(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k) {
    setTableBefore(L, table, k)

    lua_pushnil(LS);

    setTableAfter(LS)
}

void jni_setTableChild(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jobject child) {
    setTableBefore(L, table, k)

    pushUserdataFromJUD(env, LS, child);

    setTableAfter(LS)
}

void jni_setTableChildN(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jlong c, jint type) {
    setTableBefore(L, table, k);

    getValueFromGNV(LS, (ptrdiff_t) c, type);

    setTableAfter(LS)
}

/// -----------------------------------------------------------------------------------------
/// -----------------------------------------------------------------------------------------
/// -----------------------------------------------------------------------------------------

#define setTableS(env, L, table, k, fun) \
        lua_State *LS = (lua_State *) (L); \
        lua_lock(LS); \
        const char *key = GetString(env, (k)); \
        if (isGlobal(table)) { \
            {fun} \
            lua_setglobal(LS, key); \
        } else { \
            getValueFromGNV(LS, (ptrdiff_t) (table), LUA_TTABLE); \
            lua_pushstring(LS, key); \
            {fun} \
            lua_rawset(LS, -3); \
            lua_pop(LS, 1); \
        } \
        ReleaseChar(env, k, key); \
        lua_unlock(LS);

void jni_setTableSNumber(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jdouble v) {
    setTableS(env, L, table, k,
              lua_pushnumber(LS, (lua_Number) v);
    )
}

void
jni_setTableSBoolean(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jboolean v) {
    setTableS(env, L, table, k,
              lua_pushboolean(LS, (int) v);
    )
}

void jni_setTableSString(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jstring v) {
    const char *value = GetString(env, v);
    setTableS(env, L, table, k,
              lua_pushstring(LS, value);
    )
    ReleaseChar(env, v, value);
}

void jni_setTableSNil(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k) {
    setTableS(env, L, table, k,
              lua_pushnil(LS);
    )
}

void jni_setTableSChild(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jobject child) {
    setTableS(env, L, table, k,
              pushUserdataFromJUD(env, LS, child);
    )
}

void jni_setTableSChildN(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jlong c, jint type) {
    setTableS(env, L, table, k,
              getValueFromGNV(LS, (ptrdiff_t) c, type);
    )
}

jobject jni_getTableValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
    lua_pushinteger(LS, (lua_Integer) k);
    lua_rawget(LS, -2);
    lua_remove(LS, -2);
    jobject ret = toJavaValue(env, LS, -1);
    lua_pop(LS, 1);
    lua_unlock(LS);

    return ret;
}

jobject jni_getTableSValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k) {
    const char *key = GetString(env, k);
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    if (isGlobal(table)) {
        lua_getglobal(LS, key);
    } else {
        getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
        lua_pushstring(LS, key);
        lua_rawget(LS, -2);
        lua_remove(LS, -2);
    }
    ReleaseChar(env, k, key);
    jobject ret = toJavaValue(env, LS, -1);
    lua_pop(LS, 1);
    lua_unlock(LS);

    return ret;
}

jboolean jni_startTraverseTable(JNIEnv *env, jobject jobj, jlong L, jlong table) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int globalTable = isGlobal(table);
    if (globalTable)
        lua_pushglobaltable(LS);
    else
        getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
    if (lua_isnil(LS, -1)) {
        lua_pop(LS, 1);
        return (jboolean) 0;
    }
    lua_pushnil(LS);
    lua_unlock(LS);
    return (jboolean) 1;
}

static inline int isValidKeyForGlobal(lua_State *LS) {
    if (lua_isstring(LS, -2)) {
        const char *key = lua_tostring(LS, -2);
        if (!strcmp(key, GNV) || !strcmp(key, "load")) {
            lua_pop(LS, 1);
            return 0;
        }
    }
    return 1;
}

jobjectArray jni_nextEntry(JNIEnv *env, jobject jobj, jlong L, jboolean isGlobal) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    while (lua_next(LS, -2)) {         // xxx table
        if (isGlobal && !isValidKeyForGlobal(LS))
            continue;
        jobject key = toJavaValue(env, LS, -2);
        jobject value = toJavaValue(env, LS, -1);
        lua_pop(LS, 1);             // xxx table
        jobjectArray ret = (*env)->NewObjectArray(env, 2, LuaValue, NULL);
        (*env)->SetObjectArrayElement(env, ret, 0, key);
        (*env)->SetObjectArrayElement(env, ret, 1, value);
        FREE(env, key);
        FREE(env, value);
        lua_unlock(LS);
        return ret;
    }
    lua_pushnil(LS);// nil, table
    lua_unlock(LS);
    return NULL;
}

void jni_endTraverseTable(JNIEnv *env, jobject jobj, jlong L) {
    lua_pop((lua_State *) L, 2);
}

jobject jni_getTableEntry(JNIEnv *env, jobject jobj, jlong L, jlong table) {
    typedef struct JLink {
        jobject key;
        jobject value;
        struct JLink *next;
    } JLink;

    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int globalTable = isGlobal(table);
    if (globalTable)
        lua_pushglobaltable(LS);
    else
        getValueFromGNV(LS, (ptrdiff_t) table, LUA_TTABLE);
    lua_pushnil(LS);                            // nil table
    int num = 0;

    JLink *head = NULL;
    JLink *pre = NULL;
    JLink *node = NULL;
    while (lua_next(LS, -2))                    // value key table
    {
        if (globalTable && !isValidKeyForGlobal(LS))
            continue;

        jobject key = toJavaValue(env, LS, -2);
        jobject value = toJavaValue(env, LS, -1);
        lua_pop(LS, 1);

        node = (JLink *) m_malloc(NULL, 0, sizeof(JLink));
        node->key = key;
        node->value = value;

        if (num++ == 0) {
            head = node;
            pre = node;
        } else {
            pre->next = node;
            pre = node;
        }
    }
    lua_pop(LS, 1);
    lua_unlock(LS);

    jobjectArray keysarr = (*env)->NewObjectArray(env, (jsize) num, LuaValue, NULL);
    jobjectArray valuearr = (*env)->NewObjectArray(env, (jsize) num, LuaValue, NULL);
    int i;
    node = head;
    for (i = 0; i < num; i++) {
        (*env)->SetObjectArrayElement(env, keysarr, i, node->key);
        (*env)->SetObjectArrayElement(env, valuearr, i, node->value);
        pre = node;
        node = node->next;
        FREE(env, pre->key);
        FREE(env, pre->value);
        m_malloc(pre, sizeof(JLink), 0);
    }

    return (*env)->NewObject(env, Entrys, Entrys_C, keysarr, valuearr);
}

void copyTable(lua_State *L, int src, int desc) {
    lua_lock(L);
    src = src < 0 ? lua_gettop(L) + src + 1 : src;
    desc = desc < 0 ? lua_gettop(L) + desc + 1 : desc;
    lua_pushnil(L);
    while (lua_next(L, src)) {
        if (lua_isstring(L, -2)) {
            const char *key = lua_tostring(L, -2);
            if (key[0] == '_' && key[1] == '_') {
                lua_pop(L, 1);
                continue;
            }
        }
        lua_pushvalue(L, -2);
        lua_pushvalue(L, -2);
        lua_rawset(L, desc);
        lua_pop(L, 1);
    }
    lua_unlock(L);
}