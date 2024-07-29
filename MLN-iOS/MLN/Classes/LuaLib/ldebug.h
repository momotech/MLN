/*
** $Id: ldebug.h,v 2.7.1.1 2013/04/12 18:48:47 roberto Exp $
** Auxiliary functions from Debug Interface module
** See Copyright Notice in lua.h
*/

#ifndef ldebug_h
#define ldebug_h


#include "lstate.h"


#define pcRel(pc, p)	(cast(int, (pc) - (p)->code) - 1)

#define getfuncline(f,pc)	(((f)->lineinfo) ? (f)->lineinfo[pc] : 0)

#define resethookcount(L)	(L->hookcount = L->basehookcount)

/* Active Lua function (given call info) */
#define ci_func(ci)		(clLvalue((ci)->func))

#define luaG_typeerror mln_luaG_typeerror
LUAI_FUNC l_noret luaG_typeerror (lua_State *L, const TValue *o,
                                                const char *opname);
#define luaG_concaterror mln_luaG_concaterror
LUAI_FUNC l_noret luaG_concaterror (lua_State *L, StkId p1, StkId p2);
#define luaG_aritherror mln_luaG_aritherror
LUAI_FUNC l_noret luaG_aritherror (lua_State *L, const TValue *p1,
                                                 const TValue *p2);
#define luaG_ordererror mln_luaG_ordererror
LUAI_FUNC l_noret luaG_ordererror (lua_State *L, const TValue *p1,
                                                 const TValue *p2);
#define luaG_runerror mln_luaG_runerror
LUAI_FUNC l_noret luaG_runerror (lua_State *L, const char *fmt, ...);
#define luaG_errormsg mln_luaG_errormsg
LUAI_FUNC l_noret luaG_errormsg (lua_State *L);

#endif
