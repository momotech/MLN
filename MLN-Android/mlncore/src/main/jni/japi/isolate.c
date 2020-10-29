/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/06/17.
//

#include <string.h>
#include <pthread.h>
#include "isolate.h"
#include "lundump.h"
#include "lstate.h"
#include "lobject.h"
#include "ltable.h"
#include "llimits.h"
#include "lgc.h"
#include "message_looper.h"

#if defined(JAVA_ENV)

#include <jni.h>
#include "jinfo.h"
#include "m_mem.h"

#endif
#if defined(iOS_ENV)
#include "mil_lauxlib.h"
#include "mil_lualib.h"
#include <dispatch/dispatch.h>
#include "map.h"

#define FORCE_INLIEN __inline__ __attribute__((always_inline))
#else

#include "lauxlib.h"
#include "lualib.h"
#include "map.h"

#define FORCE_INLIEN
#endif

#if LUA_VERSION_NUM > 501   /**Lua 5.2 */

#include "lapi.h"
/**from ltable.h */
#define key2tval(n)         gkey(n)

#define iso_setobj(obj1, obj2) \
    { const TValue *io2=(obj2); TValue *io1=(obj1); \
      io1->value_ = io2->value_; io1->tt_ = io2->tt_; \
      }

#define LERR(L, s, p)       luai_writestringerror(L, s, p)
#else                       /**Lua 5.1 */
/**from lobject.h */
#define ctb(t)              ((t))
#define val_(o)		        ((o)->value)
#define settt_(o,t)	        ((o)->tt=(t))
#define rttype(o)           ttype(o)
#define ttypenv(o)          ttype(o)
/**from lapi.h */
#define api_incr_top(L)     {api_check(L, L->top < L->ci->top); L->top++;}
/**from  lauxlib.h*/
#define ispseudo(i)         ((i) <= LUA_REGISTRYINDEX)
#define LERR(L, s, p)       printf(s, p);
#define luaH_getint(t,n)    mil_luaH_getnum(t,n)
#define LUA_RIDX_GLOBALS    LUA_GLOBALSINDEX

#define iso_setobj(obj1,obj2) \
    { const TValue *io2=(obj2); TValue *io1=(obj1); \
      io1->value = io2->value; io1->tt = io2->tt; \
      }
LUA_API int lua_absindex (lua_State *L, int idx) {
    return (idx > 0 || ispseudo(idx)) ? idx : (int)(L->top - L->ci->func + idx);
}

LUALIB_API int luaL_getsubtable (lua_State *L, int idx, const char *fname) {
    lua_getfield(L, idx, fname);
    if (lua_istable(L, -1)) return 1;  /* table already there */
    else {
        lua_pop(L, 1);  /* remove previous result */
        idx = lua_absindex(L, idx);
        lua_newtable(L);
        lua_pushvalue(L, -1);  /* copy to be left at top */
        lua_setfield(L, idx, fname);  /* assign new table to field */
        return 0;  /* false, because did not find table there */
    }
}

LUALIB_API void luaL_requiref(lua_State *L, const char *modname,
                              lua_CFunction openf, int glb) {
    lua_pushcfunction(L, openf);
    lua_pushstring(L, modname);  /* argument to open function */
    lua_call(L, 1, 1);  /* open module */
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_LOADED");
    lua_pushvalue(L, -2);  /* make copy of module (call result) */
    lua_setfield(L, -2, modname);  /* _LOADED[modname] = module */
    lua_pop(L, 1);  /* remove _LOADED table */
    if (glb) {
        lua_pushvalue(L, -1);  /* copy of 'mod' */
        lua_setglobal(L, modname);  /* _G[modname] = module */
    }
}

LUALIB_API void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
  luaL_checkstack(L, nup, "too many upvalues");
  for (; l->name != NULL; l++) {  /* fill the table with given functions */
    int i;
    for (i = 0; i < nup; i++)  /* copy upvalues to the top */
      lua_pushvalue(L, -nup);
    lua_pushcclosure(L, l->func, nup);  /* closure with those upvalues */
    lua_setfield(L, -(nup + 2), l->name);
  }
  lua_pop(L, nup);  /* remove upvalues */
}
#define luaL_newlibtable(L,l)	\
  lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)	(luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
#endif

#define clLvalue(o)         check_exp(ttisLclosure(o), &val_(o).gc->cl.l)
#define getproto(o)         (clLvalue(o)->p)
#define NONVALIDVALUE       cast(TValue *, luaO_nilobject)
/**from lstate.h */
#define gch(o)              (&(o)->gch)

#define PARAM_TYPE_ERROR    "not support function, userdata or thread"
#define MAIN_FUN_NAME       "isolate_fun"

#define ISOLATE_FUN_NAME    "__" ISOLATE_LIB_NAME "callback"
#define ISOLATE_PARENT      "__parentL"
#define ISOLATE_CHILDREN    "__children_L"
#define ISOLATE_NAME        "__ICN"
#define ISOLATE_LOOPER      "__Looper"
//#define ISOLATE_METANAME    "__iso_meta"

#define OTHER_ERROR         -1
#define STATE_DESTROYED     -2
#define STATE_NONE_LOOP     -3
#define STATE_NO_CHILD      -4
#define STATE_MEMORY        -5
#define STATE_WRONG_PARAM   -6
#define STATE_DUMP_FAILED   -7
#define STATE_THREAD_FAILED -8
#define ISOLATE_OK          0
#ifndef POST_SUCCESS
#define POST_SUCCESS        ISOLATE_OK
#endif

static int check_lua_type(lua_State *L, int idx, int type, int code, const char *m) {
    if (lua_type(L, idx) != type) {
        lua_pushinteger(L, code);
        lua_pushstring(L, m);
        return 1;
    }
    return 0;
}

typedef struct P_Buffer P_Buffer;
typedef struct Thread_Arg Thread_Arg;
typedef struct Isolate Isolate;

typedef int (*_inner_callback)(lua_State *L, void *ud);

#if defined(iOS_ENV)        /**if (ios){ */
extern lua_State *mm_lua_create_vm_in_subthread(void);
extern void mm_lua_set_vm_bundle_path(lua_State *PL, lua_State *L);
extern void mm_lua_release_vm_in_subthread(lua_State *L);
static FORCE_INLIEN int _post(lua_State * parentL, _inner_callback f, void * args) {
    dispatch_async(dispatch_get_main_queue(), ^{
        f(parentL, args);
    });
    return 0;
}
static void *iso_malloc(void *p, size_t o, size_t n) {
    if(n == 0 && p) {
        free(p);
        return NULL;
    } else {
        return realloc(p, n);
    }
}
static int errorFunction(lua_State *L) {
    if (lua_isstring(L, -1)) {
#if DEBUG
        printf("%s", lua_tostring(L, -1));
#endif
    }
    return 1;
}

static int lua_safe_call(lua_State *L, int nargs, int nresults) {
    lua_pushcfunction(L, errorFunction);
    int errindex = -nargs - 2;
    lua_insert(L, errindex);
    int r = lua_pcall(L, nargs, nresults, errindex);
    lua_remove(L, errindex);
    return r;
}
#define new_lvm(L) mm_lua_create_vm_in_subthread()
#define close_lvm(L) lua_close(L);
static char * copystr(const char *s) {
    char *result = iso_malloc(NULL, 0, (strlen(s) + 1) * sizeof(char));
    if (!result) return NULL;
    strcpy(result, s);
    return result;
}
#elif defined(JAVA_ENV)     /**} else if (java){ */

#include "utils.h"
#include "mlog.h"

static int _post(lua_State *parentL, _inner_callback f, void *args) {
    JNIEnv *env;
    getEnv(&env);
    return postCallback(env, parentL, f, args);
}
/**
 * n > 0 malloc或realloc内存
 * n == 0 free p
 */
#define iso_malloc(p, o, n) m_malloc(p,o,n)

extern int getErrorFunctionIndex(lua_State *L);

static int lua_safe_call(lua_State *L, int nargs, int nresults) {
    int ret = lua_pcall(L, nargs, nresults, getErrorFunctionIndex(L));
    if (ret) {
        const char *errmsg;
        if (lua_isstring(L, -1))
            errmsg = lua_tostring(L, -1);
        else
            errmsg = "unkonw error";
        LERR(L, errmsg, NULL);
    }
    return ret;
}

extern jclass Globals;
extern jmethodID Globals__onNativeCreateGlobals;
extern jmethodID Globals__onGlobalsDestroyInNative;

extern void openlibs_forlua(lua_State *L, int debug);
extern void *m_alloc (void *ud, void *ptr, size_t osize, size_t nsize);

static lua_State *new_lvm(lua_State *ol) {
#if defined(J_API_INFO)
    size_t* ud = (size_t*) m_malloc(NULL, 0, sizeof(size_t));
    *ud = 0;
    lua_State *L = luaL_newstate1(m_alloc, ud);
#else
    lua_State *L = luaL_newstate();
#endif
    openlibs_forlua(L, 0);
    JNIEnv *env;
    getEnv(&env);
    (*env)->CallStaticVoidMethod(env, Globals, Globals__onNativeCreateGlobals, (jlong) ol,
                                 (jlong) L, 1);
    return L;
}

static void close_lvm(lua_State *L) {
    JNIEnv *env;
    getEnv(&env);
    (*env)->CallStaticVoidMethod(env, Globals, Globals__onGlobalsDestroyInNative, (jlong) L);
    lua_close(L);
}

#else                       /**} else{ */
#define _post(L,f, a)       OTHER_ERROR
#define iso_malloc(p,o,n)   NULL
#endif                      /**} */

/**
 * save dumped lua function
 */
struct P_Buffer {
    size_t size;
    char *buffer;
};

typedef struct PTValue {
    union {
        TValue tv;
        P_Buffer f;
    } _pt;
    char _t;
} PTValue;

#define PT_VALUE    0
#define PT_FUNCTION 1

#define pt_type(pt)  (pt)->_t
#define set_pt_val(pt) pt_type(pt) = PT_VALUE
#define set_pt_fun(pt) pt_type(pt) = PT_FUNCTION
#define pt_isFun(pt) (pt_type(pt) == PT_FUNCTION)
#define pt_tval(pt)  (&(pt)->_pt.tv)
#define pt_func(pt)  (&(pt)->_pt.f)

#define ISOLATE_ONCE    (char) 0
#define ISOLATE_MAIN    (char) 1
/// 0000 0010
#define ISOLATE_GLOBAL  (char) 2
/// 0000 0100
/// auto callback when post function return
#define ISOLATE_ACB     (char) 4

struct Isolate {
    lua_State *L;
    char type;
    looper *nl;
};
/**
 * args passed from main thread
 */
struct Thread_Arg {
    P_Buffer pb;
    int upvalue_size;
    PTValue *upvalues;
    Isolate *parent;
    char *thread_name;
    char type;
};

/// --------------------------------------------------------------------------------
/// global isolate
/// --------------------------------------------------------------------------------
static Map *global_isolate = NULL;
static pthread_rwlock_t global_rwlock;

static void _free_isolate_for_global(void *p) {
    Isolate *iso = (Isolate *)p;
    iso->nl = NULL;
    iso_malloc(p, sizeof(Isolate), 0);
}

static void _free_str_for_global(void *p) {
    char *str = p;
    iso_malloc(str, strlen(str) + 1, 0);
}

static int _str_equals(const void * a, const void * b) {
    return strcmp((const char *)a, (const char *)b) == 0;
}

static void init_global() {
    if (global_isolate)
        return;
    pthread_rwlock_init(&global_rwlock, NULL);
    global_isolate = map_new(NULL, 10);

    if (map_ero(global_isolate)) {
        map_free(global_isolate);
        global_isolate = NULL;
        pthread_rwlock_destroy(&global_rwlock);
        return;
    }
    map_set_equals(global_isolate, _str_equals);
    map_set_free(global_isolate, _free_str_for_global, _free_isolate_for_global);
}

static Isolate *get_global_isolate(const char *name) {
    if (!global_isolate) return NULL;
    pthread_rwlock_rdlock(&global_rwlock);
    Isolate *ret = (Isolate *) map_get(global_isolate, name);
    pthread_rwlock_unlock(&global_rwlock);
    return ret;
}

static void save_global_isolate(const char *name, lua_State *L) {
    if (!global_isolate) return;
    char *copy = copystr(name);
    pthread_rwlock_wrlock(&global_rwlock);
    Isolate *iso = iso_malloc(NULL, 0, sizeof(Isolate));
    iso->L = L;
    iso->type = ISOLATE_GLOBAL;
    iso->nl = current_thread_looper();
    map_put(global_isolate, copy, iso);
    pthread_rwlock_unlock(&global_rwlock);
}

static void remove_global_isolate(const char *name) {
    if (!global_isolate) return;
    pthread_rwlock_wrlock(&global_rwlock);
    void *v = map_remove(global_isolate, name);
    if (v) _free_isolate_for_global(v);
    pthread_rwlock_unlock(&global_rwlock);
}
/// --------------------------------------------------------------------------------
/// end
/// --------------------------------------------------------------------------------

static void push_value_to_state(lua_State *L, TValue *val);

static int copy_value(TValue *dest, TValue *src);

static void free_value(TValue *val);

typedef void (*free_args)(void *);

typedef struct msg_data {
    _inner_callback c;
    free_args f;
    lua_State *L;
    void *args;
} msg_data;

static void _free_looper_msg_data(void *ud) {
    msg_data *md = (msg_data *) ud;
    if (md->args)
        md->f(md->args);
    md->args = NULL;
    iso_malloc(md, sizeof(msg_data), 0);
}

static void handle_looper_message(int type, void *ud) {
    msg_data *md = (msg_data *) ud;
    if (!md) return;
    md->c(md->L, md->args);
    iso_malloc(md, sizeof(msg_data), 0);
}

static msg_data *new_looper_meesage(_inner_callback c, free_args f, lua_State *L, void *args) {
    msg_data *d = (msg_data *) iso_malloc(NULL, 0, sizeof(msg_data));
    if (!d) {
        return NULL;
    }
    d->L = L;
    d->c = c;
    d->f = f;
    d->args = args;
    return d;
}

static int _post_by_looper(Isolate *toIso, _inner_callback c, free_args f, void *args) {
    msg_data *m = new_looper_meesage(c, f, toIso->L, args);
    if (!m) return OTHER_ERROR;
    return post_message(toIso->nl, 0, m, handle_looper_message, _free_looper_msg_data);
}

static int post(Isolate *toIso, _inner_callback c, free_args f, void *args) {
    switch (toIso->type) {
        case ISOLATE_MAIN:
            return _post(toIso->L, c, args);
        case ISOLATE_GLOBAL:
            return _post_by_looper(toIso, c, f, args);
        default:
            return STATE_NONE_LOOP;
    }
}

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

static int _new_table(TValue *result) {
    GCObject *o = obj2gco(iso_malloc(NULL, 0, sizeof(Table)));
    if (!o) return STATE_MEMORY;
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
    return ISOLATE_OK;
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
            iso_malloc(t->array, t->sizearray * sizeof(TValue), 0);
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
            iso_malloc(t->node, nodesize * sizeof(Node), 0);
        }
        iso_malloc(t, sizeof(Table), 0);
    }
}

static int deep_copy_table(TValue *result, TValue *src) {
    Table *ot = hvalue(src);
    if (_new_table(result)) return STATE_MEMORY;
    Table *t = hvalue(result);
    /// copy array part
    if (ot->sizearray > 0 && ot->array) {
        t->array = (TValue *) iso_malloc(NULL, 0, ot->sizearray * sizeof(TValue));
        if (!t->array) {
            free_table(result);
            return STATE_MEMORY;
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
        t->node = (Node *) iso_malloc(NULL, 0, nodesize * sizeof(Node));
        if (!t->node) {
            free_table(result);
            return STATE_MEMORY;
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

    return ISOLATE_OK;
}

static int copy_string(TValue *result, TValue *src) {
    TString *ots = &val_(src).gc->ts;
    const char *str = svalue(src);
    size_t len = ots->tsv.len;
    size_t totalsize = sizeof(TString) + ((len + 1) * sizeof(char));
    GCObject *o = obj2gco(iso_malloc(NULL, 0, totalsize));
    if (!o) return STATE_MEMORY;
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
    return ISOLATE_OK;
}

static void free_string(TValue *val) {
    GCObject *o = val_(val).gc;
    size_t len = o->ts.tsv.len;
    iso_malloc(o, sizeof(TString) + ((len + 1) * sizeof(char)), 0);
}

/**
 * dump lua function to mem
 */
static int writer(lua_State *L, const void *p, size_t size, void *u) {
    (void) L;
    P_Buffer *pb = (P_Buffer *) u;
    pb->buffer = iso_malloc(pb->buffer, pb->size, (size + pb->size) * sizeof(char));
    if (!pb->buffer) return 1;
    memcpy(pb->buffer + pb->size, p, size);
    pb->size += size;
    return 0;
}

static int copy_function(lua_State *L, P_Buffer *buf, TValue *val) {
    if (!isLfunction(val)) return -1;
    Proto *f = getproto(val);
    int ret = luaU_dump(L, f, writer, buf, 0);
    if (ret) {
        if (buf->buffer)
            iso_malloc(buf->buffer, buf->size * sizeof(char), 0);
        buf->buffer = NULL;
        buf->size = 0;
    }
    return ret;
}

/**
 * copy values passed by isolate.create
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
        case LUA_TLIGHTUSERDATA: iso_setobj(dest, src);
            ret = 0;
            break;
        case LUA_TSTRING:
            ret = copy_string(dest, src);
            break;
        case LUA_TTABLE:
            ret = deep_copy_table(dest, src);
            break;
        case LUA_TUSERDATA:
        default:
            LERR(NULL, "not support type: %d", type);
            setnilvalue(dest);
            return STATE_WRONG_PARAM;
    }
    if (ret) {
        setnilvalue(dest);
        LERR(NULL, "copy failed, error code: %d", ret);
    }
    return ret;
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
        default:    //nil, function
            return;
    }
}

static void free_buf(P_Buffer *buf) {
    if (buf->buffer && buf->size > 0)
        iso_malloc(buf->buffer, buf->size * sizeof(char), 0);
    buf->size = 0;
    buf->buffer = NULL;
}

/**
 * free TValue * array
 */
static void free_values(PTValue *values, int size) {
    TValue *val;
    P_Buffer *buf;
    for (--size; size >= 0; size--) {
        if (!pt_isFun(&values[size])) {
            val = pt_tval(&values[size]);
            free_value(val);
            setnilvalue(val);
        } else {
            buf = pt_func(&values[size]);
            free_buf(buf);
        }
    }
}

/**
 * free all mem in Thread_Arg
 */
static void free_thread_arg(void *ud) {
    Thread_Arg *arg = (Thread_Arg *) ud;
    if (arg->pb.buffer && arg->pb.size > 0)
        free_buf(&arg->pb);
    arg->pb.buffer = NULL;
    arg->pb.size = 0;
    if (arg->upvalues) {
        free_values(arg->upvalues, arg->upvalue_size);
        iso_malloc(arg->upvalues, sizeof(PTValue) * arg->upvalue_size, 0);
    }
    arg->upvalues = NULL;
    if (arg->thread_name) {
        iso_malloc(arg->thread_name, sizeof(char) * (strlen(arg->thread_name) + 1), 0);
    }
    if (arg->parent) {
        if (arg->parent->type != ISOLATE_GLOBAL) {
            iso_malloc(arg->parent, sizeof(Isolate), 0);
        }
    }
    arg->parent = NULL;
    arg->thread_name = NULL;
    iso_malloc(arg, sizeof(Thread_Arg), 0);
}

static Thread_Arg *copy_upvalues(lua_State *L, int fromIndex, int *errorType) {
    Thread_Arg *arg = (Thread_Arg *) iso_malloc(NULL, 0, sizeof(Thread_Arg));
    if (!arg) {
        if (errorType) *errorType = STATE_MEMORY;
        return NULL;
    }
    memset(arg, 0, sizeof(Thread_Arg));
    int upsize = lua_gettop(L) - fromIndex + 1;
    arg->upvalue_size = upsize;
    if (upsize > 0) {
        arg->upvalues = (PTValue *) iso_malloc(NULL, 0, sizeof(PTValue) * upsize);
        if (!arg->upvalues) {
            free_thread_arg(arg);
            if (errorType) *errorType = STATE_MEMORY;
            return NULL;
        }
        memset(arg->upvalues, 0, sizeof(PTValue) * upsize);
    } else arg->upvalues = NULL;
    int i;
    TValue *src;
    PTValue *ptv;
    for (i = 0; i < upsize; i++) {
        src = index2addr(L, i + fromIndex);
        ptv = &arg->upvalues[i];
        if (!copy_function(L, pt_func(ptv), src)) {
            set_pt_fun(ptv);
            continue;
        }
        set_pt_val(ptv);
        int cpr = copy_value(pt_tval(ptv), src);
        if (cpr) {
            free_thread_arg(arg);
            if (errorType) *errorType = cpr;
            return NULL;
        }
    }
    return arg;
}

static Thread_Arg *copy_upvalues_and_deal_with_error(lua_State *L, int fromIndex) {
    int errorType;
    Thread_Arg *arg = copy_upvalues(L, fromIndex, &errorType);
    if (!arg) {
        lua_pushinteger(L, errorType);
        const char *em;
        if (errorType == STATE_MEMORY) em = "out of memory";
        else em = PARAM_TYPE_ERROR;

        lua_pushstring(L, em);
        return NULL;
    }
    return arg;
}

/**
 * called in new thread by push_value_to_state
 * specally copy table
 */
static void copy_table(lua_State *L, TValue *src) {
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

/**
 * called in new thread
 * push value which is copyed before
 * table is special, see copy_table
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
        case LUA_TLIGHTUSERDATA:
            lua_pushlightuserdata(L, pvalue(val));
            break;
        case LUA_TTABLE:
            lua_newtable(L);
            copy_table(L, val);
            break;
        case LUA_TUSERDATA:
        default:
            break;
    }
}

static int push_lua_function(lua_State *L, P_Buffer *buf, const char *name) {
    int r = luaL_loadbuffer(L, buf->buffer, buf->size, name);
    if (r == 0) {
        LClosure *f = clLvalue(L->top - 1);
        if (f->nupvalues == 1) {
            Table *reg = hvalue(&G(L)->l_registry);
            const TValue *gt = luaH_getint(reg, LUA_RIDX_GLOBALS);
            setobj(L, f->upvals[0]->v, gt);
            luaC_barrier(L, f->upvals[0], gt);
        }
    }
    return r;
}

static void save_parent_isolate(lua_State *L, Isolate *parent) {
    Isolate *ud = (Isolate *) lua_newuserdata(L, sizeof(Isolate));

    ud->L = parent->L;
    ud->nl = parent->nl;
    ud->type = parent->type;
    lua_setglobal(L, ISOLATE_PARENT);
}

static Isolate *get_parent_isolate(lua_State *L) {
    lua_getglobal(L, ISOLATE_PARENT);
    if (lua_isuserdata(L, -1)) {
        Isolate *r = (Isolate *) lua_touserdata(L, -1);
        lua_pop(L, 1);
        return r;
    }
    lua_pop(L, 1);
    return NULL;
}

static looper *get_looper(lua_State *L) {
    lua_getglobal(L, ISOLATE_LOOPER);
    looper *l = NULL;
    if (!lua_isnil(L, -1)) {
        l = (looper *) lua_touserdata(L, -1);
    }
    lua_pop(L, 1);
    return l;
}

/**
 * push thread args to Lua stack
 */
static int push_thread_args(lua_State *L, Thread_Arg *ta) {
    int i;
    PTValue *ptvs = ta->upvalues;
    TValue *val;
    P_Buffer *buf;
    int size = ta->upvalue_size;
    for (i = 0; i < size; i++) {
        if (!pt_isFun(&ptvs[i])) {
            val = pt_tval(&ptvs[i]);
            push_value_to_state(L, val);
            if (!ttisnil(val)) free_value(val);
        } else {
            buf = pt_func(&ptvs[i]);
            if (push_lua_function(L, buf, NULL))
                lua_pushnil(L);
            free_buf(buf);
        }
    }
    if (ptvs)
        iso_malloc(ptvs, sizeof(PTValue) * size, 0);
    ta->upvalues = NULL;
    free_thread_arg(ta);
    return size;
}

static void save_isolate_name(lua_State *L, Thread_Arg *ta) {
    const char *tn = (const char *) ta->thread_name;
    lua_pushstring(L, tn);
    lua_setglobal(L, ISOLATE_NAME);
}

typedef struct SRC_Arg {
    char save;
    const char *name;
    lua_State *child;
} SRC_Arg;

static void freeSRC_Arg(void *ud) {
    SRC_Arg *arg = (SRC_Arg *) ud;
    if (arg->name)
        iso_malloc((void *) arg->name, strlen(arg->name) + 1, 0);
    iso_malloc(arg, sizeof(SRC_Arg), 0);
}

/**
 * 保存子线程
 */
static void save_child(lua_State *L, const char *name, lua_State *child) {
    lua_getglobal(L, ISOLATE_CHILDREN);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 2, 0);
        lua_pushvalue(L, -1);
        lua_setglobal(L, ISOLATE_CHILDREN);
    }
    /// children_table
    Isolate *iso = (Isolate *) lua_newuserdata(L, sizeof(Isolate));// -1:child, children_table
    iso->L = child;
    iso->nl = NULL;
    iso->type = ISOLATE_ONCE;

    lua_setfield(L, -2, name);          // -1:children_table
    /// children_table
    lua_rawgeti(L, -1, 2);              // -1: num, children_table
    int num = lua_isnil(L, -1) ? 0 : (int) lua_tonumber(L, -1);
    lua_pop(L, 1);
    num++;
    /// children_table
    lua_pushinteger(L, num);
    lua_rawseti(L, -2, 2);
    lua_pop(L, 1);
}

/**
 * 移除子线程
 */
static void remove_child(lua_State *L, const char *name) {
    lua_getglobal(L, ISOLATE_CHILDREN);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        return;
    }
    /// children_table
    lua_getfield(L, -1, name);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);
        return;
    }
    lua_pop(L, 1);
    /// children_table
    lua_pushnil(L);
    lua_setfield(L, -2, name);
    /// children_table
    lua_rawgeti(L, -1, 2);
    int num = lua_isnil(L, -1) ? 0 : (int) lua_tonumber(L, -1);
    num--;
    lua_pop(L, 1);
    /// children_table
    lua_pushinteger(L, num);
    lua_rawseti(L, -2, 2);
    lua_pop(L, 1);
}

static FORCE_INLIEN int save_or_remove_in_post(lua_State *L, void *ud) {
    SRC_Arg *srcarg = (SRC_Arg *) ud;
    if (L) {
        if (srcarg->save) {
            save_child(L, srcarg->name, srcarg->child);
        } else {
            remove_child(L, srcarg->name);
        }
    }
    freeSRC_Arg(srcarg);
    return POST_SUCCESS;
}

static int return_sucess(lua_State *L) {
    lua_pushinteger(L, 0);
    lua_pushstring(L, "success");
    return 2;
}

static int
post_and_deal_with_error(lua_State *L, Isolate *toIso, _inner_callback c, free_args f, void *args) {
    int ret = post(toIso, c, f, args);
    if (ret == POST_SUCCESS) {
        lua_pushinteger(L, 0);
        lua_pushstring(L, "success");
        return ret;
    }
    /// <0: 表示post前出错，没有释放相关内存
    /// >0: 表示进入looper出错，释放了内存
    if (ret < POST_SUCCESS)
        f(args);
    lua_pushinteger(L, ret);
    switch (ret) {
        case STATE_DESTROYED:
            lua_pushstring(L, "parent vm is destroy");
            break;
        case STATE_NONE_LOOP:
            lua_pushstring(L, "parent vm has no looper");
            break;
        default:
            lua_pushstring(L, "unknown error");
            break;
    }
    return ret;
}

static FORCE_INLIEN int call_callback(lua_State *L, void *ud) {
    Thread_Arg *args = (Thread_Arg *) ud;
    int oldTop = lua_gettop(L);
    lua_getglobal(L, ISOLATE_FUN_NAME);
    if (!lua_isfunction(L, -1)) {
        lua_settop(L, oldTop);
        LERR(L, "%s", "must call isolate.registerCallback(function) first!");
        return OTHER_ERROR;
    }

    int size = args ? push_thread_args(L, args) : 0;
    int code = lua_safe_call(L, size, LUA_MULTRET);
    lua_settop(L, oldTop);
    return (code == 0 ? 0 : OTHER_ERROR);
}

static lua_State *_inner_in_thread(Thread_Arg *ta) {
    Isolate *parent = ta->parent;
    ta->parent = NULL;
    lua_State *L = new_lvm(parent ? parent->L : NULL);

    /// 非global
    if (parent) {
        SRC_Arg *srcarg = (SRC_Arg *) iso_malloc(NULL, 0, sizeof(SRC_Arg));
        srcarg->save = 1;
        srcarg->name = copystr(ta->thread_name);
        srcarg->child = L;
        save_parent_isolate(L, parent);
        if (post(parent, save_or_remove_in_post, freeSRC_Arg, srcarg) < POST_SUCCESS)
            freeSRC_Arg(srcarg);
    }

    save_isolate_name(L, ta);

    /// global 类型没有入口函数
    if (ta->type == ISOLATE_GLOBAL) {
        save_global_isolate(ta->thread_name, L);
        return L;
    }

    if (push_lua_function(L, &ta->pb, MAIN_FUN_NAME)) {
        /// 执行函数失败
        free_thread_arg(ta);
        const char *em = lua_tostring(L, -1);
        em = lua_pushfstring(L, "load function failed:%s", em);
        LERR(L, "%s", em);
    } else {
        int size = push_thread_args(L, ta);
        lua_safe_call(L, size, LUA_MULTRET);
    }
    lua_settop(L, 1);
    return L;
}

/**
 * in thread
 *
 * 1: create lua vm
 * 2: load the lua function which is dumped before
 * 3: push values which are copyed before
 * 4: pcall lua function
 * 5: close lua vm
 */
static void *in_thread(void *arg) {
#if defined(JAVA_ENV)
    JNIEnv *env;
    int needDetach = getEnv(&env);
#endif
    Thread_Arg *ta = (Thread_Arg *) arg;
    Isolate *parent = ta->parent;
    const char *tname = copystr(ta->thread_name);
#if defined(ANDROID)
    pthread_t pt = pthread_self();
    pthread_setname_np(pt, tname);
#else
    pthread_setname_np(tname);
#endif
    lua_State *L;
    if (ta->type == ISOLATE_ONCE) {
        L = _inner_in_thread(ta);
    } else {
#if defined(JAVA_ENV)
        prepare_loop(m_malloc);
#else
        prepare_loop(iso_malloc);
#endif
        L = _inner_in_thread(ta);
//        ta->outL = &L;
//        post_message(l, _new_init_message(ta));
        loop();
        remove_global_isolate(tname);
    }
    /// ta生命周期结束
    close_lvm(L);

    /// 非global类型
    if (parent) {
        SRC_Arg *srcarg = (SRC_Arg *) iso_malloc(NULL, 0, sizeof(SRC_Arg));
        srcarg->save = 0;
        srcarg->name = copystr(tname);
        srcarg->child = NULL;
        if (post(parent, save_or_remove_in_post, freeSRC_Arg, srcarg) < POST_SUCCESS)
            freeSRC_Arg(srcarg);
        if (parent->type != ISOLATE_GLOBAL)
            iso_malloc(parent, sizeof(Isolate), 0);
    }
    iso_malloc((void *) tname, strlen(tname) + 1, 0);

#if defined(JAVA_ENV)
    if (needDetach) detachEnv();
#elif defined(iOS_ENV)
    mm_lua_release_vm_in_subthread(L);
#endif
//    pthread_exit(0);
    return NULL;
}

/**
 * 返回当前isolate名称
 * n = isolate.name()
 */
static int name(lua_State *L) {
    lua_getglobal(L, ISOLATE_NAME);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_pushstring(L, "main");
        lua_pushvalue(L, -1);
        lua_setglobal(L, ISOLATE_NAME);
    }
    return 1;
}

static Isolate *getCurrentIsolate(lua_State *L) {
    name(L);
    const char *iso_name = lua_tostring(L, -1);
    lua_pop(L, 1);
    Isolate *isolate = get_global_isolate(iso_name);
    if (!isolate) {
        isolate = (Isolate *) iso_malloc(NULL, 0, sizeof(Isolate));;
        isolate->L = L;
        isolate->nl = NULL;
        if (strcmp(iso_name, "main") == 0) {
            isolate->type = ISOLATE_MAIN;
        } else {
            isolate->type = ISOLATE_ONCE;
        }
    }
    return isolate;
}

/**
 * 创建隔离，对于lua来讲，相当于创建新进程（虚拟机），内存不共享
 * 执行完相应lua函数后，关闭虚拟机，线程结束
 * return code msg
 * code, msg = isolate.create(callback, name, values...)
 * code: 1: success
 *
 * step1: dump lua function
 * step2: copy values if have
 * step3: create thread and run
 */
static int create(lua_State *L) {
    if (check_lua_type(L, 1, LUA_TFUNCTION,
                       STATE_WRONG_PARAM, "isolate.create must have a function for params")) {
        return 2;
    }
    if (check_lua_type(L, 2, LUA_TSTRING,
                       STATE_WRONG_PARAM, "isolate.create 2nd param must be a string for thread name")) {
        return 2;
    }
    /// dump lua function
    P_Buffer buffer = {0, NULL};
    int result = copy_function(L, &buffer, index2addr(L, 1));
    if (result) {
        if (buffer.buffer) iso_malloc(buffer.buffer, buffer.size * sizeof(char), 0);
        lua_pushinteger(L, STATE_DUMP_FAILED);
        lua_pushstring(L, "dump function failed!");
        return 2;
    }
    /// copy values
    Thread_Arg *arg = copy_upvalues_and_deal_with_error(L, 3);
    if (!arg) {
        iso_malloc(buffer.buffer, buffer.size * sizeof(char), 0);
        return 2;
    }

    arg->type = ISOLATE_ONCE;
    arg->pb = buffer;
    arg->parent = getCurrentIsolate(L);
    const char *tn = lua_tostring(L, 2);
    arg->thread_name = copystr(tn);

    /// create thread
    pthread_t pt;
    if (pthread_create(&pt, NULL, in_thread, arg) != 0) {
        free_thread_arg(arg);
        lua_pushinteger(L, STATE_THREAD_FAILED);
        lua_pushstring(L, "create thread failed");
        return 2;
    }
    pthread_detach(pt);

    return return_sucess(L);
}

/**
 * 创建全局隔离，会一直存在在内存中，其他隔离可以使用
 * code, msg = isolate.openGlobal(name)
 */
static int openGlobal(lua_State *L) {
    if (check_lua_type(L, 1, LUA_TSTRING,
                       STATE_WRONG_PARAM, "isolate.openGlobal must be a string for thread name")) {
        return 2;
    }
    const char *name = lua_tostring(L, 1);
    if (get_global_isolate(name)) return return_sucess(L);

    Thread_Arg *arg = (Thread_Arg *) iso_malloc(NULL, 0, sizeof(Thread_Arg));
    if (!arg) {
        lua_pushinteger(L, STATE_MEMORY);
        lua_pushstring(L, "out of memory");
        return 2;
    }
    memset(arg, 0, sizeof(Thread_Arg));
    arg->thread_name = copystr(name);;
    arg->type = ISOLATE_GLOBAL;
    /// create thread
    pthread_t pt;
    if (pthread_create(&pt, NULL, in_thread, arg) != 0) {
        free_thread_arg(arg);
        lua_pushinteger(L, STATE_THREAD_FAILED);
        lua_pushstring(L, "create thread failed");
        return 2;
    }
    pthread_detach(pt);

    return return_sucess(L);
}

/**
 * 关闭自身线程，自身必须是looper类型
 * code, msg = isolate.closeSelf(safely(bool))
 */
static int closeSelf(lua_State *L) {
    looper *cl = current_thread_looper();
    if (!cl) {
        lua_pushinteger(L, STATE_NONE_LOOP);
        lua_pushstring(L, "current thread is not a looper thread!");
        return 2;
    }
    int safe = lua_toboolean(L, 1) ? ML_SAFELY : ML_UNSAFELY;
    int r = post_quit(cl, safe);
    lua_pushinteger(L, r);
    if (r != ML_DONE) {
        if (r == ML_QUITING)
            lua_pushstring(L, "thread is quiting");
        else
            lua_pushstring(L, "unknown error");
    } else {
        lua_pushstring(L, "success");
    }
    return 2;
}

/**
 * 获取所有子isolate的个数
 * len = isolate.children()
 */
static int get_children(lua_State *L) {
    lua_getglobal(L, ISOLATE_CHILDREN);
    if (!lua_istable(L, -1)) {
        lua_pushinteger(L, 0);
        return 1;
    }
    lua_rawgeti(L, -1, 2);
    return 1;
}

/**
 * 注册回调，在主线程调用
 * code, msg = isolate.registCallback(function)
 * code: 1: success
 */
static int registerCallback(lua_State *L) {
    if (check_lua_type(L, 1, LUA_TFUNCTION,
                       STATE_WRONG_PARAM, "param must be a function!")) {
        return 2;
    }
    lua_pushvalue(L, 1);
    lua_setglobal(L, ISOLATE_FUN_NAME);
    return return_sucess(L);
}

/**
 * 调用回调，在子线程调用，并在主线程调用相应函数
 * code, msg = isolate.callback(...)
 * code: 1: success
 *
 * 最终调用到call_callback中
 */
static int callback(lua_State *L) {
    /// copy values
    Thread_Arg *arg = copy_upvalues_and_deal_with_error(L, 1);
    if (!arg) {
        return 2;
    }
    Isolate *pl = get_parent_isolate(L);
    post_and_deal_with_error(L, pl, call_callback, free_thread_arg, arg);
    return 2;
}

/**
 * 使线程睡眠`n`秒
 * isolate.sleep(number)
 */
static int lua_sleep(lua_State *L) {
    double n = luaL_checknumber(L, 1);
    struct timespec t;
    struct timespec r;
    if (n < 0.0) n = 0.0;
    if (n > INT_MAX) n = INT_MAX;
    t.tv_sec = (int) n;
    n -= t.tv_sec;
    t.tv_nsec = (int) (n * 1000000000);
    if (t.tv_nsec >= 1000000000) t.tv_nsec = 999999999;
    while (nanosleep(&t, &r) != 0) {
        t.tv_sec = r.tv_sec;
        t.tv_nsec = r.tv_nsec;
    }
    return 0;
}

/**
 * 在子线程执行相应函数
 * @param ud Thread_Arg 1st param is function
 */
static FORCE_INLIEN int call_post_action(lua_State *L, void *ud) {
    Thread_Arg *args = (Thread_Arg *) ud;
    int oldTop = lua_gettop(L);
    Isolate *parent = args->parent;
    char type = args->type;
    args->parent = NULL;
    int size = push_thread_args(L, args);
    int code = lua_safe_call(L, size - 1, LUA_MULTRET);
    if (parent && parent->type != ISOLATE_ONCE && type == ISOLATE_ACB) {
        lua_createtable(L, 0, 3);
        lua_pushinteger(L, code);
        lua_setfield(L, -2, "code");
        /// -1:table
        if (code != 0) {
            ///-1:table -2: errmsg
            lua_pushvalue(L, -2);
            lua_setfield(L, -2, "msg");
            lua_remove(L, -2);          // -1:table
        }
        name(L);                        // -1:table name
        lua_setfield(L, -2, "name");    // -1:table
        lua_insert(L, oldTop + 1);
        Thread_Arg *call_args = copy_upvalues_and_deal_with_error(L, oldTop + 1);
        if (call_args)
            post_and_deal_with_error(L, parent, call_callback, free_thread_arg, call_args);
    }
    if (parent && parent->type != ISOLATE_GLOBAL) {
        iso_malloc(parent, sizeof(Isolate), 0);
    }
    lua_settop(L, oldTop);
    return (code == 0 ? 0 : OTHER_ERROR);
}

/**
 * code, msg= isolate.post(child_name(string), autoCallback, function, values...)
 */
static int post_action(lua_State *L) {
    if (check_lua_type(L, 1, LUA_TSTRING,
                       STATE_WRONG_PARAM, "the 1st param must be a string")) {
        return 2;
    }
    if (check_lua_type(L, 2, LUA_TBOOLEAN,
                       STATE_WRONG_PARAM, "the 2nd param must be a bool")) {
        return 2;
    }
    if (check_lua_type(L, 3, LUA_TFUNCTION,
                       STATE_WRONG_PARAM, "the 3rd param must be a function")) {
        return 2;
    }
    int autoCallback = lua_toboolean(L, 2);
    const char *name = lua_tostring(L, 1);
    /// 先检查global隔离
    Isolate *child = get_global_isolate(name);
    if (!child) {
        lua_pushinteger(L, STATE_NO_CHILD);
        lua_pushfstring(L, "no isolate named %s", name);
        return 2;
    }
#if defined(iOS_ENV)
    mm_lua_set_vm_bundle_path(L, child->L);
#endif

    Thread_Arg *arg = copy_upvalues_and_deal_with_error(L, 3);
    if (!arg) {
        return 2;
    }
    /// 如果需要自动callback，则需要把调用方隔离传入
    if (autoCallback) {
        arg->parent = getCurrentIsolate(L);
        arg->type = ISOLATE_ACB;
    }
    post_and_deal_with_error(L, child, call_post_action, free_thread_arg, arg);
    return 2;
}

static const luaL_Reg co_funcs[] = {
        {"name", name},
        {"create", create},
        {"openGlobal", openGlobal},
        {"closeSelf", closeSelf},
        {"children", get_children},
        {"registerCallback", registerCallback},
        {"callback", callback},
        {"post", post_action},
        {"sleep", lua_sleep},
        {NULL, NULL}
};

// static void create_isolate_metatable(lua_State *L) {
//     if (luaL_newmetatable(L, ISOLATE_METANAME)) {
//         lua_pushstring(L, "__index");
//         lua_pushvalue(L, -2);
//         lua_rawset(L, -3);
//         lua_pushcfunction(L, _isolate_gc);
//         lua_setfield(L, -2, "__gc");
//     }
//     lua_pop(L, 1);
// }

static int open_core(lua_State *L) {
    lua_newtable(L);
    luaL_register(L, NULL, co_funcs);
    // create_isolate_metatable(L);
    return 1;
}

int isolate_open(lua_State *L) {
    init_global();
    luaL_newlib(L, co_funcs);
    // create_isolate_metatable(L);
    return 1;
}

int luaopen_isolate(lua_State *L) {
    init_global();
    luaL_requiref(L, ISOLATE_LIB_NAME, open_core, 1);
    lua_pop(L, 1);
    return 0;
}

#pragma mark - Thread

#if defined(JAVA_ENV)
typedef struct mln_java_thread_ctx {
    void *(*callback)(void *);
    void **retbuffer;
    void *condition;
} mln_java_thread_ctx;

static int mln_thread_java_main(lua_State *L, void *ud) {
    if (!ud) return -1;
    mln_java_thread_ctx *ctx = (mln_java_thread_ctx *)ud;
    void *(*callback)(void *) = ctx->callback;
    void *retvalue = callback(L);
    *(ctx->retbuffer) = retvalue;
    pthread_cond_signal(ctx->condition);
    return 0;
}
#endif

void* mln_thread_sync_to_main(lua_State *L, void*(*callback)(void *)) {
#if defined(iOS_ENV)
    __block void *retvalue = NULL;
    dispatch_sync(dispatch_get_main_queue(), ^{
        retvalue = callback(L);
    });
    return retvalue;
#elif defined(JAVA_ENV)
    pthread_mutex_t lock;
    pthread_cond_t condition = PTHREAD_COND_INITIALIZER;
    pthread_mutex_init(&lock, NULL);
    pthread_mutex_lock(&lock);

    void *retvalue = NULL;
    mln_java_thread_ctx *ctx = (mln_java_thread_ctx *)malloc(sizeof(mln_java_thread_ctx));
    ctx->callback = callback;
    ctx->retbuffer = &retvalue;
    ctx->condition = &condition;

    JNIEnv *env;
    getEnv(&env);
    postCallback(env, L, mln_thread_java_main, ctx);
    pthread_cond_wait(&condition, &lock); // sync

    pthread_mutex_unlock(&lock);
    pthread_mutex_destroy(&lock);
    pthread_cond_destroy(&condition);

    retvalue = *(ctx->retbuffer);
    free(ctx);
    return retvalue;
#endif
}

