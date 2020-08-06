//
//  argo_lua.h
//  Pods
//
//  Created by Dongpeng Dai on 2020/8/6.
//

#ifndef argo_lua_h
#define argo_lua_h

#include "lstate.h"
#include "mln_lauxlib.h"

//#include "lobject.h"
//#include "ltable.h"
//#include "llimits.h"

#if LUA_VERSION_NUM > 501   /**Lua 5.2 */

//#include "lapi.h"
///**from ltable.h */
//#define key2tval(n)         gkey(n)
//
//#define iso_setobj(obj1, obj2) \
//    { const TValue *io2=(obj2); TValue *io1=(obj1); \
//      io1->value_ = io2->value_; io1->tt_ = io2->tt_; \
//      }
//
//#define LERR(L, s, p)       luai_writestringerror(L, s, p)
#else                       /**Lua 5.1 */
/**from lobject.h */
#define ctb(t)              ((t))
#define val_(o)                ((o)->value)
#define settt_(o,t)            ((o)->tt=(t))
#define rttype(o)           ttype(o)
#define ttypenv(o)          ttype(o)
/**from lapi.h */
#define api_incr_top(L)     {api_check(L, L->top < L->ci->top); L->top++;}
/**from  lauxlib.h*/
#define ispseudo(i)         ((i) <= LUA_REGISTRYINDEX)
#define LERR(L, s, p)       printf(s, p);
#define luaH_getint(t,n)    mln_luaH_getnum(t,n)
#define LUA_RIDX_GLOBALS    LUA_GLOBALSINDEX

#define iso_setobj(obj1,obj2) \
    { const TValue *io2=(obj2); TValue *io1=(obj1); \
      io1->value = io2->value; io1->tt = io2->tt; \
      }
LUA_API inline int lua_absindex (lua_State *L, int idx) {
    return (idx > 0 || ispseudo(idx)) ? idx : (int)(L->top - L->ci->func + idx);
}

LUALIB_API inline int luaL_getsubtable (lua_State *L, int idx, const char *fname) {
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

LUALIB_API inline void luaL_requiref(lua_State *L, const char *modname,
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

LUALIB_API inline void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
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

LUALIB_API inline lua_Integer luaL_len (lua_State *L, int index) {
    return lua_objlen(L, index);
}

#define luaL_newlibtable(L,l)    \
  lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)    (luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
#endif


#define clLvalue(o)         check_exp(ttisLclosure(o), &val_(o).gc->cl.l)
#define getproto(o)         (clLvalue(o)->p)
#define NONVALIDVALUE       cast(TValue *, luaO_nilobject)
/**from lstate.h */
#define gch(o)              (&(o)->gch)



#endif /* argo_lua_h */
