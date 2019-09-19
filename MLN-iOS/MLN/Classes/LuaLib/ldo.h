/*
** $Id: ldo.h,v 2.7.1.1 2007/12/27 13:02:25 roberto Exp $
** Stack and Call structure of Lua
** See Copyright Notice in lua.h
*/

#ifndef ldo_h
#define ldo_h


#include "lobject.h"
#include "lstate.h"
#include "lzio.h"


#define luaD_checkstack(L,n)	\
  if ((char *)L->stack_last - (char *)L->top <= (n)*(int)sizeof(TValue)) \
    luaD_growstack(L, n); \
  else condhardstacktests(luaD_reallocstack(L, L->stacksize - EXTRA_STACK - 1));


#define incr_top(L) {luaD_checkstack(L,1); L->top++;}

#define savestack(L,p)		((char *)(p) - (char *)L->stack)
#define restorestack(L,n)	((TValue *)((char *)L->stack + (n)))

#define saveci(L,p)		((char *)(p) - (char *)L->base_ci)
#define restoreci(L,n)		((CallInfo *)((char *)L->base_ci + (n)))


/* results from luaD_precall */
#define PCRLUA		0	/* initiated a call to a Lua function */
#define PCRC		1	/* did a call to a C function */
#define PCRYIELD	2	/* C funtion yielded */

#define Pfunc mln_Pfunc
/* type of protected functions, to be ran by `runprotected' */
typedef void (*Pfunc) (lua_State *L, void *ud);

#define luaD_protectedparser mln_luaD_protectedparser
LUAI_FUNC int luaD_protectedparser (lua_State *L, ZIO *z, const char *name);
#define luaD_callhook mln_luaD_callhook
LUAI_FUNC void luaD_callhook (lua_State *L, int event, int line);
#define luaD_precall mln_luaD_precall
LUAI_FUNC int luaD_precall (lua_State *L, StkId func, int nresults);
#define luaD_call mln_luaD_call
LUAI_FUNC void luaD_call (lua_State *L, StkId func, int nResults);
#define luaD_pcall mln_luaD_pcall
LUAI_FUNC int luaD_pcall (lua_State *L, Pfunc func, void *u,
                                        ptrdiff_t oldtop, ptrdiff_t ef);
#define luaD_poscall mln_luaD_poscall
LUAI_FUNC int luaD_poscall (lua_State *L, StkId firstResult);
#define luaD_reallocCI mln_luaD_reallocCI
LUAI_FUNC void luaD_reallocCI (lua_State *L, int newsize);
#define luaD_reallocstack mln_luaD_reallocstack
LUAI_FUNC void luaD_reallocstack (lua_State *L, int newsize);
#define luaD_growstack mln_luaD_growstack
LUAI_FUNC void luaD_growstack (lua_State *L, int n);

#define luaD_throw mln_luaD_throw
LUAI_FUNC void luaD_throw (lua_State *L, int errcode);
#define luaD_rawrunprotected mln_luaD_rawrunprotected
LUAI_FUNC int luaD_rawrunprotected (lua_State *L, Pfunc f, void *ud);

#define luaD_seterrorobj mln_luaD_seterrorobj
LUAI_FUNC void luaD_seterrorobj (lua_State *L, int errcode, StkId oldtop);

#endif

