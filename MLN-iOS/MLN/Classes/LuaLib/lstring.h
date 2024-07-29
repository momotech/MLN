/*
** $Id: lstring.h,v 1.49.1.1 2013/04/12 18:48:47 roberto Exp $
** String table (keep all strings handled by Lua)
** See Copyright Notice in lua.h
*/

#ifndef lstring_h
#define lstring_h

#include "lgc.h"
#include "lobject.h"
#include "lstate.h"


#define sizestring(s)	(sizeof(union TString)+((s)->len+1)*sizeof(char))

#define sizeudata(u)	(sizeof(union Udata)+(u)->len)

#define luaS_newliteral(L, s)	(luaS_newlstr(L, "" s, \
                                 (sizeof(s)/sizeof(char))-1))

#define luaS_fix(s)	l_setbit((s)->tsv.marked, FIXEDBIT)


/*
** test whether a string is a reserved word
*/
#define isreserved(s)	((s)->tsv.tt == LUA_TSHRSTR && (s)->tsv.extra > 0)


/*
** equality for short strings, which are always internalized
*/
#define eqshrstr(a,b)	check_exp((a)->tsv.tt == LUA_TSHRSTR, (a) == (b))

#define luaS_hash mln_luaS_hash
LUAI_FUNC unsigned int luaS_hash (const char *str, size_t l, unsigned int seed);
#define luaS_eqlngstr mln_luaS_eqlngstr
LUAI_FUNC int luaS_eqlngstr (TString *a, TString *b);
#define luaS_eqstr mln_luaS_eqstr
LUAI_FUNC int luaS_eqstr (TString *a, TString *b);
#define luaS_resize mln_luaS_resize
LUAI_FUNC void luaS_resize (lua_State *L, int newsize);
#define luaS_newudata mln_luaS_newudata
LUAI_FUNC Udata *luaS_newudata (lua_State *L, size_t s, Table *e);
#define luaS_newlstr mln_luaS_newlstr
LUAI_FUNC TString *luaS_newlstr (lua_State *L, const char *str, size_t l);
#define luaS_new mln_luaS_new
LUAI_FUNC TString *luaS_new (lua_State *L, const char *str);


#endif
