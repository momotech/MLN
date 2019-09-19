/*
** $Id: lvm.h,v 2.5.1.1 2007/12/27 13:02:25 roberto Exp $
** Lua virtual machine
** See Copyright Notice in lua.h
*/

#ifndef lvm_h
#define lvm_h


#include "ldo.h"
#include "lobject.h"
#include "ltm.h"


#define tostring(L,o) ((ttype(o) == LUA_TSTRING) || (luaV_tostring(L, o)))

#define tonumber(o,n)	(ttype(o) == LUA_TNUMBER || \
                         (((o) = luaV_tonumber(o,n)) != NULL))

#define equalobj(L,o1,o2) \
	(ttype(o1) == ttype(o2) && luaV_equalval(L, o1, o2))


#define luaV_lessthan mln_luaV_lessthan
LUAI_FUNC int luaV_lessthan (lua_State *L, const TValue *l, const TValue *r);
#define luaV_equalval mln_luaV_equalval
LUAI_FUNC int luaV_equalval (lua_State *L, const TValue *t1, const TValue *t2);
#define luaV_tonumber mln_luaV_tonumber
LUAI_FUNC const TValue *luaV_tonumber (const TValue *obj, TValue *n);
#define luaV_tostring mln_luaV_tostring
LUAI_FUNC int luaV_tostring (lua_State *L, StkId obj);
#define luaV_gettable mln_luaV_gettable
LUAI_FUNC void luaV_gettable (lua_State *L, const TValue *t, TValue *key,
                                            StkId val);
#define luaV_settable mln_luaV_settable
LUAI_FUNC void luaV_settable (lua_State *L, const TValue *t, TValue *key,
                                            StkId val);
#define luaV_execute mln_luaV_execute
LUAI_FUNC void luaV_execute (lua_State *L, int nexeccalls);
#define luaV_concat mln_luaV_concat
LUAI_FUNC void luaV_concat (lua_State *L, int total, int last);

#endif
