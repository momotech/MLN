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
#define LUA_CLASS_NAME "_C_UDRecyclerView"
#define LUA_CLASS_NAME0 "CollectionView"
#define LUA_CLASS_NAME1 "TableView"
#define LUA_CLASS_NAME2 "WaterfallView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
static jmethodID _constructor2;
static jmethodID _constructor3;
//<editor-fold desc="method definition">
static jmethodID isRefreshEnableID;
static jmethodID setRefreshEnableID;
static int _refreshEnable(lua_State *L);
static jmethodID isLoadEnableID;
static jmethodID setLoadEnableID;
static int _loadEnable(lua_State *L);
static jmethodID getScrollDirectionID;
static jmethodID setScrollDirectionID;
static int _scrollDirection(lua_State *L);
static jmethodID getLoadThresholdID;
static jmethodID setLoadThresholdID;
static int _loadThreshold(lua_State *L);
static jmethodID isOpenReuseCellID;
static jmethodID setOpenReuseCellID;
static int _openReuseCell(lua_State *L);
static jmethodID getContentOffsetID;
static jmethodID setContentOffsetID;
static int _contentOffset(lua_State *L);
static jmethodID i_bouncesID;
static int _i_bounces(lua_State *L);
static jmethodID i_pagingEnabledID;
static int _i_pagingEnabled(lua_State *L);
static jmethodID isShowScrollIndicatorID;
static jmethodID setShowScrollIndicatorID;
static int _showScrollIndicator(lua_State *L);
static jmethodID getPagerContentOffsetID;
static jmethodID setPagerContentOffsetID;
static int _pagerContentOffset(lua_State *L);
static jmethodID setOffsetWithAnimID;
static int _setOffsetWithAnim(lua_State *L);
static jmethodID reloadDataID;
static int _reloadData(lua_State *L);
static jmethodID setScrollEnableID;
static int _setScrollEnable(lua_State *L);
static jmethodID reloadAtRowID;
static int _reloadAtRow(lua_State *L);
static jmethodID reloadAtSectionID;
static int _reloadAtSection(lua_State *L);
static jmethodID scrollToTop0ID;
static jmethodID scrollToTop1ID;
static int _scrollToTop(lua_State *L);
static jmethodID scrollToCell0ID;
static jmethodID scrollToCell1ID;
static int _scrollToCell(lua_State *L);
static jmethodID insertCellAtRowID;
static int _insertCellAtRow(lua_State *L);
static jmethodID insertRow0ID;
static jmethodID insertRow1ID;
static int _insertRow(lua_State *L);
static jmethodID deleteCellAtRowID;
static int _deleteCellAtRow(lua_State *L);
static jmethodID deleteRow0ID;
static jmethodID deleteRow1ID;
static int _deleteRow(lua_State *L);
static jmethodID isRefreshingID;
static int _isRefreshing(lua_State *L);
static jmethodID startRefreshingID;
static int _startRefreshing(lua_State *L);
static jmethodID stopRefreshingID;
static int _stopRefreshing(lua_State *L);
static jmethodID isLoadingID;
static int _isLoading(lua_State *L);
static jmethodID stopLoadingID;
static int _stopLoading(lua_State *L);
static jmethodID noMoreDataID;
static int _noMoreData(lua_State *L);
static jmethodID resetLoadingID;
static int _resetLoading(lua_State *L);
static jmethodID loadErrorID;
static int _loadError(lua_State *L);
static jmethodID getAdapterID;
static jmethodID setAdapterID;
static int _adapter(lua_State *L);
static jmethodID setLayoutID;
static jmethodID getLayoutID;
static int _layout(lua_State *L);
static jmethodID setRefreshingCallbackID;
static int _setRefreshingCallback(lua_State *L);
static jmethodID setLoadingCallbackID;
static int _setLoadingCallback(lua_State *L);
static jmethodID setScrollingCallbackID;
static int _setScrollingCallback(lua_State *L);
static jmethodID setScrollBeginCallbackID;
static int _setScrollBeginCallback(lua_State *L);
static jmethodID setScrollEndCallbackID;
static int _setScrollEndCallback(lua_State *L);
static jmethodID setEndDraggingCallbackID;
static int _setEndDraggingCallback(lua_State *L);
static jmethodID setScrollWillEndDraggingCallbackID;
static int _setScrollWillEndDraggingCallback(lua_State *L);
static jmethodID setStartDeceleratingCallbackID;
static int _setStartDeceleratingCallback(lua_State *L);
static jmethodID insertCellsAtSectionID;
static int _insertCellsAtSection(lua_State *L);
static jmethodID insertRowsAtSectionID;
static int _insertRowsAtSection(lua_State *L);
static jmethodID deleteRowsAtSectionID;
static int _deleteRowsAtSection(lua_State *L);
static jmethodID deleteCellsAtSectionID;
static int _deleteCellsAtSection(lua_State *L);
static jmethodID setContentInsetID;
static int _setContentInset(lua_State *L);
static jmethodID getContentInsetByFunctionID;
static int _getContentInset(lua_State *L);
static jmethodID useAllSpanForLoadingID;
static int _useAllSpanForLoading(lua_State *L);
static jmethodID getRecycledViewNumID;
static int _getRecycledViewNum(lua_State *L);
static jmethodID isStartPositionID;
static int _isStartPosition(lua_State *L);
static jmethodID cellWithSectionRowID;
static int _cellWithSectionRow(lua_State *L);
static jmethodID visibleCellsID;
static int _visibleCells(lua_State *L);
static jmethodID isDisallowFlingID;
static jmethodID setDisallowFlingID;
static int _disallowFling(lua_State *L);
static jmethodID visibleCellsRowsID;
static int _visibleCellsRows(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"refreshEnable", _refreshEnable},
            {"loadEnable", _loadEnable},
            {"scrollDirection", _scrollDirection},
            {"loadThreshold", _loadThreshold},
            {"openReuseCell", _openReuseCell},
            {"contentOffset", _contentOffset},
            {"i_bounces", _i_bounces},
            {"i_pagingEnabled", _i_pagingEnabled},
            {"showScrollIndicator", _showScrollIndicator},
            {"pagerContentOffset", _pagerContentOffset},
            {"setOffsetWithAnim", _setOffsetWithAnim},
            {"reloadData", _reloadData},
            {"setScrollEnable", _setScrollEnable},
            {"reloadAtRow", _reloadAtRow},
            {"reloadAtSection", _reloadAtSection},
            {"scrollToTop", _scrollToTop},
            {"scrollToCell", _scrollToCell},
            {"insertCellAtRow", _insertCellAtRow},
            {"insertRow", _insertRow},
            {"deleteCellAtRow", _deleteCellAtRow},
            {"deleteRow", _deleteRow},
            {"isRefreshing", _isRefreshing},
            {"startRefreshing", _startRefreshing},
            {"stopRefreshing", _stopRefreshing},
            {"isLoading", _isLoading},
            {"stopLoading", _stopLoading},
            {"noMoreData", _noMoreData},
            {"resetLoading", _resetLoading},
            {"loadError", _loadError},
            {"adapter", _adapter},
            {"layout", _layout},
            {"setRefreshingCallback", _setRefreshingCallback},
            {"setLoadingCallback", _setLoadingCallback},
            {"setScrollingCallback", _setScrollingCallback},
            {"setScrollBeginCallback", _setScrollBeginCallback},
            {"setScrollEndCallback", _setScrollEndCallback},
            {"setEndDraggingCallback", _setEndDraggingCallback},
            {"setScrollWillEndDraggingCallback", _setScrollWillEndDraggingCallback},
            {"setStartDeceleratingCallback", _setStartDeceleratingCallback},
            {"insertCellsAtSection", _insertCellsAtSection},
            {"insertRowsAtSection", _insertRowsAtSection},
            {"deleteRowsAtSection", _deleteRowsAtSection},
            {"deleteCellsAtSection", _deleteCellsAtSection},
            {"setContentInset", _setContentInset},
            {"getContentInset", _getContentInset},
            {"useAllSpanForLoading", _useAllSpanForLoading},
            {"getRecycledViewNum", _getRecycledViewNum},
            {"isStartPosition", _isStartPosition},
            {"cellWithSectionRow", _cellWithSectionRow},
            {"visibleCells", _visibleCells},
            {"disallowFling", _disallowFling},
            {"visibleCellsRows", _visibleCellsRows},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_recycler_UDRecyclerView_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZZZ)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZZ)V");
    _constructor2 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZ)V");
    _constructor3 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    isRefreshEnableID = (*env)->GetMethodID(env, clz, "isRefreshEnable", "()Z");
    setRefreshEnableID = (*env)->GetMethodID(env, clz, "setRefreshEnable", "(Z)V");
    isLoadEnableID = (*env)->GetMethodID(env, clz, "isLoadEnable", "()Z");
    setLoadEnableID = (*env)->GetMethodID(env, clz, "setLoadEnable", "(Z)V");
    getScrollDirectionID = (*env)->GetMethodID(env, clz, "getScrollDirection", "()I");
    setScrollDirectionID = (*env)->GetMethodID(env, clz, "setScrollDirection", "(I)V");
    getLoadThresholdID = (*env)->GetMethodID(env, clz, "getLoadThreshold", "()F");
    setLoadThresholdID = (*env)->GetMethodID(env, clz, "setLoadThreshold", "(F)V");
    isOpenReuseCellID = (*env)->GetMethodID(env, clz, "isOpenReuseCell", "()Z");
    setOpenReuseCellID = (*env)->GetMethodID(env, clz, "setOpenReuseCell", "(Z)V");
    getContentOffsetID = (*env)->GetMethodID(env, clz, "getContentOffset", "()Lcom/immomo/mls/fun/ud/UDPoint;");
    setContentOffsetID = (*env)->GetMethodID(env, clz, "setContentOffset", "(Lcom/immomo/mls/fun/ud/UDPoint;)V");
    i_bouncesID = (*env)->GetMethodID(env, clz, "i_bounces", "()V");
    i_pagingEnabledID = (*env)->GetMethodID(env, clz, "i_pagingEnabled", "()V");
    isShowScrollIndicatorID = (*env)->GetMethodID(env, clz, "isShowScrollIndicator", "()Z");
    setShowScrollIndicatorID = (*env)->GetMethodID(env, clz, "setShowScrollIndicator", "(Z)V");
    getPagerContentOffsetID = (*env)->GetMethodID(env, clz, "getPagerContentOffset", "()[F");
    setPagerContentOffsetID = (*env)->GetMethodID(env, clz, "setPagerContentOffset", "(FF)V");
    setOffsetWithAnimID = (*env)->GetMethodID(env, clz, "setOffsetWithAnim", "(Lcom/immomo/mls/fun/ud/UDPoint;)V");
    reloadDataID = (*env)->GetMethodID(env, clz, "reloadData", "()V");
    setScrollEnableID = (*env)->GetMethodID(env, clz, "setScrollEnable", "(Z)V");
    reloadAtRowID = (*env)->GetMethodID(env, clz, "reloadAtRow", "(IIZ)V");
    reloadAtSectionID = (*env)->GetMethodID(env, clz, "reloadAtSection", "(IZ)V");
    scrollToTop0ID = (*env)->GetMethodID(env, clz, "scrollToTop", "()V");
    scrollToTop1ID = (*env)->GetMethodID(env, clz, "scrollToTop", "(Z)V");
    scrollToCell0ID = (*env)->GetMethodID(env, clz, "scrollToCell", "(II)V");
    scrollToCell1ID = (*env)->GetMethodID(env, clz, "scrollToCell", "(IIZ)V");
    insertCellAtRowID = (*env)->GetMethodID(env, clz, "insertCellAtRow", "(II)V");
    insertRow0ID = (*env)->GetMethodID(env, clz, "insertRow", "(II)V");
    insertRow1ID = (*env)->GetMethodID(env, clz, "insertRow", "(IIZ)V");
    deleteCellAtRowID = (*env)->GetMethodID(env, clz, "deleteCellAtRow", "(II)V");
    deleteRow0ID = (*env)->GetMethodID(env, clz, "deleteRow", "(II)V");
    deleteRow1ID = (*env)->GetMethodID(env, clz, "deleteRow", "(IIZ)V");
    isRefreshingID = (*env)->GetMethodID(env, clz, "isRefreshing", "()Z");
    startRefreshingID = (*env)->GetMethodID(env, clz, "startRefreshing", "()V");
    stopRefreshingID = (*env)->GetMethodID(env, clz, "stopRefreshing", "()V");
    isLoadingID = (*env)->GetMethodID(env, clz, "isLoading", "()Z");
    stopLoadingID = (*env)->GetMethodID(env, clz, "stopLoading", "()V");
    noMoreDataID = (*env)->GetMethodID(env, clz, "noMoreData", "()V");
    resetLoadingID = (*env)->GetMethodID(env, clz, "resetLoading", "()V");
    loadErrorID = (*env)->GetMethodID(env, clz, "loadError", "()V");
    getAdapterID = (*env)->GetMethodID(env, clz, "getAdapter", "()Lcom/immomo/mmui/ud/recycler/UDBaseRecyclerAdapter;");
    setAdapterID = (*env)->GetMethodID(env, clz, "setAdapter", "(Lcom/immomo/mmui/ud/recycler/UDBaseRecyclerAdapter;)V");
    setLayoutID = (*env)->GetMethodID(env, clz, "setLayout", "(Lcom/immomo/mmui/ud/recycler/UDBaseRecyclerLayout;)V");
    getLayoutID = (*env)->GetMethodID(env, clz, "getLayout", "()Lcom/immomo/mmui/ud/recycler/UDBaseRecyclerLayout;");
    setRefreshingCallbackID = (*env)->GetMethodID(env, clz, "setRefreshingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setLoadingCallbackID = (*env)->GetMethodID(env, clz, "setLoadingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollingCallbackID = (*env)->GetMethodID(env, clz, "setScrollingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollBeginCallbackID = (*env)->GetMethodID(env, clz, "setScrollBeginCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollEndCallbackID = (*env)->GetMethodID(env, clz, "setScrollEndCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setEndDraggingCallbackID = (*env)->GetMethodID(env, clz, "setEndDraggingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollWillEndDraggingCallbackID = (*env)->GetMethodID(env, clz, "setScrollWillEndDraggingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setStartDeceleratingCallbackID = (*env)->GetMethodID(env, clz, "setStartDeceleratingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    insertCellsAtSectionID = (*env)->GetMethodID(env, clz, "insertCellsAtSection", "(III)V");
    insertRowsAtSectionID = (*env)->GetMethodID(env, clz, "insertRowsAtSection", "(IIIZ)V");
    deleteRowsAtSectionID = (*env)->GetMethodID(env, clz, "deleteRowsAtSection", "(IIIZ)V");
    deleteCellsAtSectionID = (*env)->GetMethodID(env, clz, "deleteCellsAtSection", "(III)V");
    setContentInsetID = (*env)->GetMethodID(env, clz, "setContentInset", "(FFFF)V");
    getContentInsetByFunctionID = (*env)->GetMethodID(env, clz, "getContentInsetByFunction", "(J)V");
    useAllSpanForLoadingID = (*env)->GetMethodID(env, clz, "useAllSpanForLoading", "(Z)V");
    getRecycledViewNumID = (*env)->GetMethodID(env, clz, "getRecycledViewNum", "()I");
    isStartPositionID = (*env)->GetMethodID(env, clz, "isStartPosition", "()Z");
    cellWithSectionRowID = (*env)->GetMethodID(env, clz, "cellWithSectionRow", "(II)J");
    visibleCellsID = (*env)->GetMethodID(env, clz, "visibleCells", "()Lcom/immomo/mls/fun/ud/UDArray;");
    isDisallowFlingID = (*env)->GetMethodID(env, clz, "isDisallowFling", "()Z");
    setDisallowFlingID = (*env)->GetMethodID(env, clz, "setDisallowFling", "(Z)V");
    visibleCellsRowsID = (*env)->GetMethodID(env, clz, "visibleCellsRows", "()J");
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
    lua_setglobal(L, LUA_CLASS_NAME0);
    lua_pushcfunction(L, _execute_new_ud);
    lua_setglobal(L, LUA_CLASS_NAME1);
    lua_pushcfunction(L, _execute_new_ud);
    lua_setglobal(L, LUA_CLASS_NAME2);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * boolean isRefreshEnable()
 * void setRefreshEnable(boolean)
 */
static int _refreshEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isRefreshEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isRefreshEnable")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isRefreshEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setRefreshEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRefreshEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRefreshEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isLoadEnable()
 * void setLoadEnable(boolean)
 */
static int _loadEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isLoadEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isLoadEnable")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isLoadEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setLoadEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLoadEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLoadEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getScrollDirection()
 * void setScrollDirection(int)
 */
static int _scrollDirection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getScrollDirectionID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getScrollDirection")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getScrollDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollDirectionID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollDirection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getLoadThreshold()
 * void setLoadThreshold(float)
 */
static int _loadThreshold(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getLoadThresholdID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getLoadThreshold")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getLoadThreshold", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setLoadThresholdID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLoadThreshold")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLoadThreshold", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isOpenReuseCell()
 * void setOpenReuseCell(boolean)
 */
static int _openReuseCell(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isOpenReuseCellID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isOpenReuseCell")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isOpenReuseCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setOpenReuseCellID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setOpenReuseCell")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setOpenReuseCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDPoint getContentOffset()
 * void setContentOffset(com.immomo.mls.fun.ud.UDPoint)
 */
static int _contentOffset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getContentOffsetID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentOffset")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setContentOffsetID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentOffset")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_bounces()
 */
static int _i_bounces(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_bouncesID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_bounces")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_bounces", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_pagingEnabled()
 */
static int _i_pagingEnabled(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_pagingEnabledID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_pagingEnabled")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_pagingEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isShowScrollIndicator()
 * void setShowScrollIndicator(boolean)
 */
static int _showScrollIndicator(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isShowScrollIndicatorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isShowScrollIndicator")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isShowScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setShowScrollIndicatorID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShowScrollIndicator")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShowScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float[] getPagerContentOffset()
 * void setPagerContentOffset(float,float)
 */
static int _pagerContentOffset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloatArray ret = (*env)->CallObjectMethod(env, jobj, getPagerContentOffsetID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPagerContentOffset")) {
            return lua_error(L);
        }
        int size = (*env)->GetArrayLength(env, ret);
        float *arr = (*env)->GetFloatArrayElements(env, ret, 0);
        int i;
        for (i = 0; i < size; ++i) {
            push_number(L, (jdouble)arr[i]);
        }
        (*env)->ReleaseFloatArrayElements(env, ret, arr, 0);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPagerContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return size;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, setPagerContentOffsetID, (jfloat)p1, (jfloat)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPagerContentOffset")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPagerContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setOffsetWithAnim(com.immomo.mls.fun.ud.UDPoint)
 */
static int _setOffsetWithAnim(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setOffsetWithAnimID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setOffsetWithAnim")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setOffsetWithAnim", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void reloadData()
 */
static int _reloadData(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, reloadDataID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".reloadData")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "reloadData", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollEnable(boolean)
 */
static int _setScrollEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void reloadAtRow(int,int,boolean)
 */
static int _reloadAtRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    int p3 = lua_toboolean(L, 4);
    (*env)->CallVoidMethod(env, jobj, reloadAtRowID, (jint)p1, (jint)p2, (jboolean)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".reloadAtRow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "reloadAtRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void reloadAtSection(int,boolean)
 */
static int _reloadAtSection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    int p2 = lua_toboolean(L, 3);
    (*env)->CallVoidMethod(env, jobj, reloadAtSectionID, (jint)p1, (jboolean)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".reloadAtSection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "reloadAtSection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void scrollToTop()
 * void scrollToTop(boolean)
 */
static int _scrollToTop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 2) {
        if (lua_isboolean(L, 2)) {
            int p1 = lua_toboolean(L, 2);
            (*env)->CallVoidMethod(env, jobj, scrollToTop1ID, (jboolean)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".scrollToTop")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scrollToTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".scrollToTop函数1个参数有: (boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 1) {
        (*env)->CallVoidMethod(env, jobj, scrollToTop0ID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".scrollToTop")) {
            return lua_error(L);
        }
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scrollToTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void scrollToCell(int,int)
 * void scrollToCell(int,int,boolean)
 */
static int _scrollToCell(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_isboolean(L, 4)) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            int p3 = lua_toboolean(L, 4);
            (*env)->CallVoidMethod(env, jobj, scrollToCell1ID, (jint)p1, (jint)p2, (jboolean)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".scrollToCell")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scrollToCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".scrollToCell函数3个参数有: (int,int,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            (*env)->CallVoidMethod(env, jobj, scrollToCell0ID, (jint)p1, (jint)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".scrollToCell")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scrollToCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".scrollToCell函数2个参数有: (int,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void insertCellAtRow(int,int)
 */
static int _insertCellAtRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, insertCellAtRowID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertCellAtRow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertCellAtRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void insertRow(int,int)
 * void insertRow(int,int,boolean)
 */
static int _insertRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_isboolean(L, 4)) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            int p3 = lua_toboolean(L, 4);
            (*env)->CallVoidMethod(env, jobj, insertRow1ID, (jint)p1, (jint)p2, (jboolean)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insertRow")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".insertRow函数3个参数有: (int,int,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            (*env)->CallVoidMethod(env, jobj, insertRow0ID, (jint)p1, (jint)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".insertRow")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".insertRow函数2个参数有: (int,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void deleteCellAtRow(int,int)
 */
static int _deleteCellAtRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, deleteCellAtRowID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".deleteCellAtRow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "deleteCellAtRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void deleteRow(int,int)
 * void deleteRow(int,int,boolean)
 */
static int _deleteRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_isboolean(L, 4)) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            int p3 = lua_toboolean(L, 4);
            (*env)->CallVoidMethod(env, jobj, deleteRow1ID, (jint)p1, (jint)p2, (jboolean)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".deleteRow")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "deleteRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".deleteRow函数3个参数有: (int,int,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            lua_Integer p2 = luaL_checkinteger(L, 3);
            (*env)->CallVoidMethod(env, jobj, deleteRow0ID, (jint)p1, (jint)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".deleteRow")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "deleteRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".deleteRow函数2个参数有: (int,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * boolean isRefreshing()
 */
static int _isRefreshing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, isRefreshingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".isRefreshing")) {
        return lua_error(L);
    }
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isRefreshing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void startRefreshing()
 */
static int _startRefreshing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, startRefreshingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".startRefreshing")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "startRefreshing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void stopRefreshing()
 */
static int _stopRefreshing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, stopRefreshingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".stopRefreshing")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "stopRefreshing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isLoading()
 */
static int _isLoading(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, isLoadingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".isLoading")) {
        return lua_error(L);
    }
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isLoading", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void stopLoading()
 */
static int _stopLoading(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, stopLoadingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".stopLoading")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "stopLoading", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void noMoreData()
 */
static int _noMoreData(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, noMoreDataID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".noMoreData")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "noMoreData", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void resetLoading()
 */
static int _resetLoading(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, resetLoadingID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".resetLoading")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "resetLoading", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void loadError()
 */
static int _loadError(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, loadErrorID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".loadError")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "loadError", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.recycler.UDBaseRecyclerAdapter getAdapter()
 * void setAdapter(com.immomo.mmui.ud.recycler.UDBaseRecyclerAdapter)
 */
static int _adapter(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getAdapterID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getAdapter")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getAdapter", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setAdapterID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setAdapter")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setAdapter", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.recycler.UDBaseRecyclerLayout getLayout()
 * void setLayout(com.immomo.mmui.ud.recycler.UDBaseRecyclerLayout)
 */
static int _layout(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getLayoutID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getLayout")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getLayout", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setLayoutID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLayout")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLayout", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setRefreshingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setRefreshingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setRefreshingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRefreshingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRefreshingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setLoadingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setLoadingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setLoadingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setLoadingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setLoadingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollBeginCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollBeginCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollBeginCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollBeginCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollBeginCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollEndCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollEndCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollEndCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollEndCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollEndCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setEndDraggingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setEndDraggingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setEndDraggingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEndDraggingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setEndDraggingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollWillEndDraggingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollWillEndDraggingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollWillEndDraggingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollWillEndDraggingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollWillEndDraggingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setStartDeceleratingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setStartDeceleratingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setStartDeceleratingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStartDeceleratingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStartDeceleratingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void insertCellsAtSection(int,int,int)
 */
static int _insertCellsAtSection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, insertCellsAtSectionID, (jint)p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertCellsAtSection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertCellsAtSection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void insertRowsAtSection(int,int,int,boolean)
 */
static int _insertRowsAtSection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    int p4 = lua_toboolean(L, 5);
    (*env)->CallVoidMethod(env, jobj, insertRowsAtSectionID, (jint)p1, (jint)p2, (jint)p3, (jboolean)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertRowsAtSection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertRowsAtSection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void deleteRowsAtSection(int,int,int,boolean)
 */
static int _deleteRowsAtSection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    int p4 = lua_toboolean(L, 5);
    (*env)->CallVoidMethod(env, jobj, deleteRowsAtSectionID, (jint)p1, (jint)p2, (jint)p3, (jboolean)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".deleteRowsAtSection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "deleteRowsAtSection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void deleteCellsAtSection(int,int,int)
 */
static int _deleteCellsAtSection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, deleteCellsAtSectionID, (jint)p1, (jint)p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".deleteCellsAtSection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "deleteCellsAtSection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setContentInset(float,float,float,float)
 */
static int _setContentInset(lua_State *L) {
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
    (*env)->CallVoidMethod(env, jobj, setContentInsetID, (jfloat)p1, (jfloat)p2, (jfloat)p3, (jfloat)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentInset")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentInset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void getContentInsetByFunction(long)
 */
static int _getContentInset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, getContentInsetByFunctionID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentInsetByFunction")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentInsetByFunction", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void useAllSpanForLoading(boolean)
 */
static int _useAllSpanForLoading(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, useAllSpanForLoadingID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".useAllSpanForLoading")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "useAllSpanForLoading", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getRecycledViewNum()
 */
static int _getRecycledViewNum(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, getRecycledViewNumID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getRecycledViewNum")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getRecycledViewNum", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isStartPosition()
 */
static int _isStartPosition(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, isStartPositionID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".isStartPosition")) {
        return lua_error(L);
    }
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isStartPosition", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * long cellWithSectionRow(int,int)
 */
static int _cellWithSectionRow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    jlong ret = (*env)->CallLongMethod(env, jobj, cellWithSectionRowID, (jint)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cellWithSectionRow")) {
        return lua_error(L);
    }
    getValueFromGNV(L, (ptrdiff_t) ret, LUA_TTABLE);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cellWithSectionRow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDArray visibleCells()
 */
static int _visibleCells(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, visibleCellsID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".visibleCells")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "visibleCells", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isDisallowFling()
 * void setDisallowFling(boolean)
 */
static int _disallowFling(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isDisallowFlingID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isDisallowFling")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isDisallowFling", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setDisallowFlingID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDisallowFling")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setDisallowFling", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * long visibleCellsRows()
 */
static int _visibleCellsRows(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong ret = (*env)->CallLongMethod(env, jobj, visibleCellsRowsID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".visibleCellsRows")) {
        return lua_error(L);
    }
    getValueFromGNV(L, (ptrdiff_t) ret, LUA_TTABLE);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "visibleCellsRows", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (pc == 3) {
        int p1 = lua_toboolean(L, 1);
        int p2 = lua_toboolean(L, 2);
        int p3 = lua_toboolean(L, 3);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jboolean)p1, (jboolean)p2, (jboolean)p3);
    } else if (pc == 2) {
        int p1 = lua_toboolean(L, 1);
        int p2 = lua_toboolean(L, 2);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor1, (jlong) L, (jboolean)p1, (jboolean)p2);
    } else if (pc == 1) {
        int p1 = lua_toboolean(L, 1);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor2, (jlong) L, (jboolean)p1);
    } else {
        javaObj = (*env)->NewObject(env, _globalClass, _constructor3, (jlong) L);
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