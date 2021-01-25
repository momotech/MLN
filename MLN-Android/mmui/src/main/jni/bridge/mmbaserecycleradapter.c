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
#define LUA_CLASS_NAME "__BaseRecyclerAdapter"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID isShowPressedID;
static jmethodID setShowPressedID;
static int _showPressed(lua_State *L);
static jmethodID getPressedColorID;
static jmethodID setPressedColorID;
static int _pressedColor(lua_State *L);
static jmethodID reuseIdID;
static int _reuseId(lua_State *L);
static jmethodID initCellID;
static int _initCell(lua_State *L);
static jmethodID initCellByReuseIdID;
static int _initCellByReuseId(lua_State *L);
static jmethodID headerValidID;
static int _headerValid(lua_State *L);
static jmethodID initHeaderID;
static int _initHeader(lua_State *L);
static jmethodID fillHeaderDataID;
static int _fillHeaderData(lua_State *L);
static jmethodID fillCellDataID;
static int _fillCellData(lua_State *L);
static jmethodID fillCellDataByReuseIdID;
static int _fillCellDataByReuseId(lua_State *L);
static jmethodID sectionCountID;
static int _sectionCount(lua_State *L);
static jmethodID rowCountID;
static int _rowCount(lua_State *L);
static jmethodID selectedRowID;
static int _selectedRow(lua_State *L);
static jmethodID longPressRowID;
static int _longPressRow(lua_State *L);
static jmethodID selectedRowByReuseIdID;
static int _selectedRowByReuseId(lua_State *L);
static jmethodID longPressRowByReuseIdID;
static int _longPressRowByReuseId(lua_State *L);
static jmethodID editActionID;
static int _editAction(lua_State *L);
static jmethodID editParamID;
static int _editParam(lua_State *L);
static jmethodID cellDidDisappearID;
static int _cellDidDisappear(lua_State *L);
static jmethodID cellDidDisappearByReuseIdID;
static int _cellDidDisappearByReuseId(lua_State *L);
static jmethodID cellWillAppearID;
static int _cellWillAppear(lua_State *L);
static jmethodID cellWillAppearByReuseIdID;
static int _cellWillAppearByReuseId(lua_State *L);
static jmethodID headerDidDisappearID;
static int _headerDidDisappear(lua_State *L);
static jmethodID headerWillAppearID;
static int _headerWillAppear(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"showPressed", _showPressed},
            {"pressedColor", _pressedColor},
            {"reuseId", _reuseId},
            {"initCell", _initCell},
            {"initCellByReuseId", _initCellByReuseId},
            {"headerValid", _headerValid},
            {"initHeader", _initHeader},
            {"fillHeaderData", _fillHeaderData},
            {"fillCellData", _fillCellData},
            {"fillCellDataByReuseId", _fillCellDataByReuseId},
            {"sectionCount", _sectionCount},
            {"rowCount", _rowCount},
            {"selectedRow", _selectedRow},
            {"longPressRow", _longPressRow},
            {"selectedRowByReuseId", _selectedRowByReuseId},
            {"longPressRowByReuseId", _longPressRowByReuseId},
            {"editAction", _editAction},
            {"editParam", _editParam},
            {"cellDidDisappear", _cellDidDisappear},
            {"cellDidDisappearByReuseId", _cellDidDisappearByReuseId},
            {"cellWillAppear", _cellWillAppear},
            {"cellWillAppearByReuseId", _cellWillAppearByReuseId},
            {"headerDidDisappear", _headerDidDisappear},
            {"headerWillAppear", _headerWillAppear},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_recycler_UDBaseRecyclerAdapter_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    isShowPressedID = (*env)->GetMethodID(env, clz, "isShowPressed", "()Z");
    setShowPressedID = (*env)->GetMethodID(env, clz, "setShowPressed", "(Z)V");
    getPressedColorID = (*env)->GetMethodID(env, clz, "getPressedColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setPressedColorID = (*env)->GetMethodID(env, clz, "setPressedColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    reuseIdID = (*env)->GetMethodID(env, clz, "reuseId", "(J)V");
    initCellID = (*env)->GetMethodID(env, clz, "initCell", "(Lorg/luaj/vm2/LuaFunction;)V");
    initCellByReuseIdID = (*env)->GetMethodID(env, clz, "initCellByReuseId", "(Ljava/lang/String;Lorg/luaj/vm2/LuaFunction;)V");
    headerValidID = (*env)->GetMethodID(env, clz, "headerValid", "(J)V");
    initHeaderID = (*env)->GetMethodID(env, clz, "initHeader", "(Lorg/luaj/vm2/LuaFunction;)V");
    fillHeaderDataID = (*env)->GetMethodID(env, clz, "fillHeaderData", "(J)V");
    fillCellDataID = (*env)->GetMethodID(env, clz, "fillCellData", "(J)V");
    fillCellDataByReuseIdID = (*env)->GetMethodID(env, clz, "fillCellDataByReuseId", "(Ljava/lang/String;J)V");
    sectionCountID = (*env)->GetMethodID(env, clz, "sectionCount", "(J)V");
    rowCountID = (*env)->GetMethodID(env, clz, "rowCount", "(J)V");
    selectedRowID = (*env)->GetMethodID(env, clz, "selectedRow", "(J)V");
    longPressRowID = (*env)->GetMethodID(env, clz, "longPressRow", "(J)V");
    selectedRowByReuseIdID = (*env)->GetMethodID(env, clz, "selectedRowByReuseId", "(Ljava/lang/String;J)V");
    longPressRowByReuseIdID = (*env)->GetMethodID(env, clz, "longPressRowByReuseId", "(Ljava/lang/String;J)V");
    editActionID = (*env)->GetMethodID(env, clz, "editAction", "()V");
    editParamID = (*env)->GetMethodID(env, clz, "editParam", "()V");
    cellDidDisappearID = (*env)->GetMethodID(env, clz, "cellDidDisappear", "(J)V");
    cellDidDisappearByReuseIdID = (*env)->GetMethodID(env, clz, "cellDidDisappearByReuseId", "(Ljava/lang/String;J)V");
    cellWillAppearID = (*env)->GetMethodID(env, clz, "cellWillAppear", "(J)V");
    cellWillAppearByReuseIdID = (*env)->GetMethodID(env, clz, "cellWillAppearByReuseId", "(Ljava/lang/String;J)V");
    headerDidDisappearID = (*env)->GetMethodID(env, clz, "headerDidDisappear", "(Lorg/luaj/vm2/LuaFunction;)V");
    headerWillAppearID = (*env)->GetMethodID(env, clz, "headerWillAppear", "(Lorg/luaj/vm2/LuaFunction;)V");
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
 * boolean isShowPressed()
 * void setShowPressed(boolean)
 */
static int _showPressed(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isShowPressedID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isShowPressed")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isShowPressed", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setShowPressedID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShowPressed")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShowPressed", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getPressedColor()
 * void setPressedColor(com.immomo.mmui.ud.UDColor)
 */
static int _pressedColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getPressedColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPressedColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPressedColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setPressedColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPressedColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPressedColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void reuseId(long)
 */
static int _reuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, reuseIdID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".reuseId")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "reuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void initCell(org.luaj.vm2.LuaFunction)
 */
static int _initCell(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, initCellID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".initCell")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "initCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void initCellByReuseId(java.lang.String,org.luaj.vm2.LuaFunction)
 */
static int _initCellByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallVoidMethod(env, jobj, initCellByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".initCellByReuseId")) {
        FREE(env, p1);
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "initCellByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void headerValid(long)
 */
static int _headerValid(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, headerValidID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".headerValid")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "headerValid", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void initHeader(org.luaj.vm2.LuaFunction)
 */
static int _initHeader(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, initHeaderID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".initHeader")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "initHeader", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void fillHeaderData(long)
 */
static int _fillHeaderData(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, fillHeaderDataID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".fillHeaderData")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "fillHeaderData", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void fillCellData(long)
 */
static int _fillCellData(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, fillCellDataID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".fillCellData")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "fillCellData", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void fillCellDataByReuseId(java.lang.String,long)
 */
static int _fillCellDataByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p2 = (jlong) copyValueToGNV(L, 3);
    (*env)->CallVoidMethod(env, jobj, fillCellDataByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".fillCellDataByReuseId")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "fillCellDataByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void sectionCount(long)
 */
static int _sectionCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, sectionCountID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".sectionCount")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "sectionCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void rowCount(long)
 */
static int _rowCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, rowCountID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".rowCount")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "rowCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void selectedRow(long)
 */
static int _selectedRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, selectedRowID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".selectedRow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "selectedRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void longPressRow(long)
 */
static int _longPressRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, longPressRowID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".longPressRow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "longPressRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void selectedRowByReuseId(java.lang.String,long)
 */
static int _selectedRowByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p2 = (jlong) copyValueToGNV(L, 3);
    (*env)->CallVoidMethod(env, jobj, selectedRowByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".selectedRowByReuseId")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "selectedRowByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void longPressRowByReuseId(java.lang.String,long)
 */
static int _longPressRowByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p2 = (jlong) copyValueToGNV(L, 3);
    (*env)->CallVoidMethod(env, jobj, longPressRowByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".longPressRowByReuseId")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "longPressRowByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void editAction()
 */
static int _editAction(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, editActionID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".editAction")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "editAction", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void editParam()
 */
static int _editParam(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, editParamID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".editParam")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "editParam", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cellDidDisappear(long)
 */
static int _cellDidDisappear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, cellDidDisappearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cellDidDisappear")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cellDidDisappear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cellDidDisappearByReuseId(java.lang.String,long)
 */
static int _cellDidDisappearByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p2 = (jlong) copyValueToGNV(L, 3);
    (*env)->CallVoidMethod(env, jobj, cellDidDisappearByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cellDidDisappearByReuseId")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cellDidDisappearByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cellWillAppear(long)
 */
static int _cellWillAppear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, cellWillAppearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cellWillAppear")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cellWillAppear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cellWillAppearByReuseId(java.lang.String,long)
 */
static int _cellWillAppearByReuseId(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p2 = (jlong) copyValueToGNV(L, 3);
    (*env)->CallVoidMethod(env, jobj, cellWillAppearByReuseIdID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cellWillAppearByReuseId")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cellWillAppearByReuseId", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void headerDidDisappear(org.luaj.vm2.LuaFunction)
 */
static int _headerDidDisappear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, headerDidDisappearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".headerDidDisappear")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "headerDidDisappear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void headerWillAppear(org.luaj.vm2.LuaFunction)
 */
static int _headerWillAppear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, headerWillAppearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".headerWillAppear")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "headerWillAppear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
