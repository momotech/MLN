/*
** $Id: ldo.h,v 2.20.1.1 2013/04/12 18:48:47 roberto Exp $
** Stack and Call structure of Lua
** See Copyright Notice in lua.h
*/

#ifndef ldo_h
#define ldo_h


#include "lobject.h"
#include "lstate.h"
#include "lzio.h"


#define luaD_checkstack(L,n)	if (L->stack_last - L->top <= (n)) \
				    luaD_growstack(L, n); else condmovestack(L);


#define incr_top(L) {L->top++; luaD_checkstack(L,0);}

#define savestack(L,p)		((char *)(p) - (char *)L->stack)
#define restorestack(L,n)	((TValue *)((char *)L->stack + (n)))


/* type of protected functions, to be ran by `runprotected' */
#define Pfunc mln_Pfunc
typedef void (*Pfunc) (lua_State *L, void *ud);

#define luaD_protectedparser mln_luaD_protectedparser
LUAI_FUNC int luaD_protectedparser (lua_State *L, ZIO *z, const char *name,
                                                  const char *mode);
#define luaD_hook mln_luaD_hook
LUAI_FUNC void luaD_hook (lua_State *L, int event, int line);
#define luaD_precall mln_luaD_precall
LUAI_FUNC int luaD_precall (lua_State *L, StkId func, int nresults);
#define luaD_call mln_luaD_call
LUAI_FUNC void luaD_call (lua_State *L, StkId func, int nResults,
                                        int allowyield);
#define luaD_pcall mln_luaD_pcall
LUAI_FUNC int luaD_pcall (lua_State *L, Pfunc func, void *u,
                                        ptrdiff_t oldtop, ptrdiff_t ef);
#define luaD_poscall mln_luaD_poscall
LUAI_FUNC int luaD_poscall (lua_State *L, StkId firstResult);
#define luaD_reallocstack mln_luaD_reallocstack
LUAI_FUNC void luaD_reallocstack (lua_State *L, int newsize);
#define luaD_growstack mln_luaD_growstack
LUAI_FUNC void luaD_growstack (lua_State *L, int n);
#define luaD_shrinkstack mln_luaD_shrinkstack
LUAI_FUNC void luaD_shrinkstack (lua_State *L);
#define luaD_throw mln_luaD_throw

LUAI_FUNC l_noret luaD_throw (lua_State *L, int errcode);
#define luaD_rawrunprotected mln_luaD_rawrunprotected
LUAI_FUNC int luaD_rawrunprotected (lua_State *L, Pfunc f, void *ud);

#endif

