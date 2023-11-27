/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by Xiong.Fangyu 2019/02/22
 */

#include "lauxlib.h"
#include "lualib.h"
#include "lobject.h"
#include "lstate.h"
#include "llimits.h"
#include "lfunc.h"
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include "luajapi.h"
#include "debug_info.h"
#include "mlog.h"
#include "m_mem.h"
#include "compiler.h"
#include "saes.h"
#include "statistics.h"
#include "statistics_require.h"
#include "reflib.h"
#include "mempool.h"

jboolean jni_isSAESFile(JNIEnv *env, jobject jobj, jstring path) {
    const char *file = GetString(env, path);
    int r = check_file(file);
    ReleaseChar(env, path, file);
    return r;
}

//<editor-fold desc="statistic callback">
#ifdef STATISTIC_PERFORMANCE
static jclass Java_Statistic = NULL;
static jmethodID Java_Statistic_callback = NULL;

static jclass Java_Require_Statistic = NULL;
static jmethodID Java_Require_Statistic_callback = NULL;

static void _inner_callback(const char *str, jclass jclass, jmethodID jmethodId) {
    if (!str)
        return;
    JNIEnv *env;
    int need = getEnv(&env);
    (*env)->CallStaticVoidMethod(env, jclass, jmethodId, newJString(env, str));
    if (need)
        detachEnv();
}

static void _inner_bridge_callback(const char *str) {
    _inner_callback(str, Java_Statistic, Java_Statistic_callback);
}

static void _inner_require_callback(const char *str) {
    _inner_callback(str, Java_Require_Statistic, Java_Require_Statistic_callback);
}
#endif

void jni_notifyStatisticsCallback(JNIEnv *env, jobject jobj){
    notifyStatisticsCallback();
}

void jni_notifyRequireCallback(JNIEnv *env, jobject jobj) {
    notifyRequireCallback();
}

void jni_setStatisticsOpen(JNIEnv *env, jobject jobj, jboolean open) {
#ifdef STATISTIC_PERFORMANCE
    if (open) {
        if (!Java_Statistic) {
            Java_Statistic = (*env)->FindClass(env, "com/immomo/mlncore/Statistic");
            Java_Statistic_callback = (*env)->GetStaticMethodID(env, Java_Statistic, "onBridgeCallback",
                                                                "(" STRING_CLASS ")V");
            Java_Statistic = GLOBAL(env, Java_Statistic);
        }
        setStrCallback(_inner_bridge_callback);


        if (!Java_Require_Statistic) {
            Java_Require_Statistic = (*env)->FindClass(env, "com/immomo/mlncore/Statistic");
            Java_Require_Statistic_callback = (*env)->GetStaticMethodID(env, Java_Statistic, "onRequireCallback",
                                                                "(" STRING_CLASS ")V");
            Java_Require_Statistic = GLOBAL(env, Java_Require_Statistic);
        }
        setRequireStrCallback(_inner_require_callback);

    }
    setOpenStatistics((int)open);
    setOpenRequireStatistics((int)open);
#endif
}
//</editor-fold>

//<editor-fold desc="error function">
/**
 * 一般lua异常
 */
static int error_func_traceback(lua_State *L) {
    const char *msg = lua_isstring(L, 1) ? lua_tostring(L, 1) : "unknown error";
    luaL_traceback(L, L, msg, 2);
    return 1;
}
//jmp_buf _jmp_buf;
extern jclass Globals;

/**
 * 调用 abort
 * @param L 一般指虚拟机
 * @param msg 错误信息
 */
void must_abort(void *L, const char *msg) {
    JNIEnv *env;
    getEnv(&env);
    jmethodID __onFatalError = (*env)->GetStaticMethodID(env, Globals, "__onFatalError", "(J" STRING_CLASS ")V");
    (*env)->CallStaticVoidMethod(env, Globals, __onFatalError, (jlong) L, newJString(env, msg));
    abort();
}
/**
 * 虚拟机出现重大异常，会走到这个函数，并abort
 */
static int panic_function(lua_State *L) {
    const char *msg = lua_tostring(L, -1);
    luaL_traceback(L, L, msg, 0);
    msg = lua_tostring(L, -1);
    must_abort(L, msg);
//    _longjmp(_jmp_buf, 1);
    return 1;
}

int getErrorFunctionIndex(lua_State *L) {
    if (lua_iscfunction(L, 1) && lua_tocfunction(L, 1) == error_func_traceback) {
        return 1;
    }
    lua_getglobal(L, ERROR_FUN);
    return lua_gettop(L);
}
//</editor-fold>

//<editor-fold desc="db、base、so path">
const char *l_db_path = NULL;

void jni_setDatabasePath(JNIEnv *env, jobject jobj, jstring path) {
    l_db_path = GetString(env, path);
}

void jni_setBasePath(JNIEnv *env, jobject jobj, jlong LS, jstring path, jboolean autosave) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *bp = GetString(env, path);
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_pushstring(L, bp);             //-1 bp -- table
    lua_setfield(L, -2, "path");       //-1 table
    lua_pushboolean(L, (int) autosave); //-1 bool --table
    lua_setfield(L, -2, AUTO_SAVE);    //-1 table
    lua_pop(L, 1);
    ReleaseChar(env, path, bp);
    lua_unlock(L);
}

void jni_setSoPath(JNIEnv *env, jobject jobj, jlong LS, jstring path) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *bp = GetString(env, path);
    lua_getglobal(L, LUA_LOADLIBNAME); //-1 package table
    lua_pushstring(L, bp);             //-1 bp -- table
    lua_setfield(L, -2, "cpath");      //-1 table
    lua_pop(L, 1);
    ReleaseChar(env, path, bp);
    lua_unlock(L);
}
//</editor-fold>

//<editor-fold desc="GC">
#define GC_OFFSET_TIME (CLOCKS_PER_SEC >> 3)
static clock_t last_gc_time = 0;
static int gc_offset_time = 0;

static void gc_cb(lua_State *L, int type) {
    if (gc_offset_time <= 0) return;
    clock_t now = clock();
    if (last_gc_time != 0) {
        int offset = now - last_gc_time;
        if (offset < gc_offset_time) return;
    }
    last_gc_time = now;
    JNIEnv *env;
    int d = getEnv(&env);
    callbackLuaGC(env, L);
    if (d) detachEnv();
}

void jni_setGcOffset(JNIEnv *env, jobject jobj, int offset) {
    gc_offset_time = offset * GC_OFFSET_TIME;
}
//</editor-fold>

//<editor-fold desc="lua vm init">
static int use_mem_pool = 0;
#if defined(J_API_INFO)
static size_t _all_vm_use_mem = 0;
#endif

jlong jni_allLvmMemUse(JNIEnv *env, jobject jobj) {
#if defined(J_API_INFO)
    return (jlong) m_mem_use() + _all_vm_use_mem;
#else
    return 0;
#endif
}

void jni_setUseMemoryPool(JNIEnv *env, jobject jobj, jboolean use) {
    use_mem_pool = (int) use;
}

/// 96K
#define POOL_MIN_MEM_SIZE (24 << 12)

void *m_alloc(void *ud, void *ptr, size_t osize, size_t nsize) {
    LuaJData *jd = (LuaJData *) ud;
    if (jd->pool) {
        if (nsize == 0) {
#if defined(J_API_INFO)
            _all_vm_use_mem -= osize;
            jd->use_mem -= osize;
#endif
            if (!jd->vm_is_closing && ptr)
                mp_free(jd->pool, ptr);
            return NULL;
        }
        if (!ptr) {
            ptr = mp_alloc(jd->pool, nsize);
            osize = 0;
        }
        /// 当vm在关闭过程中时，osize>=nsize表示当前指针可以不用改变
        else if (!(jd->vm_is_closing && osize >= nsize)) {
            ptr = mp_realloc(jd->pool, ptr, nsize);
//            void *nptr = mp_alloc(jd->pool, nsize);
//            memcpy(nptr, ptr, osize < nsize ? osize : nsize);
//            ptr = nptr;
        }
#if defined(J_API_INFO)
        if (ptr) {
            jd->use_mem += nsize - osize;
            _all_vm_use_mem += nsize - osize;
        }
#endif
        return ptr;
    }
    if (nsize == 0) {
        free(ptr);
#if defined(J_API_INFO)
        _all_vm_use_mem -= osize;
        jd->use_mem -= osize;
#endif
        return NULL;
    } else {
        if (!ptr) {
            ptr = malloc(nsize);
#if defined(J_API_INFO)
            if (ptr) {
                jd->use_mem += nsize;
                _all_vm_use_mem += nsize;
            }
#endif
        } else {
            ptr = realloc(ptr, nsize);
#if defined(J_API_INFO)
            if (ptr) {
                jd->use_mem += nsize - osize;
                _all_vm_use_mem += nsize - osize;
            }
#endif
        }
        return ptr;
    }
}

void init_importer(lua_State *pState);

extern void openlibs_forlua(lua_State *L, int debug) {
    lua_lock(L);
    L->l_G->gc_callback = NULL;
    luaL_openlibs(L);
    ref_open(L);
    init_require(L);
    init_importer(L);

    lua_atpanic(L, panic_function);
    lua_pushcfunction(L, error_func_traceback);
    lua_setglobal(L, ERROR_FUN);
    lua_getglobal(L, ERROR_FUN);
    JNIEnv *env;
    int need = getEnv(&env);
    initlog(env);
    if (need) detachEnv();
    init_cache(L);

    lua_getglobal(L, LUA_LOADLIBNAME);          //-1 package table

    lua_pushnil(L);                             //-1 nil -2 table
    lua_setfield(L, -2, "path");         //package.path = nil -1 table

    luaL_getsubtable(L, -1, "searchers");       //-1 package.searchers table; -2 package table
    int len = lua_objlen(L, -1);
#ifdef ANDROID
    lua_pushcfunction(L,
                      searcher_Lua_asset);   //-1: fun;-2 package.searchers table; -3 package table
    lua_rawseti(L, -2, ++len);                  //-1: package.searchers table; -2 package table
#endif
    lua_pushcfunction(L,
                      searcher_java);        //-1: fun;-2 package.searchers table; -3 package table
    lua_rawseti(L, -2, ++len);
    lua_pop(L, 2);
    if (gc_offset_time > 0)
        G(L)->gc_callback = gc_cb;
    lua_unlock(L);
}

jlong jni_createLState(JNIEnv *env, jobject jobj, jboolean debug) {
    LuaJData *ud = (LuaJData *) m_malloc(NULL, 0, sizeof(LuaJData));
#if defined(J_API_INFO)
    ud->use_mem = 0;
    ud->create_thread = pthread_self();
#endif
    ud->type = no;
    ud->vm_is_closing = 0;
    if (use_mem_pool) {
        ud->pool = mp_new_pool(POOL_MIN_MEM_SIZE, MP_MAX_SIZE);
    } else {
        ud->pool = NULL;
    }
    lua_State *L = lua_newstate(m_alloc, ud);
    if (L)
        openlibs_forlua(L, (int) debug);
    else {
        if (ud->pool)
            mp_free_pool(ud->pool);
        m_malloc(ud, sizeof(LuaJData), 0);
    }

    return (jlong) L;
}

jint jni_getErrorType(JNIEnv *env, jobject jobj, jlong L) {
    int ret = getErrorType((lua_State *)L);
    clearErrorType((lua_State *)L);
    return ret;
}

#ifdef MEM_POOL_TEST
void jni_testMemoryPool(JNIEnv *env, jobject jobj, jlong L) {
    lua_State *LS = (lua_State *) L;
    LuaJData *ud = G(LS)->ud;
    mp_test(ud->pool);
}
#endif

void jni_openDebug(JNIEnv *env, jobject jobj, jlong L) {
}

void jni_close(JNIEnv *env, jobject jobj, jlong L) {
    lua_State *LS = (lua_State *) L;
    LuaJData *ud = G(LS)->ud;
    ud->vm_is_closing = 1;
#if defined(J_API_INFO)
    _checkThread(ud);
#endif
    lua_close(LS);
    if (ud->pool) {
        mp_free_pool(ud->pool);
    }
    m_malloc(ud, sizeof(LuaJData), 0);
#if defined(J_API_INFO)
    cj_log();
#endif
}
//</editor-fold>

//<editor-fold desc="debug jni method">
jlong jni_lvmMemUse(JNIEnv *env, jobject jobj, jlong L) {
    LuaJData *ud = G(((lua_State *) L))->ud;
    if (ud->pool)
        return ud->pool->use_mem;
#if defined(J_API_INFO)
    return ud->use_mem;
#else
    return 0;
#endif
}

extern jclass LuaValue;
jobjectArray jni_dumpStack(JNIEnv *env, jobject jobj, jlong L) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int size = lua_gettop(LS);
    jobjectArray arr = (*env)->NewObjectArray(env, (jsize) size, LuaValue, NULL);
    int index, i;
    for (index = size; index > 0; --index) {
        i = size - index;
        jobject v = toJavaValue(env, LS, index);
        (*env)->SetObjectArrayElement(env, arr, i, v);
        FREE(env, v);
    }
    lua_unlock(LS);
    return arr;
}

jstring jni_traceback(JNIEnv *env, jobject jobj, jlong l) {
    lua_State *L = (lua_State *) l;
    luaL_traceback(L, L, NULL, 0);
    const char *trace = lua_tostring(L, -1);
    lua_pop(L, 1);
    return newJString(env, trace);
}

void jni_lgc(JNIEnv *env, jobject jobj, jlong L) {
    lua_State * LS = (lua_State *)L;
    lua_gc(LS, LUA_GCCOLLECT, 0);
}
//</editor-fold>

void jni_callMethod(JNIEnv *env, jobject jobj, jlong L, jlong method, jlong arg) {
    lua_State *LS = (lua_State *) L;
    CheckThread(LS);
    callback_method m = (callback_method) method;
    m(LS, (void *) arg);
}