/*
** $Id: lua.h,v 1.285.1.4 2015/02/21 14:04:50 roberto Exp $
** Lua - A Scripting Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*/


#ifndef lua_h
#define lua_h

#include <stdarg.h>
#include <stddef.h>


#include "mln_luaconf.h"


#define LUA_VERSION_MAJOR	"5"
#define LUA_VERSION_MINOR	"2"
#define LUA_VERSION_NUM		502
#define LUA_VERSION_RELEASE	"4"

#define LUA_VERSION	"Lua " LUA_VERSION_MAJOR "." LUA_VERSION_MINOR
#define LUA_RELEASE	LUA_VERSION "." LUA_VERSION_RELEASE
#define LUA_COPYRIGHT	LUA_RELEASE "  Copyright (C) 1994-2015 Lua.org, PUC-Rio"
#define LUA_AUTHORS	"R. Ierusalimschy, L. H. de Figueiredo, W. Celes"


/* mark for precompiled code ('<esc>Lua') */
#define LUA_SIGNATURE	"\033Lua"

/* option for multiple returns in 'lua_pcall' and 'lua_call' */
#define LUA_MULTRET	(-1)


/*
** pseudo-indices
*/
#define LUA_REGISTRYINDEX	LUAI_FIRSTPSEUDOIDX
#define lua_upvalueindex(i)	(LUA_REGISTRYINDEX - (i))


/* thread status */
#define LUA_OK		0
#define LUA_YIELD	1
#define LUA_ERRRUN	2
#define LUA_ERRSYNTAX	3
#define LUA_ERRMEM	4
#define LUA_ERRGCMM	5
#define LUA_ERRERR	6

typedef struct lua_State lua_State;

#define lua_CFunction mln_lua_CFunction
typedef int (*lua_CFunction) (lua_State *L);


/*
** functions that read/write blocks when loading/dumping Lua chunks
*/
#define lua_Reader mln_lua_Reader
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);

#define lua_Writer mln_lua_Writer
typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);


/*
** prototype for memory-allocation functions
*/
#define lua_Alloc mln_lua_Alloc
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

#define LUA_NUMTAGS		9



/* minimum Lua stack available to a C function */
#define LUA_MINSTACK	20


/* predefined values in the registry */
#define LUA_RIDX_MAINTHREAD	1
#define LUA_RIDX_GLOBALS	2
#define LUA_RIDX_LAST		LUA_RIDX_GLOBALS


/* type of numbers in Lua */
#define lua_Number mln_lua_Number
typedef LUA_NUMBER lua_Number;


/* type for integer functions */
#define lua_Integer mln_lua_Integer
typedef LUA_INTEGER lua_Integer;

/* unsigned integer type */
#define lua_Unsigned mln_lua_Unsigned
typedef LUA_UNSIGNED lua_Unsigned;



/*
** generic extra include file
*/
#if defined(LUA_USER_H)
#include LUA_USER_H
#endif


/*
** RCS ident string
*/
extern const char lua_ident[];


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

#define lua_version mln_lua_version
LUA_API const lua_Number *(lua_version) (lua_State *L);


/*
** basic stack manipulation
*/
#define lua_absindex mln_lua_absindex
LUA_API int   (lua_absindex) (lua_State *L, int idx);
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
#define lua_copy mln_lua_copy
LUA_API void  (lua_copy) (lua_State *L, int fromidx, int toidx);
#define lua_checkstack mln_lua_checkstack
LUA_API int   (lua_checkstack) (lua_State *L, int sz);

#define lua_xmove mln_lua_xmove
LUA_API void  (lua_xmove) (lua_State *from, lua_State *to, int n);


/*
** access functions (stack -> C)
*/
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

#define lua_tonumberx mln_lua_tonumberx
LUA_API lua_Number      (lua_tonumberx) (lua_State *L, int idx, int *isnum);
#define lua_tointegerx mln_lua_tointegerx
LUA_API lua_Integer     (lua_tointegerx) (lua_State *L, int idx, int *isnum);
#define lua_tounsignedx mln_lua_tounsignedx
LUA_API lua_Unsigned    (lua_tounsignedx) (lua_State *L, int idx, int *isnum);
#define lua_toboolean mln_lua_toboolean
LUA_API int             (lua_toboolean) (lua_State *L, int idx);
#define lua_tolstring mln_lua_tolstring
LUA_API const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
#define lua_rawlen mln_lua_rawlen
LUA_API size_t          (lua_rawlen) (lua_State *L, int idx);
#define lua_tocfunction mln_lua_tocfunction
LUA_API lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
#define lua_touserdata mln_lua_touserdata
LUA_API void	       *(lua_touserdata) (lua_State *L, int idx);
#define lua_tothread mln_lua_tothread
LUA_API lua_State      *(lua_tothread) (lua_State *L, int idx);
#define lua_topointer mln_lua_topointer
LUA_API const void     *(lua_topointer) (lua_State *L, int idx);


/*
** Comparison and arithmetic functions
*/

#define LUA_OPADD	0	/* ORDER TM */
#define LUA_OPSUB	1
#define LUA_OPMUL	2
#define LUA_OPDIV	3
#define LUA_OPMOD	4
#define LUA_OPPOW	5
#define LUA_OPUNM	6

#define lua_arith mln_lua_arith
LUA_API void  (lua_arith) (lua_State *L, int op);

#define LUA_OPEQ	0
#define LUA_OPLT	1
#define LUA_OPLE	2

#define lua_rawequal mln_lua_rawequal
LUA_API int   (lua_rawequal) (lua_State *L, int idx1, int idx2);
#define lua_compare mln_lua_compare
LUA_API int   (lua_compare) (lua_State *L, int idx1, int idx2, int op);


/*
** push functions (C -> stack)
*/
#define lua_pushnil mln_lua_pushnil
LUA_API void        (lua_pushnil) (lua_State *L);
#define lua_pushnumber mln_lua_pushnumber
LUA_API void        (lua_pushnumber) (lua_State *L, lua_Number n);
#define lua_pushinteger mln_lua_pushinteger
LUA_API void        (lua_pushinteger) (lua_State *L, lua_Integer n);
#define lua_pushunsigned mln_lua_pushunsigned
LUA_API void        (lua_pushunsigned) (lua_State *L, lua_Unsigned n);
#define lua_pushlstring mln_lua_pushlstring
LUA_API const char *(lua_pushlstring) (lua_State *L, const char *s, size_t l);
#define lua_pushstring mln_lua_pushstring
LUA_API const char *(lua_pushstring) (lua_State *L, const char *s);
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
#define lua_getglobal mln_lua_getglobal
LUA_API void  (lua_getglobal) (lua_State *L, const char *var);
#define lua_gettable mln_lua_gettable
LUA_API void  (lua_gettable) (lua_State *L, int idx);
#define lua_getfield mln_lua_getfield
LUA_API void  (lua_getfield) (lua_State *L, int idx, const char *k);
#define lua_rawget mln_lua_rawget
LUA_API void  (lua_rawget) (lua_State *L, int idx);
#define lua_rawgeti mln_lua_rawgeti
LUA_API void  (lua_rawgeti) (lua_State *L, int idx, int n);
#define lua_rawgetp mln_lua_rawgetp
LUA_API void  (lua_rawgetp) (lua_State *L, int idx, const void *p);
#define lua_createtable mln_lua_createtable
LUA_API void  (lua_createtable) (lua_State *L, int narr, int nrec);
#define lua_newuserdata mln_lua_newuserdata
LUA_API void *(lua_newuserdata) (lua_State *L, size_t sz);
#define lua_getmetatable mln_lua_getmetatable
LUA_API int   (lua_getmetatable) (lua_State *L, int objindex);
#define lua_getuservalue mln_lua_getuservalue
LUA_API void  (lua_getuservalue) (lua_State *L, int idx);


/*
** set functions (stack -> Lua)
*/
#define lua_setglobal mln_lua_setglobal
LUA_API void  (lua_setglobal) (lua_State *L, const char *var);
#define lua_settable mln_lua_settable
LUA_API void  (lua_settable) (lua_State *L, int idx);
#define lua_setfield mln_lua_setfield
LUA_API void  (lua_setfield) (lua_State *L, int idx, const char *k);
#define lua_rawset mln_lua_rawset
LUA_API void  (lua_rawset) (lua_State *L, int idx);
#define lua_rawseti mln_lua_rawseti
LUA_API void  (lua_rawseti) (lua_State *L, int idx, int n);
#define lua_rawsetp mln_lua_rawsetp
LUA_API void  (lua_rawsetp) (lua_State *L, int idx, const void *p);
#define lua_setmetatable mln_lua_setmetatable
LUA_API int   (lua_setmetatable) (lua_State *L, int objindex);
#define lua_setuservalue mln_lua_setuservalue
LUA_API void  (lua_setuservalue) (lua_State *L, int idx);


/*
** 'load' and 'call' functions (load and run Lua code)
*/
#define lua_callk mln_lua_callk
LUA_API void  (lua_callk) (lua_State *L, int nargs, int nresults, int ctx,
                           lua_CFunction k);
#define lua_call(L,n,r)		lua_callk(L, (n), (r), 0, NULL)

#define lua_getctx mln_lua_getctx
LUA_API int   (lua_getctx) (lua_State *L, int *ctx);

#define lua_pcallk mln_lua_pcallk
LUA_API int   (lua_pcallk) (lua_State *L, int nargs, int nresults, int errfunc,
                            int ctx, lua_CFunction k);
#define lua_pcall(L,n,r,f)	lua_pcallk(L, (n), (r), (f), 0, NULL)

#define lua_load mln_lua_load
LUA_API int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname,
                                        const char *mode);

#define lua_dump mln_lua_dump
LUA_API int (lua_dump) (lua_State *L, lua_Writer writer, void *data);


/*
** coroutine functions
*/
#define lua_yieldk mln_lua_yieldk
LUA_API int  (lua_yieldk) (lua_State *L, int nresults, int ctx,
                           lua_CFunction k);
#define lua_yield(L,n)		lua_yieldk(L, (n), 0, NULL)
#define lua_resume mln_lua_resume
LUA_API int  (lua_resume) (lua_State *L, lua_State *from, int narg);
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
#define LUA_GCSETMAJORINC	8
#define LUA_GCISRUNNING		9
#define LUA_GCGEN		10
#define LUA_GCINC		11

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
#define lua_len mln_lua_len
LUA_API void  (lua_len)    (lua_State *L, int idx);

#define lua_getallocf mln_lua_getallocf
LUA_API lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
#define lua_setallocf mln_lua_setallocf
LUA_API void      (lua_setallocf) (lua_State *L, lua_Alloc f, void *ud);



/*
** ===============================================================
** some useful macros
** ===============================================================
*/

#define lua_tonumber(L,i)	lua_tonumberx(L,i,NULL)
#define lua_tointeger(L,i)	lua_tointegerx(L,i,NULL)
#define lua_tounsigned(L,i)	lua_tounsignedx(L,i,NULL)

#define lua_pop(L,n)		lua_settop(L, -(n)-1)

#define lua_newtable(L)		lua_createtable(L, 0, 0)

#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))

#define lua_pushcfunction(L,f)	lua_pushcclosure(L, (f), 0)

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

#define lua_pushglobaltable(L)  \
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS)

#define lua_tostring(L,i)	lua_tolstring(L, (i), NULL)



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
#define LUA_HOOKTAILCALL 4


/*
** Event masks
*/
#define LUA_MASKCALL	(1 << LUA_HOOKCALL)
#define LUA_MASKRET	(1 << LUA_HOOKRET)
#define LUA_MASKLINE	(1 << LUA_HOOKLINE)
#define LUA_MASKCOUNT	(1 << LUA_HOOKCOUNT)

//#define lua_Debug mln_lua_Debug
typedef struct lua_Debug lua_Debug;  /* activation record */


/* Functions to be called by the debugger in specific events */
#define lua_Hook mln_lua_Hook
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);

#define lua_getstack mln_lua_getstack
LUA_API int (lua_getstack) (lua_State *L, int level, lua_Debug *ar);
#define lua_getinfo mln_lua_getinfo
LUA_API int (lua_getinfo) (lua_State *L, const char *what, lua_Debug *ar);
#define lua_getlocal mln_lua_getlocal
LUA_API const char *(lua_getlocal) (lua_State *L, const lua_Debug *ar, int n);
#define lua_setlocal mln_lua_setlocal
LUA_API const char *(lua_setlocal) (lua_State *L, const lua_Debug *ar, int n);
#define lua_getupvalue mln_lua_getupvalue
LUA_API const char *(lua_getupvalue) (lua_State *L, int funcindex, int n);
#define lua_setupvalue mln_lua_setupvalue
LUA_API const char *(lua_setupvalue) (lua_State *L, int funcindex, int n);

#define lua_upvalueid mln_lua_upvalueid
LUA_API void *(lua_upvalueid) (lua_State *L, int fidx, int n);
#define lua_upvaluejoin mln_lua_upvaluejoin
LUA_API void  (lua_upvaluejoin) (lua_State *L, int fidx1, int n1,
                                               int fidx2, int n2);
#define lua_sethook mln_lua_sethook
LUA_API int (lua_sethook) (lua_State *L, lua_Hook func, int mask, int count);
#define lua_gethook mln_lua_gethook
LUA_API lua_Hook (lua_gethook) (lua_State *L);
#define lua_gethookmask mln_lua_gethookmask
LUA_API int (lua_gethookmask) (lua_State *L);
#define lua_gethookcount mln_lua_gethookcount
LUA_API int (lua_gethookcount) (lua_State *L);

struct lua_Debug {
  int event;
  const char *name;	/* (n) */
  const char *namewhat;	/* (n) 'global', 'local', 'field', 'method' */
  const char *what;	/* (S) 'Lua', 'C', 'main', 'tail' */
  const char *source;	/* (S) */
  int currentline;	/* (l) */
  int linedefined;	/* (S) */
  int lastlinedefined;	/* (S) */
  unsigned char nups;	/* (u) number of upvalues */
  unsigned char nparams;/* (u) number of parameters */
  char isvararg;        /* (u) */
  char istailcall;	/* (t) */
  char short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  struct CallInfo *i_ci;  /* active function */
};

/* }====================================================================== */


/******************************************************************************
* Copyright (C) 1994-2015 Lua.org, PUC-Rio.
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
