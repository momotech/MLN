/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by Xiong.Fangyu 2019/03/13
 */

#include <string.h>
#include "cache.h"
#include "lobject.h"
#include "mlog.h"
#include "debug_info.h"
#include "map.h"
#include "m_mem.h"
#include "llimits.h"
#include "juserdata.h"

/**
 * 从GNV表中移除native数据
 * @return 返回引用计数
 */
static int removeValueFromGNV(lua_State *L, ptrdiff_t key, int ltype);
/**
 * 判断GNV表中是否有相应对象
 */
static int hasNativeValue(lua_State *L, ptrdiff_t key, int ltype);

jint jni_removeNativeValue(JNIEnv *env, jobject job, jlong L, jlong key, jint lt) {
    if (key) {
        lua_State *LS = (lua_State *) L;
        int r = removeValueFromGNV(LS, (ptrdiff_t) key, lt);
        return (jint) r;
    }
    return (jint) -1;
}

jboolean jni_hasNativeValue(JNIEnv *env, jobject obj, jlong L, jlong key, jint lt) {
    lua_State *LS = (lua_State *) L;
    return (jboolean) hasNativeValue(LS, (ptrdiff_t) key, lt);
}

static void init_map();

void init_cache(lua_State *L) {
    init_map();
    lua_lock(L);
    /// 创建GNV表 需要针对4种类型
    lua_createtable(L, 4, 0);
    lua_setglobal(L, GNV);
    lua_unlock(L);
}

/**
 * GNV表设计:
 *  {
 *      [type]: type取值有Table|Function
 *      {
 *          [addr]:
 *          {
 *              [GNV_VIDX]: obj,        存储对象
 *              [GNV_NIDX]: ref_count   引用计数
 *          }
 *      }
 *      [Userdata]: Userdata类型单独拎出来，因为userdata不用单独的引用计数
 *      {
 *          [addr]: obj     存储对象，引用计数在对象内部
 *      }
 *  }
 */
#define GNV_VIDX 1
#define GNV_NIDX 2

/**
 * 从GNV 表中，找到对应类型的表
 * 主要类型为 table, function, userdata, thread
 */
static void getGlobalNVTableForType(lua_State *L, int type) {
    lua_lock(L);
    lua_getglobal(L, GNV);                  // -1: GNV
    lua_rawgeti(L, -1, (lua_Integer) type);  // -1: value --GNV
    if (lua_istable(L, -1)) {
        lua_remove(L, -2);
        lua_unlock(L);
        return;
    }
    lua_pop(L, 1);                          // -1: GNV
    lua_createtable(L, 0, 10);              // -1: table --GNV
    lua_pushvalue(L, -1);                   // -1: table --table-GNV
    lua_rawseti(L, -3, (lua_Integer) type);  // -1: table -GNV
    lua_remove(L, -2);
    lua_unlock(L);
}

ptrdiff_t copyValueToGNV(lua_State *L, int idx) {
    lua_lock(L);
    lua_pushvalue(L, idx);                            // -1: value
    ptrdiff_t addr = (ptrdiff_t) lua_topointer(L, -1);

    int type = lua_type(L, -1);
    getGlobalNVTableForType(L, type);                 // -1: table --value

    lua_pushnumber(L, addr);                          // -1: addr --table-value
    lua_rawget(L, -2);                                // -1: newtable; --table-value
    /// 已有缓存的情况，增加引用计数
    if (lua_istable(L, -1)) {
        lua_rawgeti(L, -1, GNV_NIDX);       //-1: num(引用计数) --newtable-table-value
        int num = lua_tointeger(L, -1);
        lua_pushinteger(L, num + 1);        // -1: num(增加计数) --num(原计数)-newtable-table-value
        lua_rawseti(L, -3,
                    GNV_NIDX);              // newtable[2] = num(增加计数)    --num(原计数)-newtable-table-value
        lua_pop(L, 4);
        lua_unlock(L);
        return addr;
    }
    /// 剩下的情况：缓存一定为空
    /// -1: nil --table-value
    lua_pop(L, 1);                  // -1: table --value
    lua_pushnumber(L, addr);        // -1: addr --table-value
    /// ud情况下，肯定没有缓存，且不处理引用计数
    if (type == LUA_TUSERDATA) {
        lua_pushvalue(L, -3);       // -1: value --addr-table-value
        lua_rawset(L, -3);          // -1: table --value
        lua_pop(L, 2);
        lua_unlock(L);
        return addr;
    }

    /// 其他类型, 增加引用计数，创建一个数组table，1指向value，2指向引用计数
    /// -1: addr --table-value
    lua_createtable(L, 2, 0);       // -1: newtable --addr-table-value
    lua_pushinteger(L, 1);          // -1: 1 --newtable-addr-table-value
    lua_rawseti(L, -2, GNV_NIDX);   //设置计数 newtable[2] = 1  -1：newtable --addr-table-value
    lua_pushvalue(L, -4);           // -1: value --newtable-key-table-value
    lua_rawseti(L, -2, GNV_VIDX);   //newtable[1] = value   -1: newtable --key-table-value
    lua_rawset(L, -3);              // table[key] = newtable  -1: table --value
    lua_pop(L, 2);
    lua_unlock(L);
    return addr;
}

void getValueFromGNV(lua_State *L, ptrdiff_t key, int ltype) {
    lua_lock(L);
    if (!key) {
        lua_pushnil(L);
        lua_unlock(L);
        return;
    }

    getGlobalNVTableForType(L, ltype);
    lua_pushnumber(L, key); //-1:key --table
    lua_rawget(L, -2);      //-1:newtable --table
    lua_remove(L, -2);      //-1:newtable
    if (lua_isnil(L, -1)) {
        lua_unlock(L);
        return;
    }
    /// 非ud类型
    if (lua_istable(L, -1)) {
        lua_rawgeti(L, -1, GNV_VIDX);   //-1:newtable[1] --newtable
        lua_remove(L, -2);              //-1:newtable[1]
    }
    /// ud类型不用处理
    /// -1: userdata
    lua_unlock(L);
}

static int hasNativeValue(lua_State *L, ptrdiff_t key, int ltype) {
    lua_lock(L);
    getGlobalNVTableForType(L, ltype);  //-1: table
    lua_pushnumber(L, key);             //-1: key--table
    lua_rawget(L, -2);                  //-1: newtable --table
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);
        lua_unlock(L);
        return 0;
    }

    lua_pop(L, 2);
    lua_unlock(L);
    return 1;
}

static int removeValueFromGNV(lua_State *L, ptrdiff_t key, int ltype) {
    if (!key) return -1;

    lua_lock(L);
    getGlobalNVTableForType(L, ltype);  //-1: table
    lua_pushnumber(L, key);             //-1: key--table
    lua_rawget(L, -2);                  //-1: newtable --table
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);
        lua_unlock(L);
        return -1;
    }
    /// userdata类型
    /// -1: userdata --table
    if (ltype == LUA_TUSERDATA) {
        UDjavaobject ud = (UDjavaobject) lua_touserdata(L, -1);
        ud->refCount--;
        if (ud->refCount <= 0) {
            clearUDFlag(ud, JUD_FLAG_SKEY);
            lua_pop(L, 1);              // -1: table
            lua_pushnumber(L, key);     // -1: key --table
            lua_pushnil(L);
            lua_rawset(L, -3);          // table[key] = nil -1: table
            lua_pop(L, 1);
        }
        lua_unlock(L);
        return ud->refCount;
    }

    /// 其他类型
    /// -1: newtable --table
    lua_rawgeti(L, -1, GNV_NIDX);       //newtable[2]  -1: num(引用计数) --newtable-table
    int num = lua_tointeger(L, -1) - 1; //减去一个计数
    if (num > 0) {                      //还有计数的情况下，替换计数
        lua_pushinteger(L, num);        //-1: num --num(原计数)-newtable-table
        lua_rawseti(L, -3, GNV_NIDX);   //newtable[2] = num  -1:num(原计数) --newtable-table
        lua_pop(L, 3);
        lua_unlock(L);
        return num;
    }
    /// 引用计数为0的情况
    lua_pop(L, 2);                  //-1: table
    lua_pushnumber(L, key);         //-1: key --table
    lua_pushnil(L);                 //-1: nil --key-table
    lua_rawset(L, -3);
    lua_pop(L, 1);
    lua_unlock(L);
    return 0;
}

///---------------------------------------------------------------------------
///------------------------classname->jclass----------------------------------
///---------------------------------------------------------------------------
/// 存储java class 名称 --> 对应global jclass
static Map *__map = NULL;

static void s_free(void *p) {
#if defined(J_API_INFO)
    m_malloc(p, (strlen(p) + 1) * sizeof(char), 0);
#else
    free(p);
#endif
}

static int str_equals(const void *a, const void *b) {
    return strcmp((const char *) a, (const char *) b) == 0;
}

#if defined(J_API_INFO)

static size_t str_size(void *k) {
    char *str = (char *) k;
    return sizeof(char) * (strlen(str) + 1);
}

static size_t obj_size(void *v) {
    return 0;//sizeof(jobject);
}

#endif

static void init_map() {
    if (!__map) {
        __map = map_new(NULL, 50);
        if (map_ero(__map)) {
            map_free(__map);
            __map = NULL;
        } else {
            map_set_free(__map, s_free, NULL);
            map_set_equals(__map, str_equals);
#if defined(J_API_INFO)
            map_set_ud(__map, 1);
            map_set_sizeof(__map, NULL, NULL);
#endif
        }
    }
}

/**
 * 存储类名对应的jclass(global变量)
 */
void cj_put(const char *name, void *obj) {
    init_map();
    if (!__map) {
        LOGE("cj_put-- map is not init!!!");
        return;
    }
    int len = strlen(name) + 1;
    char *copy = (char *) m_malloc(NULL, 0, sizeof(char) * len);
    strcpy(copy, name);
    copy[len - 1] = '\0';
    void *v = map_put(__map, copy, obj);
    if (v) m_malloc(copy, sizeof(char) * len, 0);
#if defined(J_API_INFO)
    if (!v) remove_by_pointer(copy, sizeof(char) * len);
    // LOGE("value for %s is %p, value: %p", copy, v, obj);
#endif
}

/**
 * 取出类名name 对应的jclass(global变量)
 */
void *cj_get(const char *name) {
    if (!__map) {
        return NULL;
    }
    return map_get(__map, name);
}

#if defined(J_API_INFO)

/**
 * 打印map中内容
 */
void cj_log() {
    if (!__map) {
        LOGE("cj_log-- map is not init!!!");
        return;
    }
    size_t len = map_size(__map);
    if (len <= 0) {
        LOGI("map has no value");
        return;
    }
    LOGI("map has %d values, map table has %d size.", (int) len, (int) map_table_size(__map));
}

/**
 * 获取map消耗的内存
 */
size_t cj_mem_size() {
    return __map ? map_mem(__map) : 0;
}

#endif  //J_API_INFO


///---------------------------------------------------------------------------
///------------------------jclsss->constructor--------------------------------
///---------------------------------------------------------------------------

static Map *__classData = NULL;

static int class_equals(const void *a, const void *b) {
    return a == b;
}

unsigned int class_hash(const void *k) {
    return (unsigned int) k;
}

static void init_classData() {
    if (!__classData) {
        __classData = map_new(NULL, 50);
        if (map_ero(__classData)) {
            map_free(__classData);
            __classData = NULL;
        } else {
            map_set_free(__classData, NULL, NULL);
            map_set_equals(__classData, class_equals);
            map_set_hash(__classData, class_hash);
#if defined(J_API_INFO)
            map_set_sizeof(__classData, NULL, NULL);
#endif
        }
    }
}

typedef struct classDataValue {
    jmethodID constructor;
    Map *methods;
} CDV;

/**
 * 存储类对应的构造函数
 */
void jc_put(jclass clz, jmethodID m) {
    init_classData();
    if (!__classData) {
        LOGE("jc_put-- __classData init error!!!");
        return;
    }

    CDV *cdv = map_get(__classData, clz);
    if (!cdv) {
        cdv = (CDV *) malloc(sizeof(CDV));
        if (cdv) {
            map_put(__classData, clz, cdv);
            memset(cdv, 0, sizeof(CDV));
        }
    }

    if (!cdv)
        return;

    cdv->constructor = m;
}

/**
 * 获取类对应的构造函数
 */
void *jc_get(jclass clz) {
    if (!__classData) {
        return NULL;
    }
    CDV *cdv = (CDV *) map_get(__classData, clz);
    if (cdv) return cdv->constructor;
    return NULL;
}

///---------------------------------------------------------------------------
///------------------------name->method---------------------------------------
///---------------------------------------------------------------------------

static Map *init_methods_map() {
    Map *ret = map_new(NULL, 10);
    if (map_ero(ret)) {
        map_free(ret);
        ret = NULL;
    } else {
        map_set_free(ret, s_free, NULL);
        map_set_equals(ret, str_equals);
#if defined(J_API_INFO)
        map_set_sizeof(__classData, NULL, NULL);
#endif
    }
    return ret;
}

/**
 * 存储类对应的方法
 */
void jm_put(jclass clz, const char *name, jmethodID m) {
    init_classData();
    if (!__classData) {
        LOGE("jm_put-- __classData is not init!!!");
        return;
    }
    CDV *cdv = map_get(__classData, clz);
    if (!cdv) {
        cdv = (CDV *) malloc(sizeof(CDV));
        if (cdv) {
            map_put(__classData, clz, cdv);
            memset(cdv, 0, sizeof(CDV));
        }
    }
    if (!cdv)
        return;
    Map *method_map = cdv->methods;
    if (!method_map) {
        method_map = init_methods_map();
        cdv->methods = method_map;
    }
    if (!method_map) return;

    int len = strlen(name) + 1;
    char *copy = (char *) malloc(sizeof(char) * len);
    strcpy(copy, name);
    copy[len - 1] = '\0';

    void *v = map_put(method_map, copy, m);
    if (v) free(copy);
}

/**
 * 获取类对应的方法
 */
void *jm_get(jclass clz, const char *name) {
    if (!__classData) {
        LOGE("jm_get-- __classData is not init!!!");
        return NULL;
    }

    CDV *cdv = map_get(__classData, clz);
    if (!cdv) return NULL;

    Map *method_map = cdv->methods;
    if (!method_map) return NULL;

    return map_get(method_map, name);
}

/**
 * 获取clz对应的所有方法
 */
void jm_traverse_all_method(jclass clz, map_look_fun fun, void *ud) {
    if (!__classData) {
        LOGE("jm_traverse_all_method-- __classData is not init!!!");
        return;
    }

    CDV *cdv = map_get(__classData, clz);
    if (!cdv) return;

    Map *method_map = cdv->methods;
    if (!method_map) return;

    map_traverse(method_map, fun, ud);
}