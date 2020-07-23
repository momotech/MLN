/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/6/5.
//

#include "LuaRPC.h"
#include <string.h>
#include "lobject.h"
#include "lstate.h"
#include "ltable.h"
#include "m_mem.h"
#include "lapi.h"

/// ---------------------------------------------------------------
/// 虚拟机之间差异
#if LUA_VERSION_NUM > 501   /**Lua 5.2 */
#define key2tval(n)         gkey(n)
#define rpc_setobj(obj1, obj2) \
    { const TValue *io2=(obj2); TValue *io1=(obj1); \
      io1->value_ = io2->value_; io1->tt_ = io2->tt_; \
      }
#else
#define api_incr_top(L)     {api_check(L, L->top < L->ci->top); L->top++;}
#define ttypenv(o)          ttype(o)
#define rpc_setobj(obj1,obj2) \
    { const TValue *io2=(obj2); TValue *io1=(obj1); \
      io1->value = io2->value; io1->tt = io2->tt; \
      }
#endif
/// ---------------------------------------------------------------

#define NONVALIDVALUE       cast(TValue *, luaO_nilobject)

static TValue *index2addr(lua_State *L, int idx);
static int copy_string(TValue *result, TValue *src);
static void free_string(TValue *val);
static int deep_copy_table(TValue *result, TValue *src);
static void free_table(TValue *val);
static void free_value(TValue *val);
static void push_table(lua_State *L, TValue *src);

/**
 * 将src数据复制到dest中
 * 仅支持boolean|number|string|table
 */
static int copy_value(TValue *dest, TValue *src) {
    int type = ttypenv(src);
    int ret = 0;
    switch (type) {
        case LUA_TNIL:
            setnilvalue(dest);
            ret = 0;
            break;
        case LUA_TBOOLEAN:
        case LUA_TNUMBER:
        case LUA_TLIGHTUSERDATA:
            rpc_setobj(dest, src);
            ret = 0;
            break;
        case LUA_TSTRING:
            ret = copy_string(dest, src);
            break;
        case LUA_TTABLE:
            ret = deep_copy_table(dest, src);
            break;
        default:
            setnilvalue(dest);
            return RPC_UNSUPPORTED_TYPE;
    }
    if (ret) {
        setnilvalue(dest);
    }
    return ret;
}
/**
 * 将内存中复制的数据push到虚拟机栈顶
 * 仅支持boolean|number|string|table
 */
static void push_value_to_state(lua_State *L, TValue *val) {
    int type = ttypenv(val);
    switch (type) {
        case LUA_TNIL:
            lua_pushnil(L);
            break;
        case LUA_TBOOLEAN:
            lua_pushboolean(L, bvalue(val));
            break;
        case LUA_TNUMBER:
            lua_pushnumber(L, nvalue(val));
            break;
        case LUA_TSTRING:
            lua_pushstring(L, svalue(val));
            break;
        case LUA_TTABLE:
            lua_newtable(L);
            push_table(L, val);
            break;
//        case LUA_TLIGHTUSERDATA:
//            lua_pushlightuserdata(L, pvalue(val));
//            break;
//        case LUA_TUSERDATA:
        default:
            break;
    }
}

int rpc_copy(lua_State *src, int index, lua_State *dest) {
    TValue *srcValue = index2addr(src, index);
    TValue *destValue = (TValue *) m_malloc(NULL, 0, sizeof(TValue));
    if (!destValue)
        return RPC_MEM_ERROR;
    int ret = copy_value(destValue, srcValue);
    if (ret) {
        m_malloc(destValue, sizeof(TValue), 0);
        return ret;
    }
    push_value_to_state(dest, destValue);
    free_value(destValue);
    m_malloc(destValue, sizeof(TValue), 0);
    return RPC_OK;
}

static void free_value(TValue *val) {
    switch (ttypenv(val)) {
        case LUA_TBOOLEAN:
        case LUA_TNUMBER:
        case LUA_TLIGHTUSERDATA:
            break;
        case LUA_TSTRING:
            free_string(val);
            break;
        case LUA_TTABLE:
            free_table(val);
            break;
        default:    //nil
            return;
    }
}

//<editor-fold desc="string copy free">

static int copy_string(TValue *result, TValue *src) {
    TString *ots = &val_(src).gc->ts;
    const char *str = svalue(src);
    size_t len = ots->tsv.len;
    size_t totalsize = sizeof(TString) + ((len + 1) * sizeof(char));
    GCObject *o = obj2gco(m_malloc(NULL, 0, totalsize));
    if (!o) return RPC_MEM_ERROR;
    gch(o)->tt = gch(val_(src).gc)->tt;
    TString *ts = &o->ts;
    ts->tsv.len = len;
    ts->tsv.hash = ots->tsv.hash;
#if LUA_VERSION_NUM > 501   /**Lua 5.2 */
    ts->tsv.extra = ots->tsv.extra;
#else                       /**Lua 5.1 */
    ts->tsv.reserved = ots->tsv.reserved;
#endif

    memcpy(ts + 1, str, len * sizeof(char));
    ((char *) (ts + 1))[len] = '\0';

    val_(result).gc = o;
    rttype(result) = rttype(src);
    return RPC_OK;
}

static void free_string(TValue *val) {
    GCObject *o = val_(val).gc;
    size_t len = o->ts.tsv.len;
    m_malloc(o, sizeof(TString) + ((len + 1) * sizeof(char)), 0);
}
//</editor-fold>

//<editor-fold desc="table copy free">

static int _new_table(TValue *result) {
    GCObject *o = obj2gco(m_malloc(NULL, 0, sizeof(Table)));
    if (!o) return RPC_MEM_ERROR;
    gch(o)->tt = LUA_TTABLE;;
    Table *t = &o->h;
    t->metatable = NULL;
    t->flags = cast_byte(~0);
    t->array = NULL;
    t->sizearray = 0;
    t->node = NULL;
    t->lsizenode = cast_byte(0);
    t->lastfree = gnode(t, 0);

    val_(result).gc = o;
    settt_(result, ctb(LUA_TTABLE));
    return RPC_OK;
}

static void free_table(TValue *val) {
    Table *t = hvalue(val);
    if (t) {
        size_t i;
        /// free array part
        if (t->sizearray > 0 && t->array) {
            TValue *v;
            for (i = 0; i < t->sizearray; i++) {
                v = &t->array[i];
                if (v != val) free_value(v);
                setnilvalue(v);
            }
            m_malloc(t->array, t->sizearray * sizeof(TValue), 0);
        }
        /// free hash part
        int nodesize = sizenode(t);
        if (nodesize > 0 && t->node) {
            Node *n;
            TValue *kv;
            TValue *vv;
            for (i = 0; i < nodesize; i++) {
                n = gnode(t, i);
                kv = key2tval(n);
                free_value(kv);
                vv = gval(n);
                if (vv != val) free_value(vv);
                setnilvalue(kv);
                setnilvalue(vv);
            }
            m_malloc(t->node, nodesize * sizeof(Node), 0);
        }
        m_malloc(t, sizeof(Table), 0);
    }
}

static int deep_copy_table(TValue *result, TValue *src) {
    Table *ot = hvalue(src);
    if (_new_table(result)) return RPC_MEM_ERROR;
    Table *t = hvalue(result);
    /// copy array part
    if (ot->sizearray > 0 && ot->array) {
        t->array = (TValue *) m_malloc(NULL, 0, ot->sizearray * sizeof(TValue));
        if (!t->array) {
            free_table(result);
            return RPC_MEM_ERROR;
        }
        int i;
        TValue *oldvalue;
        for (i = 0; i < ot->sizearray; i++) {
            oldvalue = &ot->array[i];
            if (oldvalue == src) {
                oldvalue = result;
            }
            int cpr = copy_value(&t->array[i], oldvalue);
            if (cpr) {
                free_table(result);
                return cpr;
            }
        }
        t->sizearray = ot->sizearray;
    }
    /// copy hash part
    int nodesize = sizenode(ot);
    if (nodesize > 0 && ot->node) {
        t->node = (Node *) m_malloc(NULL, 0, nodesize * sizeof(Node));
        if (!t->node) {
            free_table(result);
            return RPC_MEM_ERROR;
        }
        memset(t->node, 0, nodesize * sizeof(Node));
        size_t i;
        Node *on;
        Node *nn;
        Node *next;
        int next_i;
        TValue *vv;
        for (i = 0; i < nodesize; i++) {
            on = gnode(ot, i);
            next = gnext(on);
            vv = gval(on);
            nn = gnode(t, i);
            if (next) {
                next_i = cast_int(next - gnode(ot, 0));
                gnext(nn) = gnode(t, next_i);
            }
            if (vv == src) vv = result;
            int cpr = copy_value(key2tval(nn), key2tval(on));
            if (cpr) {
                free_table(result);
                return cpr;
            }
            cpr = copy_value(gval(nn), vv);
            if (cpr) {
                free_table(result);
                return cpr;
            }
        }
        t->lsizenode = ot->lsizenode;
    }

    return RPC_OK;
}

static void push_table(lua_State *L, TValue *src) {
    Table *t = hvalue(src);
    lua_pushnil(L);                         // -1: nil --table
    TValue *val;
    while (luaH_next(L, t, index2addr(L, -1))) {
        api_incr_top(L);                    // -1: value --key-table
        push_value_to_state(L, index2addr(L, -2)); // -1: copy_key --value-key-table
        val = index2addr(L, -2);
        if (val == src)
            lua_pushvalue(L, -4);
        else
            push_value_to_state(L, val);    // -1: copy_value --copy_key-value-key-table
        lua_rawset(L, -5);                  // -1: value --key-table
        lua_pop(L, 1);                      // -1: key --table
    }
    lua_pop(L, 1);                          // -1: table
}
//</editor-fold>

/**
 * simple lua stack index to value pointer
 */
static TValue *index2addr(lua_State *L, int idx) {
    if (idx > 0) {
        TValue *o = L->ci->func + idx;
        if (o >= L->top) return NONVALIDVALUE;
        else return o;
    } else {
        return L->top + idx;
    }
}