/*
** $Id: lfunc.h,v 2.8.1.1 2013/04/12 18:48:47 roberto Exp $
** Auxiliary functions to manipulate prototypes and closures
** See Copyright Notice in lua.h
*/

#ifndef lfunc_h
#define lfunc_h


#include "lobject.h"


#define sizeCclosure(n)	(cast(int, sizeof(CClosure)) + \
                         cast(int, sizeof(TValue)*((n)-1)))

#define sizeLclosure(n)	(cast(int, sizeof(LClosure)) + \
                         cast(int, sizeof(TValue *)*((n)-1)))


#define luaF_newproto mln_luaF_newproto
LUAI_FUNC Proto *luaF_newproto (lua_State *L);
#define luaF_newCclosure mln_luaF_newCclosure
LUAI_FUNC Closure *luaF_newCclosure (lua_State *L, int nelems);
#define luaF_newLclosure mln_luaF_newLclosure
LUAI_FUNC Closure *luaF_newLclosure (lua_State *L, int nelems);
#define luaF_newupval mln_luaF_newupval
LUAI_FUNC UpVal *luaF_newupval (lua_State *L);
#define luaF_findupval mln_luaF_findupval
LUAI_FUNC UpVal *luaF_findupval (lua_State *L, StkId level);
#define luaF_close mln_luaF_close
LUAI_FUNC void luaF_close (lua_State *L, StkId level);
#define luaF_freeproto mln_luaF_freeproto
LUAI_FUNC void luaF_freeproto (lua_State *L, Proto *f);
#define luaF_freeupval mln_luaF_freeupval
LUAI_FUNC void luaF_freeupval (lua_State *L, UpVal *uv);
#define luaF_getlocalname mln_luaF_getlocalname
LUAI_FUNC const char *luaF_getlocalname (const Proto *func, int local_number,
                                         int pc);


#endif
