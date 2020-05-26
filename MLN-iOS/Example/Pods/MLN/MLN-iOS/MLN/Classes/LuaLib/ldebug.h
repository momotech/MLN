/*
** $Id: ldebug.h,v 2.3.1.1 2007/12/27 13:02:25 roberto Exp $
** Auxiliary functions from Debug Interface module
** See Copyright Notice in lua.h
*/

#ifndef ldebug_h
#define ldebug_h


#include "lstate.h"


#define pcRel(pc, p)	(cast(int, (pc) - (p)->code) - 1)

#define getline(f,pc)	(((f)->lineinfo) ? (f)->lineinfo[pc] : 0)

#define resethookcount(L)	(L->hookcount = L->basehookcount)


#define luaG_typeerror mln_luaG_typeerror
LUAI_FUNC void luaG_typeerror (lua_State *L, const TValue *o,
                                             const char *opname);
#define luaG_concaterror mln_luaG_concaterror
LUAI_FUNC void luaG_concaterror (lua_State *L, StkId p1, StkId p2);
#define luaG_aritherror mln_luaG_aritherror
LUAI_FUNC void luaG_aritherror (lua_State *L, const TValue *p1,
                                              const TValue *p2);
#define luaG_ordererror mln_luaG_ordererror
LUAI_FUNC int luaG_ordererror (lua_State *L, const TValue *p1,
                                             const TValue *p2);
#define luaG_runerror mln_luaG_runerror
LUAI_FUNC void luaG_runerror (lua_State *L, const char *fmt, ...);
#define luaG_errormsg mln_luaG_errormsg
LUAI_FUNC void luaG_errormsg (lua_State *L);
#define luaG_checkcode mln_luaG_checkcode
LUAI_FUNC int luaG_checkcode (const Proto *pt);
#define luaG_checkopenop mln_luaG_checkopenop
LUAI_FUNC int luaG_checkopenop (Instruction i);

#endif
