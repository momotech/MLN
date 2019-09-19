/*
** $Id: ltable.h,v 2.10.1.1 2007/12/27 13:02:25 roberto Exp $
** Lua tables (hash)
** See Copyright Notice in lua.h
*/

#ifndef ltable_h
#define ltable_h

#include "lobject.h"


#define gnode(t,i)	(&(t)->node[i])
#define gkey(n)		(&(n)->i_key.nk)
#define gval(n)		(&(n)->i_val)
#define gnext(n)	((n)->i_key.nk.next)

#define key2tval(n)	(&(n)->i_key.tvk)


#define luaH_getnum mln_luaH_getnum
LUAI_FUNC const TValue *luaH_getnum (Table *t, int key);
#define luaH_setnum mln_luaH_setnum
LUAI_FUNC TValue *luaH_setnum (lua_State *L, Table *t, int key);
#define luaH_getstr mln_luaH_getstr
LUAI_FUNC const TValue *luaH_getstr (Table *t, TString *key);
#define luaH_setstr mln_luaH_setstr
LUAI_FUNC TValue *luaH_setstr (lua_State *L, Table *t, TString *key);
#define luaH_get mln_luaH_get
LUAI_FUNC const TValue *luaH_get (Table *t, const TValue *key);
#define luaH_set mln_luaH_set
LUAI_FUNC TValue *luaH_set (lua_State *L, Table *t, const TValue *key);
#define luaH_new mln_luaH_new
LUAI_FUNC Table *luaH_new (lua_State *L, int narray, int lnhash);
#define luaH_resizearray mln_luaH_resizearray
LUAI_FUNC void luaH_resizearray (lua_State *L, Table *t, int nasize);
#define luaH_free mln_luaH_free
LUAI_FUNC void luaH_free (lua_State *L, Table *t);
#define luaH_next mln_luaH_next
LUAI_FUNC int luaH_next (lua_State *L, Table *t, StkId key);
#define luaH_getn mln_luaH_getn
LUAI_FUNC int luaH_getn (Table *t);


#if defined(LUA_DEBUG)
#define luaH_mainposition mln_luaH_mainposition
LUAI_FUNC Node *luaH_mainposition (const Table *t, const TValue *key);
#define luaH_isdummy mln_luaH_isdummy
LUAI_FUNC int luaH_isdummy (Node *n);
#endif


#endif
