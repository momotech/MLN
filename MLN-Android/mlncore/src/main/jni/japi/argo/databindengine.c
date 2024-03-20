/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/6/4.
//

#include "databindengine.h"
#include <string.h>
#include "lauxlib.h"
#include "utils.h"
#include "LuaIPC.h"
#include "global_define.h"
#include "mtree.h"
#include "debug_info.h"

typedef struct DataBind {
    D_malloc alloc;
    /**
     * 存储key->lua_State(被观察者)
     * 1:1
     */
    Map *key_observable;
    /**
     * 储存key->List(lua_State)观察者
     * 1:n
     */
    Map *key_observer;
    /**
     * 存储lua_State->List(key)
     * 1:n
     * 每个虚拟机被观察的key和观察key，释放时使用
     */
    Map *vm_key;
} DataBind;

static DataBind *instance = NULL;

/**
 * 在虚拟机全局表中设定一个特殊表来记录观察者(OTK)
 * 记录方式为: key->{function, params}
 */
#define OBSERVER_TABLE_KEY "__OTK"
/**
 * 针对需要观察的表，在虚拟机全局表中设定一个特殊表来记录(OATK)
 * 记录方式为: key->table
 */
#define OBSERVABLE_TABLE_KEY "__OATK"
/**
 * 记录当前表的key值
 */
#define OBSERVABLE_TABLE_FLAG "__OATF"
/**
 * 插入、删除操作移动table值时，忽略监听
 */
#define OBSERVER_TABLE_IGNORE_FLAG "__OTKT_F"
/**
 * 插入、删除、更新操作类型：insert:1, remove:2, updata:3
 */
#define OBSERVER_TABLE_CHANGE_TYPE_FLAG "__OTKT_TYPE_F"

#define LUA_INDEX_KEY "__index"
#define LUA_NEWINDEX_KEY "__newindex"
#define LUA_PAIRS_KEY "__pairs"
#define LUA_IPAIRS_KEY "__ipairs"
#define LUA_LEN_KEY "__len"

#define LUA_CHANGE_TYPE_INSERT 1
#define LUA_CHANGE_TYPE_REMOVE 2
#define LUA_CHANGE_TYPE_UPDATE 3
/**
 * watchTable回调函数type，返回change_key、type、old、new
 */
#define CALLBACK_PARAMS_TYPE 4

#ifdef J_API_INFO
#define CHECK_STACK_START(L) int _old_top = lua_gettop((L));
#define CHECK_STACK_END(L, l) if (lua_gettop((L)) - _old_top != l) \
    luaL_error((L), "%s(%d) top error, old: %d, new: %d",__FUNCTION__, __LINE__, _old_top, lua_gettop((L)));
#define CHECK_STACK_END_O(L, ot, l) if (lua_gettop((L)) - (ot) != l) \
    LOGE("o %s(%d) top error, old: %d, new: %d",__FUNCTION__, __LINE__, (ot), lua_gettop((L)));
#else
#define CHECK_STACK_START(L)
#define CHECK_STACK_END(L, l)
#define CHECK_STACK_END_O(L, ot, l)
#endif

#define IPC_RESULT(ret) const char *msg;\
                        switch (ret) {\
                            case IPC_MEM_ERROR:\
                                msg = "no memory";\
                                break;\
                            default:\
                                msg = "only support type nil|boolean|number|string|table";\
                                break;\
                        }

//<editor-fold desc="vm key 相关操作">

static int _str_equals(const void *a, const void *b) {
    const char *ba = (const char *) a;
    const char *bb = (const char *) b;
    while (*ba && *bb) {
        if (*ba != *bb) return 0;
        ba++;
        bb++;
    }
    if (*ba != *bb) return 0;
    return 1;
}

static void saveVmKey(lua_State *L, const char *key) {
    List *list = map_get(instance->vm_key, L);
    if (!list) {
        list = list_new(instance->alloc, 20, 0);
        if (!list) {
            luaL_error(L, "save vm(%p) key(%s) failed, no memory!", L, key);
            return;
        }
        list_set_equals(list, _str_equals);
        map_put(instance->vm_key, (void *) L, list);
    } else if (list_index(list, (void *) key) < list_size(list)) {
        return;
    }
    list_add(list, copystr(key));
}

/**
 * 1、从key_observable删除虚拟机相关缓存
 * 2、从key_observer删除虚拟机相关缓存
 */
int _freeTraverse(const void *value, void *ud) {
    /// step 1:
    if (instance->key_observable) {
        map_remove(instance->key_observable, value);
    }
    /// step 2:
    if (ud && instance->key_observer) {
        List *list = map_get(instance->key_observer, value);
        if (list) {
            list_remove_obj(list, ud);
            if (!list_size(list)) {
                map_remove(instance->key_observer, value);
                list_free(list);
            }
        }
    }
    instance->alloc((void *) value, (strlen(value) + 1) * sizeof(char), 0);
    return 0;
}

/**
 * 检查argo instance是否初始化
 */
static inline void _check_instance(lua_State *L) {
    if (!instance) {
        luaL_error(L, "argo databinding instance not init");
    }
}
//</editor-fold>

//<editor-fold desc="observable table">
//<editor-fold desc="callback">
/**
 * 获取table中key的值，key可以是多级的
 * 进入栈:无
 * 退出栈:key在table中的值，或中途因为非table造成的中断值
 * @return 0: 成功; 其他，key从0~len的值在table中不是table，且后续还有'.'
 */
static inline int _get_table_by_key(lua_State *L, const char *key, int table, int *last_key_start) {
    if (!key) {
        lua_pushvalue(L, table);
        return 0;
    }
    static const size_t _max = 100;
    char tkey[_max];
    size_t index = 0;
    size_t key_len = strlen(key);
    char *dot = strchr(key, '.');
    int lkeyindex = 0;
    char *end;
    int num;
    lua_pushvalue(L, table);
    /// -1:table
    while (dot && lua_istable(L, -1)) {
        index = dot - key;
        memcpy(tkey, key, index);
        tkey[index] = '\0';

        if (string_to_int(tkey, &num)) {
            lua_pushinteger(L, num);
            lua_gettable(L, -2);
        } else {
            lua_getfield(L, -1, tkey);
        }
        lua_remove(L, -2);
        /// -1: value
        lkeyindex = (int) (dot - key) + 1;
        dot = strchr(&dot[1], '.');
    }
    /// -1: value
    if (last_key_start)
        *last_key_start = lkeyindex;
    /// dot != NULL 说明-1不是table
    if (dot) {
        return (int) (dot - key);
    }
    /// dot == NULL，最后一个key前的value不为table
    if (!lua_istable(L, -1)) {
        return lkeyindex - 1;
    }
    memcpy(tkey, &key[lkeyindex], key_len - lkeyindex);
    tkey[key_len - lkeyindex] = '\0';
    if (string_to_int(tkey, &num)) {
        lua_pushinteger(L, num);
        lua_gettable(L, -2);
    } else {
        lua_getfield(L, -1, tkey);
    }
    lua_remove(L, -2);
    /// -1: value
    return 0;
}

/**
 * 存储原虚拟机和新旧数据栈位置
 */
typedef struct DataContainer {
    lua_State *L;
    int oldIndex;
    int newIndex;
    const char *key;
    const char *parent;
    int changeType;
} _DC;

/**
 * OTK中查找对应lua函数
 * 通过key寻找callback，若找到，则栈顶为function，若没找到，栈顶为OTK
 * 传入时，dest栈顶必须为OTK
 * @return 找到时，返回param
 */
static inline int _get_callback_function(lua_State *dest, const char *key) {
    /// -1: OTK
    lua_getfield(dest, -1, key);
    if (!lua_istable(dest, -1)) {
        lua_pop(dest, 1);
        return 0;
    }
    /// -1:{function, params} -2:OTK
    lua_rawgeti(dest, -1, 1);
    if (!lua_isfunction(dest, -1)) {
        lua_pop(dest, 2);
        return 0;
    }
    /// -1: function, -2: {function, params} -3:OTK
    lua_rawgeti(dest, -2, 2);
    if (!lua_isnumber(dest, -1)) {
        lua_pop(dest, 3);
        return 0;
    }
    int params = lua_tointeger(dest, -1);
    lua_pop(dest, 1);
    lua_remove(dest, -2);
    /// -1: function, -2:OTK
    return params;
}
/**
 * 查找callback并回调
 * 进入时，dest栈为:-1:function
 * @param params 回调参数
 * @param old_index 旧值在dest中的位置
 * @param new_index 新值在dest中的位置
 *
 * 复制旧值和新值,不使用ipc复制
 * 调用函数
 */
static inline void _real_callback(lua_State *dest,
        int params, int old_index, int new_index) {
    int top = lua_gettop(dest);
    old_index = old_index < 0 ? top + old_index + 1 : old_index;
    new_index = new_index < 0 ? top + new_index + 1 : new_index;
    /// -1: function, -2:OTK
    /// step 2
    if (params > 0) {
        lua_pushvalue(dest, new_index);
    }
    if (params > 1) {
        lua_pushvalue(dest, old_index);
    }
    /// maybe -1:old, -2:new, -3:function
    /// step 3
    lua_call(dest, params, 0);
}
/**
 * 先检查是否有对应的callback，然后回调
 * @param oldindex src中old下标
 * @param newindex src中new下标
 * @param needcopy 是否需要ipc copy old和new的flag，0位表示new，1位表示old; 1表示需要
 * @return 1:回调，0:无回调
 */
static inline int _check_and_callback(lua_State *src,
        lua_State *dest, const char *key,
        int oldindex, int newindex) {
    /// -1: OTK
    int params = _get_callback_function(dest, key);
    if (lua_isfunction(dest, -1)) {
        /// -1: function, -2: otk
        int functionIndex = -1;
        if (dest != src) {
            if (params > 0) {
                int ret = ipc_copy(src, newindex, dest);
                if (ret != IPC_OK) {
                    lua_pop(dest, 2);
                    IPC_RESULT(ret);
                    luaL_error(src, "callback failed, msg: %s, target(%s): %s",
                               msg, luaL_typename(src, -1), luaL_tolstring(src, -1, NULL));
                    return -1;
                }
                newindex = -1;
                functionIndex--;
            }
            if (params > 1) {
                /// -1:new, -2: function, -3: otk
                int ret = ipc_copy(src, oldindex, dest);
                if (ret != IPC_OK) {
                    lua_pop(dest, 3);
                    IPC_RESULT(ret);
                    luaL_error(src, "callback failed, msg: %s, target(%s): %s",
                               msg, luaL_typename(src, -1), luaL_tolstring(src, -1, NULL));
                    return -1;
                }
                oldindex = -1;
                if (newindex < 0)
                    newindex --;
                functionIndex--;
            }
            if (functionIndex != -1) {
                /// push function
                lua_pushvalue(dest, functionIndex);
                if (newindex < 0)
                    newindex --;
                if (oldindex < 0)
                    oldindex --;
                /// -1:function, -2:old, -3:new, -4:function, -5:OTK
            } /// else -1: function, -2: OTK
        } /// else -1: function, -2:OTK
        _real_callback(dest, params, oldindex, newindex);
        if (functionIndex != -1) {
            /// at lease copy new
            /// -1:old, -2:new, -3:function, -4:OTK
            /// if params == 1 then newindex = -3 else newindex = -2
            lua_pop(dest, -newindex);
        } /// else -1:OTK
        return 1;
    }
    return 0;
}

typedef struct KeyTreeUD {
    lua_State *src;
    lua_State *dest;
    int *need_copy;
    int oldindex;
    int newindex;
    int OTKindex;
    char *nil_after_key;
} KTUD;

/**
 * 1、检查callback
 * 2、copy value or not
 * 3、根据find值，查询copy value中对应值，若非table，当nil处理
 * 4、回调
 * 5、保存copy value给下次使用
 * dest栈：进入时，无特殊
 *      出函数，根据ud->need_copy 增加一个新值或一个旧值
 * @return 0 继续遍历，1停止遍历
 */
static int _traverse_key_tree(const char *srckey, const char *find, void *ud) {
    static const int _max = 400;
    char key[_max];
    size_t src_len = strlen(srckey);
    size_t find_len = strlen(find);
    memcpy(key, srckey, src_len);
    key[src_len] = '.';
    memcpy(&key[src_len + 1], find, find_len);
    key[src_len + find_len + 1] = '\0';
    KTUD *ktud = (KTUD *) ud;
    if (ktud->nil_after_key[0] != '\0') {
        if (strstr(key, ktud->nil_after_key) == key) {
            return 0;
        }
    }

    lua_State *src = ktud->src;
    lua_State *dest = ktud->dest;
    int *need_copy = ktud->need_copy;
    int oldindex = ktud->oldindex;
    int newindex = ktud->newindex;
    int OTKindex = ktud->OTKindex;
    CHECK_STACK_START(dest);

    /// step 1
    lua_pushvalue(dest, OTKindex);
    /// -1: OTK
    int params = _get_callback_function(dest, key);
    if (!lua_isfunction(dest, -1)) {
        /// -1: OTK
        lua_pop(dest, 1);
        return 0;
    }
    /// -1: function, -2: OTK
    lua_remove(dest, -2);

    /// step 2
    /// -1: function
    int functionIndex = -1;
    int copy_count = 0;
    if (dest != src) {
        if (params > 0 && ((*need_copy) & 1) == 1) {
            int ret = ipc_copy(src, newindex, dest);
            if (ret != IPC_OK) {
                lua_pop(dest, 2);
                IPC_RESULT(ret);
                luaL_error(src, "callback failed, msg: %s, target(%s): %s",
                           msg, luaL_typename(src, -1), luaL_tolstring(src, -1, NULL));
                return 1;
            }
            newindex = -1;
            functionIndex--;
            *need_copy = (*need_copy) & 0x2;
            copy_count++;
        }
        if (params > 1 && ((*need_copy) & 2) == 2) {
            /// -1:new, -2: function, -3: otk
            int ret = ipc_copy(src, oldindex, dest);
            if (ret != IPC_OK) {
                lua_pop(dest, 3);
                IPC_RESULT(ret);
                luaL_error(src, "callback failed, msg: %s, target(%s): %s",
                           msg, luaL_typename(src, -1), luaL_tolstring(src, -1, NULL));
                return 1;
            }
            oldindex = -1;
            if (newindex < 0)
                newindex --;
            functionIndex--;
            *need_copy = (*need_copy) & 0x1;
            copy_count++;
        }
    }/// else -1: function no copy
    if (functionIndex != -1) {
        /// some value copy
        lua_pushvalue(dest, functionIndex);
        lua_remove(dest, functionIndex - 1);
        functionIndex = -1;
        int top = lua_gettop(dest);
        if (oldindex < 0) {
            ktud->oldindex = top + oldindex;
        }
        if (newindex < 0) {
            ktud->newindex = top + newindex;
        }
    }

    /// step 3 根据find值，查询copy value中对应值，若非table，当nil处理
    /// -1: function
    if (params > 0) {
        /// 需要新值，取
        int ret = _get_table_by_key(dest, find, ktud->newindex, NULL);
        /// -1: value, -2: function
        if (ret != 0) {
            lua_pop(dest, 2);
            lua_pushnil(dest);
            memcpy(ktud->nil_after_key, srckey, src_len);
            ktud->nil_after_key[src_len] = '.';
            memcpy(&ktud->nil_after_key[src_len+1], find, find_len);
            ktud->nil_after_key[src_len + find_len + 1] = '\0';
            CHECK_STACK_END(dest, copy_count);
            return 0;
        }
        /// -1: value, -2: function
        newindex = -1;
        functionIndex --;
    }
    if (params > 1) {
        /// 需要新值，取
        int ret = _get_table_by_key(dest, find, ktud->oldindex, NULL);
        /// -1: value, -2: function
        if (ret != 0) {
            lua_pop(dest, 1);
            lua_pushnil(dest);
        }
        oldindex = -1;
        newindex --;
        functionIndex --;
    }
    if (functionIndex != -1) {
        /// at lease copy new
        /// push function
        lua_pushvalue(dest, functionIndex);
        oldindex --;
        newindex --;
    } /// else -1:function no copy

    /// -1: function
    /// step 4
    _real_callback(dest, params, oldindex, newindex);
    /// do copy before, so remove function
    if (functionIndex != -1)
        lua_remove(dest, functionIndex);
    if (params > 1) {
        lua_pop(dest, 2);
    } else if (params > 0) {
        lua_pop(dest, 1);
    }

    CHECK_STACK_END(dest, copy_count);
    return 0;
}
/**
 * 调用lua函数通知数据改变
 * 查找目标虚拟机的key Tree，回调_DC->key及后续所有的监听
 * @param l 目标虚拟机
 * @param ud _DC
 * @return 0继续遍历
 *
 * 1、查找对应的key回调
 * 2、OTK中查找对应key Tree
 * 3、复制旧值和新值
 * 4、调用函数
 */
static int _callbackTraverse(const void *l, void *ud) {
    lua_State *dest = (lua_State *) l;
    CheckThread(dest);
    _DC *dc = (_DC *) ud;
    CHECK_STACK_START(dc->L);
    int oldTop = lua_gettop(dest);

    /// step 1
    lua_getglobal(dest, OBSERVER_TABLE_KEY);
    if (!lua_istable(dest, -1)) {
        lua_settop(dest, oldTop);
        CHECK_STACK_END_O(dest, oldTop, 0);
        CHECK_STACK_END(dc->L, 0);
        return 0;
    }
    /// -1: OTK
    /// 直接查找callback，并回调
    _check_and_callback(dc->L, dest, dc->key, dc->oldIndex, dc->newIndex);

    /// step 2
    /// -1: OTK
    lua_rawgeti(dest, -1, 1);
    Tree *key_tree = NULL;
    if (lua_isuserdata(dest, -1)) {
        key_tree = lua_touserdata(dest, -1);
    }
    ///没有key tree的情况下
    if (!key_tree) {
        lua_pop(dest, 2);
        return 0;
    }
    lua_pop(dest, 1);

    /// -1: OTK
    /*0x01: copy new, 0x02: copy old*/
    int need_copy = 3;
    char nil_after_key[400] = {0};
    KTUD ktud = {dc->L, dest, &need_copy, dc->oldIndex, dc->newIndex, lua_gettop(dest), nil_after_key};
    tree_traverse(key_tree, _traverse_key_tree, dc->key, &ktud);
    if ((need_copy & 1) == 0) {
        /// copy new
        lua_remove(dest, ktud.newindex);
    }
    if ((need_copy & 2) == 0) {
        /// copy old
        lua_remove(dest, ktud.oldindex);
    }
    lua_pop(dest, 1);
    CHECK_STACK_END_O(dest, oldTop, 0);
    CHECK_STACK_END(dc->L, 0);
    return 0;
}

//</editor-fold>

//<editor-fold desc="i/pairs start">
/**
 * oldtable被新表包装，无法i\pairs()
 * 这里在原表中插入代理方法。替换为oldtable
 */
static void insertFunction(lua_State *L, const char *method, lua_CFunction iter) {
    CHECK_STACK_START(L);
    if (!luaL_getmetafield(L, -2, method)) {  /* no metamethod? */
        lua_pushstring(L, method);
        lua_pushcfunction(L, iter);  /* will return generator, */
        lua_rawset(L, -3);
    }
    CHECK_STACK_END(L, 0);
}

static int ipairsaux(lua_State *L) {
    int i = luaL_checkint(L, 2);
    luaL_checktype(L, 1, LUA_TTABLE);
    i++;  /* next value */

    lua_pushinteger(L, i);
    lua_rawgeti(L, 1, i);
    return (lua_isnil(L, -1)) ? 1 : 2;
}

static int luaB_next(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_settop(L, 2);  /* create a 2nd argument if there isn't one */

    if (lua_next(L, 1))
        return 2;
    else {
        lua_pushnil(L);
        return 1;
    }
}

static int pairsmeta(lua_State *L, int iszero, lua_CFunction iter) {
    lua_getmetatable(L, 1);
    lua_pushcfunction(L, iter);
    lua_getfield(L, -2, LUA_INDEX_KEY);

    if (iszero) lua_pushinteger(L, 0);  /* and initial value */
    else lua_pushnil(L);

    // -1: key -2: oldtable -3: func -4: metatable -5: source table
    return 3;
}

/**
 *   代理i/pairs方法
 */
static int luaB_pairs(lua_State *L) {
    return pairsmeta(L, 0, luaB_next);
}

static int luaB_ipairs(lua_State *L) {
    return pairsmeta(L, 1, ipairsaux);
}
//</editor-fold>

//<editor-fold desc="mock other function">
/**
 * __newindex对应的lua函数
 * 参数为: table,参数名称,值
 * upvalue: parentkey
 * 1、拿到原值
 * 2、设置新值
 * 3、查找callback，并回调
 */
static int __newindexCallback(lua_State *L) {
    CHECK_STACK_START(L);
    /// step 1 拿到原值
    lua_getmetatable(L, 1);
    lua_getfield(L, -1, LUA_INDEX_KEY);
    /// -1: source table, -2:mt
    lua_pushvalue(L, 2);
    lua_gettable(L, -2);
    /// -1: old data ; -2: source table, -3:mt

    /// step 2 设置新值 source_table[v_in_2]=v_in_3
    lua_pushvalue(L, 2);
    lua_pushvalue(L, 3);
    lua_settable(L, -4);
    /// -1: old data ; -2: source table -3:mt

    lua_getfield(L, -3, OBSERVER_TABLE_IGNORE_FLAG);
    //-1:flag -2: old data ; -3: source table -4:mt
    if (lua_toboolean(L, -1) == 1) {
        lua_pop(L, 4);
        CHECK_STACK_END(L, 0);
        return 0;
    }
    lua_pop(L, 1);
    /// -1: old data ; -2: source table -3:mt
    int changeType = 0;
    lua_getfield(L, -3, OBSERVER_TABLE_CHANGE_TYPE_FLAG);
    //-1:changeType -2: old data ; -3: source table -4:mt
    if (lua_isnumber(L, -1)) {
        changeType = lua_tointeger(L, -1);//操作类型
    }
    lua_pop(L, 1);
    lua_remove(L, -2);
    lua_remove(L, -2);
    /// -1: old data

    /// step 3 查询最根层key，找到所有虚拟机，并根据当前key，callback所有后级key
    /// root key: 最根层key，不含'.'
    /// key: 当前key，被修改的值的key，含有'.'
    const char *parent = luaL_checkstring(L, lua_upvalueindex(1));
    const size_t LEN = 300;
    char key[LEN];
    lua_pushvalue(L, 2);
    join_3string(parent, ".", lua_tostring(L, -1), key, LEN);
    lua_pop(L, 1);
    char *dot_index = strchr(parent, '.');
    char root_key[100] = {0};
    if (dot_index) {
        memcpy(root_key, parent, dot_index - parent);
    } else {
        memcpy(root_key, parent, strlen(parent));
    }

    List *list = (List *) map_get(instance->key_observer, root_key);
    if (list) {
        /// -1: old data
        _DC ud = {L, lua_gettop(L), 3, key, root_key, changeType};
        list_traverse(list, _callbackTraverse, &ud);
    }
    /// -1: source data
    lua_pop(L, 1);
    CHECK_STACK_END(L, 0);

    return 0;
}

/**
 * __len对应的lua函数
 * 参数为: table
 * 1、拿到原值
 * 2、获取长度
 */
static int __lenFunction(lua_State *L) {
    CHECK_STACK_START(L);
    /// step 1
    lua_getmetatable(L, 1);
    lua_getfield(L, -1, LUA_INDEX_KEY);
    lua_remove(L, -2);
    /// -1: source table
    /// step 2
    size_t len = lua_objlen(L, -1);
    lua_pop(L, 1);
    lua_pushinteger(L, len);
    CHECK_STACK_END(L, 1);

    return 1;
}
//</editor-fold>

//<editor-fold desc="observable table">
/**
 * 使用新表代替旧表，设置flag、设置__index为原表、__newindex为callback函数，设置metatable
 * 遍历子节点，并将所有table都设置上
 */
static void createObservableTable(lua_State *L, const char *key, int tableIndex, int check) {
    CHECK_STACK_START(L);
    if (check) {
        lua_getfield(L, tableIndex, OBSERVABLE_TABLE_FLAG);
        if (!lua_isnil(L, -1)) {
            lua_pop(L, 1);
            CHECK_STACK_END(L, 0);
            luaL_error(L, "不能将已经绑定过的table");
            return;
        }
        lua_pop(L, 1);
    }

    /// 遍历子节点，若子节点是table，则将它改成可观察表
    int realIndex = tableIndex < 0 ? lua_gettop(L) + tableIndex + 1 : tableIndex;
    const int SIZE = 300;
    int keyType;
    char childKey[SIZE] = {0};
    lua_Number kn;
    lua_Integer ki;
    lua_pushnil(L);
    while (lua_next(L, realIndex)) {
        if (lua_istable(L, -1)) {
            keyType = lua_type(L, -2);
            if (keyType == LUA_TNUMBER) {
                kn = lua_tonumber(L, -2);
                ki = lua_tointeger(L, -2);
                if (kn == ki) {
                    format_string(childKey, SIZE, "%s.%d", key, ki);
                } else {
                    format_string(childKey, SIZE, "%s.%f", key, kn);
                }
            } else {
                join_3string(key, ".", lua_tostring(L, -2), childKey, SIZE);
            }
            lua_pushvalue(L, -2);
            /// -1: key, -2 value table, -3: key
            createObservableTable(L, childKey, -2, 1);
            /// -1: new talbe, -2: key, -3: value table, -4: key
            lua_rawset(L, realIndex);
        }
        lua_pop(L, 1);
    }

    /// 创建需要返回的table
    lua_newtable(L);
    /// 创建metatable
    /// { __OATF = true, __index = oldtable, __newindex = callback, __len = __lenFunction}
    lua_createtable(L, 0, 3);

    /// __OATF = true
    lua_pushstring(L, OBSERVABLE_TABLE_FLAG);
    lua_pushboolean(L, 1);
    lua_rawset(L, -3);
    /// __index = oldtable
    lua_pushstring(L, LUA_INDEX_KEY);
    lua_pushvalue(L, realIndex);
    lua_rawset(L, -3);
    /// __newindex = callback
    lua_pushstring(L, LUA_NEWINDEX_KEY);
    lua_pushstring(L, key);
    lua_pushcclosure(L, __newindexCallback, 1);
    lua_rawset(L, -3);
    /// __len = __lenFunction
    lua_pushstring(L, LUA_LEN_KEY);
    lua_pushcfunction(L, __lenFunction);
    lua_rawset(L, -3);

    //插入ipairs、pairs方法. lbaselib.c的相关方法会掉到这里
    insertFunction(L, LUA_IPAIRS_KEY, luaB_ipairs);
    insertFunction(L, LUA_PAIRS_KEY, luaB_pairs);

    /// -1: metatable -2: table
    lua_setmetatable(L, -2);
    CHECK_STACK_END(L, 1);
}

/**
 * 在虚拟机中的OATK表中找到对应key的表，并放入栈顶
 */
static inline void getObservableTable(lua_State *L, const char *key) {
    CHECK_STACK_START(L);
    lua_getglobal(L, OBSERVABLE_TABLE_KEY);
    if (!lua_istable(L, -1)) {
        if (!lua_isnil(L, -1)) {
            lua_pop(L, 1);
            lua_pushnil(L);
        }
        CHECK_STACK_END(L, 1);
        /// 栈顶是nil
        return;
    }
    /// -1: OATK表
    lua_getfield(L, -1, key);
    lua_remove(L, -2);
    CHECK_STACK_END(L, 1);
}
//</editor-fold>
//</editor-fold>

//<editor-fold desc="static">
/**
 * 查找OATK表中，找到key对应的表，并放入栈顶
 * 正确返回，栈顶为为table
 * 如果未找到，返回NULL，并将错误信息以string的形式push到L栈顶
 */
static inline lua_State *DB_findTarget(lua_State *L, const char *key, char **sec_key) {
    const size_t SIZE = 100;
    char realKey[SIZE] = {0};
    size_t keyLen = strlen(key);
    /// step 1
    char *dot = strchr(key, '.');
    if (dot) {
        memcpy(realKey, key, dot - key);
    } else {
        memcpy(realKey, key, keyLen);
    }
    lua_State *target = (lua_State *) map_get(instance->key_observable, (void *) realKey);
    if (!target) {
        lua_pushfstring(L, "key \"%s\"(from key \"%s\") has no binding data", realKey, key);
        return NULL;
    }
    CheckThread(target);
    CHECK_STACK_START(target);
    /// step 2
    getObservableTable(target, (const char *) realKey);
    if (!lua_istable(target, -1)) {
        lua_pushfstring(L, "binding data \"%s\" is not a table, but a \"%s\"",
                        (const char *) realKey,
                        luaL_typename(target, -1));
        lua_pop(target, 1);
        CHECK_STACK_END(target, 0);
        return NULL;
    }
    /// 多级情况,index= '.'后第一位
    if (dot) {
        if (sec_key)
            *sec_key = &dot[1];
    } else {
        if (sec_key)
            *sec_key = NULL;
    }
    /// -1:table
    CHECK_STACK_END(target, 1);
    return target;
}

/**
 * 保存：在原表中保存flag
 * metaIndex < 0
 */
static inline void saveFlagInMetaTable(lua_State *target, const char *flag, int value, int metaIndex) {
    CHECK_STACK_START(target);
    ///-1:metatable
    lua_pushstring(target, flag);//操作类型保存

    if (strcmp(flag, OBSERVER_TABLE_IGNORE_FLAG) == 0) {
        lua_pushboolean(target, value);
    } else if (strcmp(flag, OBSERVER_TABLE_CHANGE_TYPE_FLAG) == 0) {
        lua_pushinteger(target, value);
    } else {
        lua_pop(target, 1);
        CHECK_STACK_END(target, 0);
        return;
    }
    lua_settable(target, metaIndex - 2);
    CHECK_STACK_END(target, 0);
}

/**
 * 移除：在原表中的flag
 */
static inline void removeFlagInMetaTable(lua_State *target, const char *flag, int metaIndex) {
    CHECK_STACK_START(target);
    ///-1:metatable
    lua_pushstring(target, flag);//移除操作类型
    if (strcmp(flag, OBSERVER_TABLE_IGNORE_FLAG) == 0) {
        lua_pushboolean(target, 0);
    } else if (strcmp(flag, OBSERVER_TABLE_CHANGE_TYPE_FLAG)==0) {
        lua_pushnil(target);
    } else {
        lua_pop(target, 1);
        CHECK_STACK_END(target, 0);
        return;
    }

    lua_settable(target, metaIndex - 2);
    CHECK_STACK_END(target, 0);
}

/**
 * DB_Insert方法中，对插入的位置元素赋值，并替换元表
 * in statck: -1:value -2:metatable -3: childtable
 * return statck: -1:metatable -2: childtable
 */
static inline void replaceMetaTable(lua_State *target, const char *key, int insertindex) {
    CHECK_STACK_START(target);
    ///-1:value -2:metatable -3: childtable
    if (lua_istable(target, -1)) {//更新table，替换为observableTable
        createObservableTable(target, key, -1, 0);
        ///-1:newTable -2:value -3:metatable -4: childtable
        lua_pushinteger(target, insertindex);
        //-1:insertindex -2:newTable -3:value -4:metatable -5:childtable
        lua_pushvalue(target, -2);
        //-1:newTable -2:insertindex -3:newTable -4:value -5:metatable -6:childtable
        lua_settable(target, -6);
        lua_pop(target, 2);//-1:metatable -2:childtable
    } else {
        lua_pushinteger(target, insertindex);
        //-1:insertindex -2:value -3:metatable -4:childtable
        lua_pushvalue(target, -2);
        //-1:value -2:insertindex -3:value -4:metatable -5:childtable
        lua_settable(target, -5);
        lua_pop(target, 1);
    }
    CHECK_STACK_END(target, 0);
}

/**
 * 记录key对应的虚拟机 (key_observer)
 * 记录方式为: key->List(lua_State)
 */
static inline int _record_observer(lua_State *L, const char *key) {
    List *list = map_get(instance->key_observer, key);
    if (!list) {
        list = list_new(instance->alloc, 5, 0);
        if (!list) {
            luaL_error(L, "cannot watch \"%s\" because no memory");
            return 0;
        }
        map_put(instance->key_observer, (void *) copystr(key), list);
    } else if (list_index(list, L) < list_size(list)) {
        /// 已存储
        return 1;
    }
    list_add(list, L);
    /*记录虚拟机中所有的key值 map[L] = List(keys)*/
    saveVmKey(L, key);
    return 0;
}
//</editor-fold>

//<editor-fold desc="instance 操作">
/**
 * 1、从vm_key中查找虚拟机相关缓存
 * 2、遍历缓存key，并从两个表中删除
 * 3、释放list
 */
void DB_Close(lua_State *L) {
    if (!instance) return;
    lua_getglobal(L, OBSERVER_TABLE_KEY);
    /// -1: OTK
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
    } else {
        lua_rawgeti(L, -1, 1);
        Tree *tree = NULL;
        if (lua_isuserdata(L, -1)) {
            tree = (Tree *) lua_touserdata(L, -1);
        }
        lua_pop(L, 2);
        if (tree)
            tree_free(tree);
    }
    List *list = map_remove(instance->vm_key, L);
    if (!list)
        return;
    CHECK_STACK_START(L);
    list_traverse(list, _freeTraverse, L);
    list_free(list);
    CHECK_STACK_END(L, 0);
}

/**
 * 1、将key和虚拟机关联起来放入 key_observable 中
 * 2、在虚拟机中将key和table关联，并替换table，放入栈顶
 */
void DB_Bind(lua_State *L, const char *key, int valueIndex) {
    _check_instance(L);
    if (strchr(key, '.')) {
        luaL_error(L, "cannot has '.' in key \"%s\"", key);
    }
    /// step 1
    char *copy_str = copystr(key);
    lua_State *old = (lua_State *) map_put(instance->key_observable, (void *) copy_str, L);
    if (old) {
        instance->alloc(copy_str, (strlen(copy_str) + 1) * sizeof(char), 0);
        /// 如果是覆盖的情况
        if (old != L) {
            luaL_error(L, "key \"%s\" has already bind data", key);
            return;
        }
    } else {
        saveVmKey(L, key);
    }
    ///step 2
    /**
     * 针对需要观察的表，在虚拟机全局表中设定一个特殊表来记录(OATK)，并将新表放入栈顶
     * 记录方式为: key->table
     * 1、先使用新表代替旧表，设置flag、设置__index为原表、__newindex为callback函数，设置metatable
     * 2、在全局表中记录key->table
     */
    CHECK_STACK_START(L);
    /// step 1
    lua_getfield(L, valueIndex, OBSERVABLE_TABLE_FLAG);
    if (!lua_isnil(L, -1)) {
        /// 这个table已经被绑定了，不用管
        lua_pop(L, 1);
        lua_pushvalue(L, valueIndex);
        CHECK_STACK_END(L, 1);
        return;
    }
    lua_pop(L, 1);
    createObservableTable(L, key, valueIndex, 0);
    ///-1: newtable

    /// step 2
    lua_getglobal(L, OBSERVABLE_TABLE_KEY);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 0, 5);
        lua_pushvalue(L, -1);
        lua_setglobal(L, OBSERVABLE_TABLE_KEY);
    }
    /// -1: OATK表, -2:newtable
    lua_pushvalue(L, -2);
    lua_setfield(L, -2, key);
    lua_pop(L, 1);
    CHECK_STACK_END(L, 1);
}

/**
 * 针对观察者，在虚拟机全局表中设定一个特殊表来记录(OTK)
 * 记录方式为: key->{function, type}
 * 并且记录key对应的虚拟机 (key_observer)
 * 记录方式为: key->List(lua_State)
 * 当key中有多级时(包含.)，记录最初级key对应当前虚拟机(key_observer)
 * 记录方式: key->List(lua_State)
 *
 * @param key model名称
 * @param type 类型，取值范围[0,2] (对应后续回调参数个数) | CALLBACK_PARAMS_TYPE(watchTable回调函数type，返回change_key、type、old、new)
 * @param functionIndex lua回调函数栈位置
 * @type 返回参数数量
 */
void DB_Watch(lua_State *L, const char *key, int type, int functionIndex) {
    _check_instance(L);
    CHECK_STACK_START(L);
    /// 记录回调
    lua_getglobal(L, OBSERVER_TABLE_KEY);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 0, 5);
        lua_pushvalue(L, -1);
        lua_setglobal(L, OBSERVER_TABLE_KEY);
    }
    /*OTK[key] = {callback, type}*/
    /// stack: OTK
    lua_createtable(L, 2, 0);
    lua_pushvalue(L, functionIndex);
    lua_rawseti(L, -2, 1);
    lua_pushinteger(L, type);
    lua_rawseti(L, -2, 2);
    /// -1: {function, type}, -2: OTK
    lua_setfield(L, -2, key);
    /// stack: OTK

    /*记录观察者虚拟机 (instance->key_observer[key]).add(L)*/
    /// stack: OTK
    if (_record_observer(L, key)) {
        /// 已存储
        lua_pop(L, 1);
        CHECK_STACK_END(L, 0);
        return;
    }

    /*多级key的情况，记录最初级key，并记录key tree*/
    char *dot = strchr(key, '.');
    if (dot) {
        char parent[50] = {0};
        memcpy(parent, key, dot - key);
        _record_observer(L, parent);

        /// stack: OTK
        lua_rawgeti(L, -1, 1);
        Tree *tree;
        if (!lua_isuserdata(L, -1)) {
            lua_pop(L, 1);
            tree = tree_new(instance->alloc);
            if (!tree) {
                luaL_error(L, "watch \'%s\' failed, no memory!", key);
                return;
            }
            lua_pushlightuserdata(L, tree);
            lua_rawseti(L, -2, 1);
        } else {
            tree = (Tree *) lua_touserdata(L, -1);
            lua_pop(L, 1);
        }
        tree_save(tree, key);
    }
    lua_pop(L, 1);
    CHECK_STACK_END(L, 0);
}

/**
 * 释法监听table
 */
void DB_UnWatch(lua_State *L, const char *key) {
    _check_instance(L);
    CHECK_STACK_START(L);
    //移除key_observer的keyList中的虚拟机缓存
    if (instance->key_observer) {
        List *list = map_get(instance->key_observer, key);
        if (list) {
            list_remove_obj(list, L);
            if (!list_size(list)) {
                map_remove(instance->key_observer, key);
                list_free(list);
            }
        }
    }
    //移除vm_key中的key缓存
    List *keyList = map_get(instance->vm_key, L);
    if (keyList) {
        size_t index = list_index(keyList, (void *) key);
        if (index < list_size(keyList)) {//key存在
            void *realkey = list_get(keyList, index);
            list_remove(keyList, index);

            instance->alloc(realkey, (strlen(realkey) + 1) * sizeof(char), 0);
        }

        if (!list_size(keyList)) {
            map_remove(instance->vm_key, L);
            list_free(keyList);
        }
    }
    /// 移除key tree
    lua_getglobal(L, OBSERVER_TABLE_KEY);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
    } else {
        lua_rawgeti(L, -1, 1);
        Tree *tree = NULL;
        if (lua_isuserdata(L, -1)) {
            tree = (Tree *) lua_touserdata(L, -1);
        }
        lua_pop(L, 1);
        if (tree) {
            tree_remove(tree, key);
        }
    }
    CHECK_STACK_END(L, 0);
}

/**
 * 1、查找被观察数据，key值可能需要拆分
 * 2、若查找到，通过lua rpc将数据复制到被观察虚拟机中，并设置值
 */
void DB_Update(lua_State *L, const char *key, int valueIndex) {
    _check_instance(L);
    CHECK_STACK_START(L);
    char *sec_key = NULL;
    lua_State *target = DB_findTarget(L, key, &sec_key);
    if (!target) {
        lua_error(L);
        return;
    }
    CheckThread(target);
#ifdef J_API_INFO
    int _tot = lua_gettop(target) - 1;
#endif
    ///target -1:table
    if (!sec_key) {
        lua_pop(target, 1);
        CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
        luaL_error(L, "cannot update \"%s\"(first level) binding data!", key);
        return;
    }
    /// -1: table
    int last_key_start = 0;
    int ret = _get_table_by_key(target, sec_key, -1, &last_key_start);
    /// -1: value, -2: table
    if (ret != 0) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        char fir_key[100];
        memcpy(fir_key, key, (sec_key - key));
        luaL_error(L, "error update binding data by \"%s\", cause \"%s%s\" is not a table but a %s",
                key, fir_key, sec_key, tn);
        return;
    }
    lua_pop(target, 1);
    /// -1: table

    lua_getmetatable(target, -1);
    saveFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, LUA_CHANGE_TYPE_UPDATE, -1);
    lua_pop(target, 1);
    ///target -1:table
    if (L == target) {
        lua_pushvalue(L, valueIndex);
    } else {
        int ret = ipc_copy(L, valueIndex, target);
        if (ret != IPC_OK) {
            const char *tn = luaL_typename(L, valueIndex);
            const char *vs = luaL_tolstring(L, valueIndex, NULL);
            lua_pop(target, 2);
            CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
            CHECK_STACK_END_O(target, _tot, 0);
#endif
            IPC_RESULT(ret);
            luaL_error(L, "update by key(\"%s\") failed ipc copy, msg: %s, target(%s): %s",
                       key, msg, tn, vs);
            return;
        }
    }

    //-1:value -2:table
    int num;
    if (string_to_int(&sec_key[last_key_start], &num)) {
        lua_pushinteger(target, num);
    } else {
        lua_pushstring(target, &sec_key[last_key_start]);
    }
    //-1: key -2:value -3:table
    if (lua_istable(L, -2)) {//更新table，替换为observableTable
        createObservableTable(target, key, -2, 0);
        ///-1:newTable -2:key -3:value -4: table
        lua_settable(target, -4);//-1:value -2:table
        lua_pop(target, 1);
    } else {
        lua_pushvalue(target, -2);
        lua_settable(target, -4);
        lua_pop(target, 1);
    }

    ///-1:table
    lua_getmetatable(target, -1);//-1:metatable -2:table
    removeFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, -1);

    lua_pop(target, 2);
    CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
    CHECK_STACK_END_O(target, _tot, 0);
#endif
}

/**
 * 1、查找被观察数据，key值可能需要拆分
 * 2、若查找到，通过lua rpc将数据复制到被观察虚拟机中
 */
void DB_Get(lua_State *L, const char *key) {
    _check_instance(L);
    CHECK_STACK_START(L);
    char *sec_key = NULL;
    lua_State *target = DB_findTarget(L, key, &sec_key);
    if (!target) {
        lua_error(L);
        return;
    }
    CheckThread(target);
#ifdef J_API_INFO
    int _tot = lua_gettop(target) - 1;
#endif
    int ret = _get_table_by_key(target, sec_key, -1, NULL);
    /// -1: value, -2: table
    if (ret != 0) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        char fir_key[100];
        memcpy(fir_key, key, (sec_key - key));
        luaL_error(L, "error get binding data by \"%s\", cause \"%s%s\" is not a table but a %s",
                   key, fir_key, sec_key, tn);
        return;
    }
    /// -1: value, -2: table
    ///table 特殊处理，提取出metatable的__index
    if (lua_istable(target, -1)
        && lua_getmetatable(target, -1)) {
        /// -1:metatable -2: value -3: table
        lua_getfield(target, -1, LUA_INDEX_KEY);
        lua_remove(target, -2);//remove metatalbe
        lua_remove(target, -2);//remove value
    }
    /// -1: value -2:table
    if (target != L) {//不同虚拟机
        int ret = ipc_copy(target, -1, L);
        if (ret != IPC_OK) {
            const char *tn = luaL_typename(target, -1);
            const char *vs = luaL_tolstring(target, -1, NULL);
            lua_pop(target, 2);
            CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
            CHECK_STACK_END_O(target, _tot, 0);
#endif
            IPC_RESULT(ret);
            luaL_error(L, "get by key(\"%s\") failed ipc copy, msg: %s, target(%s): %s",
                    key, msg, tn, vs);
            return;
        }
        lua_pop(target, 2);
        CHECK_STACK_END(L, 1);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
    } else {
        lua_remove(L, -2);
        // -1: value
        CHECK_STACK_END(L, 1);
    }
}

/**
 * 1、查找被观察数据，key值可能需要拆分
 * 2、若查找到，通过lua rpc将数据复制到被观察虚拟机中
 */
void DB_Insert(lua_State *L, const char *key, int insertindex, int valueIndex) {
    _check_instance(L);
    CHECK_STACK_START(L);
    char *sec_key = NULL;
    lua_State *target = DB_findTarget(L, key, &sec_key);
    if (!target) {
        lua_error(L);
        return;
    }
    CheckThread(target);
#ifdef J_API_INFO
    int _tot = lua_gettop(target) - 1;
#endif
    ///target -1:table
    if (!sec_key) {
        lua_pop(target, 1);
        CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
        luaL_error(L, "cannot insert \"%s\"(first level) binding data!", key);
        return;
    }
    /// -1: table
    int last_key_start = 0;
    int ret = _get_table_by_key(target, sec_key, -1, &last_key_start);
    /// -1: value, -2: table
    if (ret != 0) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        char fir_key[100];
        memcpy(fir_key, key, (sec_key - key));
        luaL_error(L, "error insert binding data by \"%s\", cause \"%s%s\" is not a table but a %s",
                   key, fir_key, sec_key, tn);
        return;
    }
    if (!lua_istable(target, -1)) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        luaL_error(L, "error insert binding data by \"%s\", cause it is not a table but a %s",
                   key, tn);
        return;
    }
    lua_remove(target, -2);
    /// -1: valuetable

    int curlen = luaL_len(target, -1);
    /// -1: valuetable
    if (insertindex < 0 || insertindex > curlen) {//末尾插入
        insertindex = curlen + 1;
        lua_getmetatable(target, -1);//-1:metatable -2: childtable
        saveFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, LUA_CHANGE_TYPE_INSERT, -1);
        if (L == target) {
            lua_pushvalue(L, valueIndex);
        } else {
            int ret = ipc_copy(L, valueIndex, target);
            if (ret != IPC_OK) {
                const char *tn = luaL_typename(target, valueIndex);
                const char *vs = luaL_tolstring(target, valueIndex, NULL);
                lua_pop(target, 3);
                CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
                CHECK_STACK_END_O(target, _tot, 0);
#endif
                IPC_RESULT(ret);
                luaL_error(L, "insert by key(\"%s\") failed ipc copy, msg: %s, target(%s): %s",
                           key, msg, tn, vs);
                return;
            }
        }
        ///-1:value -2:metatable -3: childtable
        replaceMetaTable(target, key, insertindex);//替换元表，监听table
        ///-1:metatable -2:childtable
        removeFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, -1);
        lua_pop(target, 2);
        CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
        return;
    }

    /// -1: valuetable
    lua_getmetatable(target, -1);//-1:metatable -2: childtable
    saveFlagInMetaTable(target, OBSERVER_TABLE_IGNORE_FLAG, LUA_CHANGE_TYPE_INSERT, -1);
    lua_pop(target, 1);
    /// -1: childtable
    for (int i = curlen + 1; i > insertindex; --i) {
        //向后移动值
        lua_pushinteger(target, i);//-1:toIndex -2: childtable
        lua_pushinteger(target, i - 1);//-1:fromIndex -2:toIndex -3: childtable
        lua_gettable(target, -3);//-1:value -2:toIndex -3: childtable
        lua_settable(target, -3);// -1: childtable -2:table

        //遍历到insert位置，赋值
        if (i - 1 == insertindex) {
            lua_getmetatable(target, -1);//-1:metatable -2: childtable
            removeFlagInMetaTable(target, OBSERVER_TABLE_IGNORE_FLAG, -1);
            saveFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, LUA_CHANGE_TYPE_INSERT,
                                -1);
            if (L == target) {
                lua_pushvalue(L, valueIndex);
            } else {
                ///-1:metatable -2: childtable
                int ret = ipc_copy(L, valueIndex, target);
                if (ret != IPC_OK) {
                    const char *tn = luaL_typename(target, valueIndex);
                    const char *vs = luaL_tolstring(target, valueIndex, NULL);
                    lua_pop(target, 3);
                    CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
                    CHECK_STACK_END_O(target, _tot, 0);
#endif
                    IPC_RESULT(ret);
                    luaL_error(L, "insert by key(\"%s\") failed ipc copy, msg: %s, target(%s): %s",
                               key, msg, tn, vs);
                    return;
                }
            }
            ///-1:value -2:metatable -3: childtable
            replaceMetaTable(target, key, insertindex);//替换元表，监听table
            ///-1:metatable -2:childtable
            removeFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, -1);
            lua_pop(target, 1);//-1: childtable
        }
    }
    lua_pop(target, 1);
    CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
    CHECK_STACK_END_O(target, _tot, 0);
#endif
}

/**
 * 1、查找被观察数据，key值可能需要拆分
 * 2、若查找到，通过lua rpc将数据复制到被观察虚拟机中
 */
void DB_Remove(lua_State *L, const char *key, int removeIndex) {
    _check_instance(L);
    CHECK_STACK_START(L);
    char *sec_key = NULL;
    lua_State *target = DB_findTarget(L, key, &sec_key);
    if (!target) {
        lua_error(L);
        return;
    }
    CheckThread(target);
#ifdef J_API_INFO
    int _tot = lua_gettop(target) - 1;
#endif
    ///target -1:table
    if (!sec_key) {
        lua_pop(target, 1);
        CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
        luaL_error(L, "cannot remove \"%s\"(first level) binding data!", key);
        return;
    }
    /// -1: table
    int last_key_start = 0;
    int ret = _get_table_by_key(target, sec_key, -1, &last_key_start);
    /// -1: value, -2: table
    if (ret != 0) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        char fir_key[100];
        memcpy(fir_key, key, (sec_key - key));
        luaL_error(L, "error remove binding data by \"%s\", cause \"%s%s\" is not a table but a %s",
                   key, fir_key, sec_key, tn);
        return;
    }
    if (!lua_istable(target, -1)) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        luaL_error(L, "error remove binding data by \"%s\", cause it is not a table but a %s",
                   key, tn);
        return;
    }
    lua_remove(target, -2);
    /// -1: valuetable

    lua_getmetatable(target, -1);//-1:metatable -2: valuetable
    saveFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, LUA_CHANGE_TYPE_REMOVE, -1);
    ///-1:metatable -2: childtable
    int curlen = luaL_len(target, -2);
    lua_pushinteger(target, removeIndex);//-1:removeIndex -2:metatable -3: childtable
    lua_pushnil(target);//-1:nil -2:removeIndex -3:metatable -4: childtable
    lua_settable(target, -4);// -1:metatable -2: childtable
    removeFlagInMetaTable(target, OBSERVER_TABLE_CHANGE_TYPE_FLAG, -1);
    lua_pop(target, 1);
    //-1: childtable
    if (removeIndex == curlen) {//末尾移除
        lua_pop(target, 1);
        CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
        return;
    }
    //-1: childtable
    lua_getmetatable(target, -1);//-1:metatable -2: childtable
    saveFlagInMetaTable(target, OBSERVER_TABLE_IGNORE_FLAG, LUA_CHANGE_TYPE_INSERT, -1);
    lua_pop(target, 1);
    /// -1: childtable
    for (int i = removeIndex; i <= curlen; ++i) {
        if (i + 1 <= curlen) {//非最后
            lua_pushinteger(target, i);     //-1:toIndex -2:childtable
            lua_pushinteger(target, i + 1); //-1:fromIndex -2:toIndex -3:childtable
            lua_gettable(target, -3);       //-1:value -2:toIndex -3:childtable
            lua_settable(target, -3);       // -1: childtable
        } else {//最后一个
            lua_pushinteger(target, i); //-1:removeIndex -2:childtable
            lua_pushnil(target);        //-1:nil -2:removeIndex -3:childtable
            lua_settable(target, -3);   // -1: childtable
        }
    }
    // -1: childtable
    lua_getmetatable(target, -1);//-1:metatable -2: childtable
    removeFlagInMetaTable(target, OBSERVER_TABLE_IGNORE_FLAG, -1);
    lua_pop(target, 2);
    CHECK_STACK_END(L, 0);
#ifdef J_API_INFO
    CHECK_STACK_END_O(target, _tot, 0);
#endif
}

/**
 * 1、查找被观察数据，key值可能需要拆分
 * 2、若查找到，通过lua rpc将数据复制到被观察虚拟机中
 */
void DB_Len(lua_State *L, const char *key) {
    _check_instance(L);
    CHECK_STACK_START(L);
    char *sec_key = NULL;
    lua_State *target = DB_findTarget(L, key, &sec_key);
    if (!target) {
        lua_error(L);
        return;
    }
    CheckThread(target);
#ifdef J_API_INFO
    int _tot = lua_gettop(target) - 1;
#endif
    int ret = _get_table_by_key(target, sec_key, -1, NULL);
    /// -1: value, -2: table
    if (ret != 0) {
        const char *tn = luaL_typename(target, -1);
        lua_pop(target, 2);
        char fir_key[100];
        memcpy(fir_key, key, (sec_key - key));
        luaL_error(L, "error get binding data len by \"%s\", cause \"%s%s\" is not a table but a %s",
                   key, fir_key, sec_key, tn);
        return;
    }
    /// -1: value, -2: table
    ///table 特殊处理，提取出metatable的__index
    if (lua_istable(target, -1)
        && lua_getmetatable(target, -1)) {
        /// -1:metatable -2: value -3: table
        lua_getfield(target, -1, LUA_INDEX_KEY);
        lua_remove(target, -2);//remove metatalbe
        lua_remove(target, -2);//remove value
    }
    /// -1: childtable -2:table
    int len = luaL_len(target, -1);

    if (target != L) {//不同虚拟机
        lua_pushinteger(L, len);//-1:len
        lua_pop(target, 2);
        CHECK_STACK_END(L, 1);
#ifdef J_API_INFO
        CHECK_STACK_END_O(target, _tot, 0);
#endif
    } else {
        lua_pop(L, 2);
        lua_pushinteger(L, len);// -1:len
        CHECK_STACK_END(L, 1);
    }
}
//</editor-fold>

//<editor-fold desc="instance free 操作">
/**
 * 释放map中key值内存
 */
static void _free_key(void *key) {
    if (instance) {
        const char *s = (const char *) key;
        size_t len = strlen(s) + 1;
        instance->alloc(key, len * sizeof(char), 0);
    } else {
        free(key);
    }
}

/**
 * 释放map中list值内存
 */
static void _free_list(void *v) {
    List *l = (List *) v;
    list_free(l);
}

static unsigned int _vm_hash(const void *vm) {
    return (unsigned int) vm;
}

static void _free_vm_list(void *v) {
    List *l = (List *) v;
    list_traverse(l, _freeTraverse, NULL);
    list_free(l);
}

/**
 * 释放instance
 */
void DataBindFree() {
    if (instance) {
        if (instance->key_observable) {
            map_free(instance->key_observable);
        }
        if (instance->key_observer) {
            map_free(instance->key_observer);
        }
        if (instance->vm_key) {
            map_free(instance->vm_key);
        }
        instance->alloc(instance, sizeof(DataBind), 0);
        instance = NULL;
    }
}
//</editor-fold>

int DataBindInit(D_malloc m) {
    if (instance)
        return 0;
    instance = (DataBind *) m(NULL, 0, sizeof(DataBind));
    if (!instance) {
        return 1;
    }
    instance->alloc = m;
    Map *temp = map_new(m, 10);
    if (!temp || map_ero(temp)) {
        if (temp) {
            map_free(temp);
        }
        DataBindFree();
        return 1;
    }
    map_set_free(temp, _free_key, NULL);
    instance->key_observable = temp;

    temp = map_new(m, 50);
    if (!temp || map_ero(temp)) {
        if (temp) {
            map_free(temp);
        }
        DataBindFree();
        return 1;
    }
    map_set_free(temp, _free_key, _free_list);
    instance->key_observer = temp;

    temp = map_new(m, 10);
    if (!temp || map_ero(temp)) {
        if (temp) {
            map_free(temp);
        }
        DataBindFree();
        return 1;
    }
    map_set_hash(temp, _vm_hash);
    map_set_equals(temp, NULL);
    map_set_free(temp, NULL, _free_vm_list);
    instance->vm_key = temp;

    return 0;
}