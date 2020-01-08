/*
** $Id: lua.h,v 1.218.1.5 2008/08/06 13:30:12 roberto Exp $
** Lua - An Extensible Extension Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*/


#ifndef lua_h
#define lua_h

#include <stdarg.h>
#include <stddef.h>


#include "mln_luaconf.h"


#define LUA_VERSION	"Lua 5.1"
#define LUA_RELEASE	"Lua 5.1.4"
#define LUA_VERSION_NUM	501
#define LUA_COPYRIGHT	"Copyright (C) 1994-2008 Lua.org, PUC-Rio"
#define LUA_AUTHORS 	"R. Ierusalimschy, L. H. de Figueiredo & W. Celes"


/* mark for precompiled code (`<esc>Lua') */
#define	LUA_SIGNATURE	"\033Lua"

/* option for multiple returns in `lua_pcall' and `lua_call' */
#define LUA_MULTRET	(-1)


/*
** pseudo-indices
*/
#define LUA_REGISTRYINDEX	(-10000)
#define LUA_ENVIRONINDEX	(-10001)
#define LUA_GLOBALSINDEX	(-10002)
#define lua_upvalueindex(i)	(LUA_GLOBALSINDEX-(i))


/* thread status; 0 is OK */
#define LUA_YIELD	1
#define LUA_ERRRUN	2
#define LUA_ERRSYNTAX	3
#define LUA_ERRMEM	4
#define LUA_ERRERR	5


typedef struct lua_State lua_State;
#define lua_CFunction mln_lua_CFunction
typedef int (*lua_CFunction) (lua_State *L);

#define lua_Reader mln_lua_Reader
/*
** functions that read/write blocks when loading/dumping Lua chunks
*/
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);
#define lua_Writer mln_lua_Writer
typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);

#define lua_Alloc mln_lua_Alloc
/*
** prototype for memory-allocation functions
*/
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);


/*
** basic types
*/
#define LUA_TNONE		(-1)

#define LUA_TNIL		0
#define LUA_TBOOLEAN		1
#define LUA_TLIGHTUSERDATA	2
#define LUA_TNUMBER		3
#define LUA_TSTRING		4
#define LUA_TTABLE		5
#define LUA_TFUNCTION		6
#define LUA_TUSERDATA		7
#define LUA_TTHREAD		8



/* minimum Lua stack available to a C function */
#define LUA_MINSTACK	20


/*
** generic extra include file
*/
#if defined(LUA_USER_H)
#include LUA_USER_H
#endif


/* type of numbers in Lua */
typedef LUA_NUMBER lua_Number;


/* type for integer functions */
typedef LUA_INTEGER lua_Integer;



/*
** state manipulation
*/
#define lua_newstate mln_lua_newstate
LUA_API lua_State *(lua_newstate) (lua_Alloc f, void *ud);
#define lua_close mln_lua_close
LUA_API void       (lua_close) (lua_State *L);
#define lua_newthread mln_lua_newthread
LUA_API lua_State *(lua_newthread) (lua_State *L);

#define lua_atpanic mln_lua_atpanic
LUA_API lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);


/*
** basic stack manipulation
*/
#define lua_gettop mln_lua_gettop
LUA_API int   (lua_gettop) (lua_State *L);
#define lua_settop mln_lua_settop
LUA_API void  (lua_settop) (lua_State *L, int idx);
#define lua_pushvalue mln_lua_pushvalue
LUA_API void  (lua_pushvalue) (lua_State *L, int idx);
#define lua_remove mln_lua_remove
LUA_API void  (lua_remove) (lua_State *L, int idx);
#define lua_insert mln_lua_insert
LUA_API void  (lua_insert) (lua_State *L, int idx);
#define lua_replace mln_lua_replace
LUA_API void  (lua_replace) (lua_State *L, int idx);
#define lua_checkstack mln_lua_checkstack
LUA_API int   (lua_checkstack) (lua_State *L, int sz);

#define lua_xmove mln_lua_xmove
LUA_API void  (lua_xmove) (lua_State *from, lua_State *to, int n);


/*
** access functions (stack -> C)
*/
#define lua_isinteger mln_lua_isinteger
LUA_API int             (lua_isinteger) (lua_State *L, int idx);
#define lua_isnumber mln_lua_isnumber
LUA_API int             (lua_isnumber) (lua_State *L, int idx);
#define lua_isstring mln_lua_isstring
LUA_API int             (lua_isstring) (lua_State *L, int idx);
#define lua_iscfunction mln_lua_iscfunction
LUA_API int             (lua_iscfunction) (lua_State *L, int idx);
#define lua_isuserdata mln_lua_isuserdata
LUA_API int             (lua_isuserdata) (lua_State *L, int idx);
#define lua_type mln_lua_type
LUA_API int             (lua_type) (lua_State *L, int idx);
#define lua_typename mln_lua_typename
LUA_API const char     *(lua_typename) (lua_State *L, int tp);

#define lua_equal mln_lua_equal
LUA_API int            (lua_equal) (lua_State *L, int idx1, int idx2);
#define lua_rawequal mln_lua_rawequal
LUA_API int            (lua_rawequal) (lua_State *L, int idx1, int idx2);
#define lua_lessthan mln_lua_lessthan
LUA_API int            (lua_lessthan) (lua_State *L, int idx1, int idx2);

#define lua_tonumber mln_lua_tonumber
LUA_API lua_Number      (lua_tonumber) (lua_State *L, int idx);
#define lua_tointeger mln_lua_tointeger
LUA_API lua_Integer     (lua_tointeger) (lua_State *L, int idx);
#define lua_toboolean mln_lua_toboolean
LUA_API int             (lua_toboolean) (lua_State *L, int idx);
#define lua_tolstring mln_lua_tolstring
LUA_API const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
#define lua_objlen mln_lua_objlen
LUA_API size_t          (lua_objlen) (lua_State *L, int idx);
#define lua_tocfunction mln_lua_tocfunction
LUA_API lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
#define lua_touserdata mln_lua_touserdata
LUA_API void           *(lua_touserdata) (lua_State *L, int idx);
#define lua_tothread mln_lua_tothread
LUA_API lua_State      *(lua_tothread) (lua_State *L, int idx);
#define lua_topointer mln_lua_topointer
LUA_API const void     *(lua_topointer) (lua_State *L, int idx);


/*
** push functions (C -> stack)
*/
#define lua_pushnil mln_lua_pushnil
LUA_API void  (lua_pushnil) (lua_State *L);
#define lua_pushnumber mln_lua_pushnumber
LUA_API void  (lua_pushnumber) (lua_State *L, lua_Number n);
#define lua_pushinteger mln_lua_pushinteger
LUA_API void  (lua_pushinteger) (lua_State *L, lua_Integer n);
#define lua_pushlstring mln_lua_pushlstring
LUA_API void  (lua_pushlstring) (lua_State *L, const char *s, size_t l);
#define lua_pushstring mln_lua_pushstring
LUA_API void  (lua_pushstring) (lua_State *L, const char *s);
#define lua_pushvfstring mln_lua_pushvfstring
LUA_API const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
#define lua_pushfstring mln_lua_pushfstring
LUA_API const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
#define lua_pushcclosure mln_lua_pushcclosure
LUA_API void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
#define lua_pushboolean mln_lua_pushboolean
LUA_API void  (lua_pushboolean) (lua_State *L, int b);
#define lua_pushlightuserdata mln_lua_pushlightuserdata
LUA_API void  (lua_pushlightuserdata) (lua_State *L, void *p);
#define lua_pushthread mln_lua_pushthread
LUA_API int   (lua_pushthread) (lua_State *L);


/*
** get functions (Lua -> stack)
*/
#define lua_gettable mln_lua_gettable
LUA_API void  (lua_gettable) (lua_State *L, int idx);
#define lua_getfield mln_lua_getfield
LUA_API void  (lua_getfield) (lua_State *L, int idx, const char *k);
#define lua_rawget mln_lua_rawget
LUA_API void  (lua_rawget) (lua_State *L, int idx);
#define lua_rawgeti mln_lua_rawgeti
LUA_API void  (lua_rawgeti) (lua_State *L, int idx, int n);
#define lua_createtable mln_lua_createtable
LUA_API void  (lua_createtable) (lua_State *L, int narr, int nrec);
#define lua_newuserdata mln_lua_newuserdata
LUA_API void *(lua_newuserdata) (lua_State *L, size_t sz);
#define lua_getmetatable mln_lua_getmetatable
LUA_API int   (lua_getmetatable) (lua_State *L, int objindex);
#define lua_getfenv mln_lua_getfenv
LUA_API void  (lua_getfenv) (lua_State *L, int idx);


/*
** set functions (stack -> Lua)
*/
#define lua_settable mln_lua_settable
LUA_API void  (lua_settable) (lua_State *L, int idx);
#define lua_setfield mln_lua_setfield
LUA_API void  (lua_setfield) (lua_State *L, int idx, const char *k);
#define lua_rawset mln_lua_rawset
LUA_API void  (lua_rawset) (lua_State *L, int idx);
#define lua_rawseti mln_lua_rawseti
LUA_API void  (lua_rawseti) (lua_State *L, int idx, int n);
#define lua_setmetatable mln_lua_setmetatable
LUA_API int   (lua_setmetatable) (lua_State *L, int objindex);
#define lua_setfenv mln_lua_setfenv
LUA_API int   (lua_setfenv) (lua_State *L, int idx);


/*
** `load' and `call' functions (load and run Lua code)
*/
#define lua_call mln_lua_call
LUA_API void  (lua_call) (lua_State *L, int nargs, int nresults);
#define lua_pcall mln_lua_pcall
LUA_API int   (lua_pcall) (lua_State *L, int nargs, int nresults, int errfunc);
#define lua_cpcall mln_lua_cpcall
LUA_API int   (lua_cpcall) (lua_State *L, lua_CFunction func, void *ud);
#define lua_load mln_lua_load
LUA_API int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname);

#define lua_dump mln_lua_dump
LUA_API int (lua_dump) (lua_State *L, lua_Writer writer, void *data);


/*
** coroutine functions
*/
#define lua_yield mln_lua_yield
LUA_API int  (lua_yield) (lua_State *L, int nresults);
#define lua_resume mln_lua_resume
LUA_API int  (lua_resume) (lua_State *L, int narg);
#define lua_status mln_lua_status
LUA_API int  (lua_status) (lua_State *L);

/*
** garbage-collection function and options
*/

#define LUA_GCSTOP		0
#define LUA_GCRESTART		1
#define LUA_GCCOLLECT		2
#define LUA_GCCOUNT		3
#define LUA_GCCOUNTB		4
#define LUA_GCSTEP		5
#define LUA_GCSETPAUSE		6
#define LUA_GCSETSTEPMUL	7

#define lua_gc mln_lua_gc
LUA_API int (lua_gc) (lua_State *L, int what, int data);


/*
** miscellaneous functions
*/

#define lua_error mln_lua_error
LUA_API int   (lua_error) (lua_State *L);

#define lua_next mln_lua_next
LUA_API int   (lua_next) (lua_State *L, int idx);

#define lua_concat mln_lua_concat
LUA_API void  (lua_concat) (lua_State *L, int n);

#define lua_getallocf mln_lua_getallocf
LUA_API lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
#define lua_setallocf mln_lua_setallocf
LUA_API void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);



/* 
** ===============================================================
** some useful macros
** ===============================================================
*/

#define lua_pop(L,n)		lua_settop(L, -(n)-1)

#define lua_newtable(L)		lua_createtable(L, 0, 0)

#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))

#define lua_pushcfunction(L,f)	lua_pushcclosure(L, (f), 0)

#define lua_strlen(L,i)		lua_objlen(L, (i))

#define lua_isfunction(L,n)	(lua_type(L, (n)) == LUA_TFUNCTION)
#define lua_istable(L,n)	(lua_type(L, (n)) == LUA_TTABLE)
#define lua_islightuserdata(L,n)	(lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
#define lua_isnil(L,n)		(lua_type(L, (n)) == LUA_TNIL)
#define lua_isboolean(L,n)	(lua_type(L, (n)) == LUA_TBOOLEAN)
#define lua_isthread(L,n)	(lua_type(L, (n)) == LUA_TTHREAD)
#define lua_isnone(L,n)		(lua_type(L, (n)) == LUA_TNONE)
#define lua_isnoneornil(L, n)	(lua_type(L, (n)) <= 0)

#define lua_pushliteral(L, s)	\
	lua_pushlstring(L, "" s, (sizeof(s)/sizeof(char))-1)

#define lua_setglobal(L,s)	lua_setfield(L, LUA_GLOBALSINDEX, (s))
#define lua_getglobal(L,s)	lua_getfield(L, LUA_GLOBALSINDEX, (s))

#define lua_tostring(L,i)	lua_tolstring(L, (i), NULL)



/*
** compatibility macros and functions
*/

#define lua_open()	luaL_newstate()

#define lua_getregistry(L)	lua_pushvalue(L, LUA_REGISTRYINDEX)

#define lua_getgccount(L)	lua_gc(L, LUA_GCCOUNT, 0)

#define lua_Chunkreader		lua_Reader
#define lua_Chunkwriter		lua_Writer


#define lua_setlevel mln_lua_setlevel
/* hack */
LUA_API void lua_setlevel	(lua_State *from, lua_State *to);


/*
** {======================================================================
** Debug API
** =======================================================================
*/


/*
** Event codes
*/
#define LUA_HOOKCALL	0
#define LUA_HOOKRET	1
#define LUA_HOOKLINE	2
#define LUA_HOOKCOUNT	3
#define LUA_HOOKTAILRET 4


/*
** Event masks
*/
#define LUA_MASKCALL	(1 << LUA_HOOKCALL)
#define LUA_MASKRET	(1 << LUA_HOOKRET)
#define LUA_MASKLINE	(1 << LUA_HOOKLINE)
#define LUA_MASKCOUNT	(1 << LUA_HOOKCOUNT)

typedef struct lua_Debug lua_Debug;  /* activation record */


#define lua_Hook mln_lua_Hook
/* Functions to be called by the debuger in specific events */
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);

#define lua_getstack mln_lua_getstack
LUA_API int lua_getstack (lua_State *L, int level, lua_Debug *ar);
#define lua_getinfo mln_lua_getinfo
LUA_API int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
#define lua_getlocal mln_lua_getlocal
LUA_API const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
#define lua_setlocal mln_lua_setlocal
LUA_API const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
#define lua_getupvalue mln_lua_getupvalue
LUA_API const char *lua_getupvalue (lua_State *L, int funcindex, int n);
#define lua_setupvalue mln_lua_setupvalue
LUA_API const char *lua_setupvalue (lua_State *L, int funcindex, int n);

#define lua_sethook mln_lua_sethook
LUA_API int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
#define lua_gethook mln_lua_gethook
LUA_API lua_Hook lua_gethook (lua_State *L);
#define lua_gethookmask mln_lua_gethookmask
LUA_API int lua_gethookmask (lua_State *L);
#define lua_gethookcount mln_lua_gethookcount
LUA_API int lua_gethookcount (lua_State *L);


struct lua_Debug {
  int event;
  const char *name;	/* (n) */
  const char *namewhat;	/* (n) `global', `local', `field', `method' */
  const char *what;	/* (S) `Lua', `C', `main', `tail' */
  const char *source;	/* (S) */
  int currentline;	/* (l) */
  int nups;		/* (u) number of upvalues */
  int linedefined;	/* (S) */
  int lastlinedefined;	/* (S) */
  char short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  int i_ci;  /* active function */
};

/* }====================================================================== */


/******************************************************************************
* Copyright (C) 1994-2008 Lua.org, PUC-Rio.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/


#endif
