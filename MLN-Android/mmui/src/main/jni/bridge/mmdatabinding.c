/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Generator on 2020-07-20
//

#include <jni.h>
#include "cache.h"
#include "lauxlib.h"
#include "jinfo.h"

#define PRE JNIEnv *env;                                                        \
            getEnv(&env);                                                       \
            if (!lua_istable(L, 1)) {                                           \
                lua_pushstring(L, "use ':' instead of '.' to call method!!");   \
                return lua_error(L);                                            \
            }


#define LUA_CLASS_NAME "DataBinding"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID watchID;
static int _watch(lua_State *L);
static jmethodID updateID;
static int _update(lua_State *L);
static jmethodID getID;
static int _get(lua_State *L);
static jmethodID insertID;
static int _insert(lua_State *L);
static jmethodID removeID;
static int _remove(lua_State *L);
static jmethodID bindListViewID;
static int _bindListView(lua_State *L);
static jmethodID getSectionCountID;
static int _getSectionCount(lua_State *L);
static jmethodID getRowCountID;
static int _getRowCount(lua_State *L);
static jmethodID bindCellID;
static int _bindCell(lua_State *L);
static jmethodID mockID;
static int _mock(lua_State *L);
static jmethodID mockArrayID;
static int _mockArray(lua_State *L);
static jmethodID arraySizeID;
static int _arraySize(lua_State *L);
static jmethodID removeObserverID;
static int _removeObserver(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"watch", _watch},
            {"update", _update},
            {"get", _get},
            {"insert", _insert},
            {"remove", _remove},
            {"bindListView", _bindListView},
            {"getSectionCount", _getSectionCount},
            {"getRowCount", _getRowCount},
            {"bindCell", _bindCell},
            {"mock", _mock},
            {"mockArray", _mockArray},
            {"arraySize", _arraySize},
            {"removeObserver", _removeObserver},
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
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL Java_com_immomo_mmui_databinding_LTCDataBinding__1init
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    watchID = (*env)->GetStaticMethodID(env, clz, "watch", "(JLjava/lang/String;J)Ljava/lang/String;");
    updateID = (*env)->GetStaticMethodID(env, clz, "update", "(JLjava/lang/String;Lorg/luaj/vm2/LuaValue;)V");
    getID = (*env)->GetStaticMethodID(env, clz, "get", "(JLjava/lang/String;)Lorg/luaj/vm2/LuaValue;");
    insertID = (*env)->GetStaticMethodID(env, clz, "insert", "(JLjava/lang/String;ILorg/luaj/vm2/LuaValue;)V");
    removeID = (*env)->GetStaticMethodID(env, clz, "remove", "(JLjava/lang/String;I)V");
    bindListViewID = (*env)->GetStaticMethodID(env, clz, "bindListView", "(JLjava/lang/String;Lcom/immomo/mmui/ud/UDView;)V");
    getSectionCountID = (*env)->GetStaticMethodID(env, clz, "getSectionCount", "(JLjava/lang/String;)I");
    getRowCountID = (*env)->GetStaticMethodID(env, clz, "getRowCount", "(JLjava/lang/String;I)I");
    bindCellID = (*env)->GetStaticMethodID(env, clz, "bindCell", "(JLjava/lang/String;IILorg/luaj/vm2/LuaTable;)V");
    mockID = (*env)->GetStaticMethodID(env, clz, "mock", "(JLjava/lang/String;Lorg/luaj/vm2/LuaTable;)V");
    mockArrayID = (*env)->GetStaticMethodID(env, clz, "mockArray", "(JLjava/lang/String;Lorg/luaj/vm2/LuaTable;Lorg/luaj/vm2/LuaTable;)V");
    arraySizeID = (*env)->GetStaticMethodID(env, clz, "arraySize", "(JLjava/lang/String;)I");
    removeObserverID = (*env)->GetStaticMethodID(env, clz, "removeObserver", "(JLjava/lang/String;)V");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 */
JNIEXPORT void JNICALL Java_com_immomo_mmui_databinding_LTCDataBinding__1register
        (JNIEnv *env, jclass o, jlong l) {
    lua_State *L = (lua_State *)l;

    lua_createtable(L, 0, 0);
    fillUDMetatable(L);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * java.lang.String static watch(long,java.lang.String,long)
 */
static int _watch(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jlong p2 = lua_isfunction(L, 3) ? (jlong) copyValueToGNV(L, 3) : 0;
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, watchID, (jlong) L, p1, p2);
    pushJavaString(env, L, ret);
    return 1;
}
/**
 * void static update(long,java.lang.String,org.luaj.vm2.LuaValue)
 */
static int _update(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, updateID, (jlong) L, p1, p2);
    lua_settop(L, 1);
    return 1;
}
/**
 * org.luaj.vm2.LuaValue static get(long,java.lang.String)
 */
static int _get(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, getID, (jlong) L, p1);
    pushJavaValue(env, L, ret);
    return 1;
}
/**
 * void static insert(long,java.lang.String,int,org.luaj.vm2.LuaValue)
 */
static int _insert(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p2 = luaL_checkinteger(L, 3);
    jobject p3 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallStaticVoidMethod(env, _globalClass, insertID, (jlong) L, p1, (jint)p2, p3);
    lua_settop(L, 1);
    return 1;
}
/**
 * void static remove(long,java.lang.String,int)
 */
static int _remove(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, removeID, (jlong) L, p1, (jint)p2);
    lua_settop(L, 1);
    return 1;
}
/**
 * void static bindListView(long,java.lang.String,com.immomo.mmui.ud.UDView)
 */
static int _bindListView(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, bindListViewID, (jlong) L, p1, p2);
    lua_settop(L, 1);
    return 1;
}
/**
 * int static getSectionCount(long,java.lang.String)
 */
static int _getSectionCount(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, getSectionCountID, (jlong) L, p1);
    lua_pushinteger(L, (lua_Integer) ret);
    return 1;
}
/**
 * int static getRowCount(long,java.lang.String,int)
 */
static int _getRowCount(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p2 = luaL_checkinteger(L, 3);
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, getRowCountID, (jlong) L, p1, (jint)p2);
    lua_pushinteger(L, (lua_Integer) ret);
    return 1;
}
/**
 * void static bindCell(long,java.lang.String,int,int,org.luaj.vm2.LuaTable)
 */
static int _bindCell(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    jobject p4 = lua_isnil(L, 5) ? NULL : toJavaValue(env, L, 5);
    (*env)->CallStaticVoidMethod(env, _globalClass, bindCellID, (jlong) L, p1, (jint)p2, (jint)p3, p4);
    lua_settop(L, 1);
    return 1;
}
/**
 * void static mock(long,java.lang.String,org.luaj.vm2.LuaTable)
 */
static int _mock(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, mockID, (jlong) L, p1, p2);
    lua_settop(L, 1);
    return 1;
}
/**
 * void static mockArray(long,java.lang.String,org.luaj.vm2.LuaTable,org.luaj.vm2.LuaTable)
 */
static int _mockArray(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    jobject p3 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallStaticVoidMethod(env, _globalClass, mockArrayID, (jlong) L, p1, p2, p3);
    lua_settop(L, 1);
    return 1;
}
/**
 * int static arraySize(long,java.lang.String)
 */
static int _arraySize(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, arraySizeID, (jlong) L, p1);
    lua_pushinteger(L, (lua_Integer) ret);
    return 1;
}
/**
 * void static removeObserver(long,java.lang.String)
 */
static int _removeObserver(lua_State *L) {
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallStaticVoidMethod(env, _globalClass, removeObserverID, (jlong) L, p1);
    lua_settop(L, 1);
    return 1;
}
//</editor-fold>
