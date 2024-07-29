/*
** $Id: lauxlib.h,v 1.120.1.1 2013/04/12 18:48:47 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/


#ifndef lauxlib_h
#define lauxlib_h


#include <stddef.h>
#include <stdio.h>

#include "mln_luaconf.h"
#include "mln_lua.h"



/* extra error code for `luaL_load' */
#define LUA_ERRFILE     (LUA_ERRERR+1)

//#define BinOpr mln_BinOpr
typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;


#define luaL_checkversion_ mln_luaL_checkversion_
LUALIB_API void (luaL_checkversion_) (lua_State *L, lua_Number ver);
#define luaL_checkversion(L)	luaL_checkversion_(L, LUA_VERSION_NUM)

#define luaL_getmetafield mln_luaL_getmetafield
LUALIB_API int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
#define luaL_callmeta mln_luaL_callmeta
LUALIB_API int (luaL_callmeta) (lua_State *L, int obj, const char *e);
#define luaL_tolstring mln_luaL_tolstring
LUALIB_API const char *(luaL_tolstring) (lua_State *L, int idx, size_t *len);
#define luaL_argerror mln_luaL_argerror
LUALIB_API int (luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
#define luaL_checklstring mln_luaL_checklstring
LUALIB_API const char *(luaL_checklstring) (lua_State *L, int numArg,
                                                          size_t *l);
#define luaL_optlstring mln_luaL_optlstring
LUALIB_API const char *(luaL_optlstring) (lua_State *L, int numArg,
                                          const char *def, size_t *l);
#define luaL_checknumber mln_luaL_checknumber
LUALIB_API lua_Number (luaL_checknumber) (lua_State *L, int numArg);
#define luaL_optnumber mln_luaL_optnumber
LUALIB_API lua_Number (luaL_optnumber) (lua_State *L, int nArg, lua_Number def);

#define luaL_checkinteger mln_luaL_checkinteger
LUALIB_API lua_Integer (luaL_checkinteger) (lua_State *L, int numArg);
#define luaL_optinteger mln_luaL_optinteger
LUALIB_API lua_Integer (luaL_optinteger) (lua_State *L, int nArg,
                                          lua_Integer def);
#define luaL_checkunsigned mln_luaL_checkunsigned
LUALIB_API lua_Unsigned (luaL_checkunsigned) (lua_State *L, int numArg);
#define luaL_optunsigned mln_luaL_optunsigned
LUALIB_API lua_Unsigned (luaL_optunsigned) (lua_State *L, int numArg,
                                            lua_Unsigned def);

#define luaL_checkstack mln_luaL_checkstack
LUALIB_API void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
#define luaL_checktype mln_luaL_checktype
LUALIB_API void (luaL_checktype) (lua_State *L, int narg, int t);
#define luaL_checkany mln_luaL_checkany
LUALIB_API void (luaL_checkany) (lua_State *L, int narg);

#define luaL_newmetatable mln_luaL_newmetatable
LUALIB_API int   (luaL_newmetatable) (lua_State *L, const char *tname);
#define luaL_setmetatable mln_luaL_setmetatable
LUALIB_API void  (luaL_setmetatable) (lua_State *L, const char *tname);
#define luaL_testudata mln_luaL_testudata
LUALIB_API void *(luaL_testudata) (lua_State *L, int ud, const char *tname);
#define luaL_checkudata mln_luaL_checkudata
LUALIB_API void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);

#define luaL_where mln_luaL_where
LUALIB_API void (luaL_where) (lua_State *L, int lvl);
#define luaL_error mln_luaL_error
LUALIB_API int (luaL_error) (lua_State *L, const char *fmt, ...);

#define luaL_checkoption mln_luaL_checkoption
LUALIB_API int (luaL_checkoption) (lua_State *L, int narg, const char *def,
                                   const char *const lst[]);

#define luaL_fileresult mln_luaL_fileresult
LUALIB_API int (luaL_fileresult) (lua_State *L, int stat, const char *fname);
#define luaL_execresult mln_luaL_execresult
LUALIB_API int (luaL_execresult) (lua_State *L, int stat);

/* pre-defined references */
#define LUA_NOREF       (-2)
#define LUA_REFNIL      (-1)

#define luaL_ref mln_luaL_ref
LUALIB_API int (luaL_ref) (lua_State *L, int t);
#define luaL_unref mln_luaL_unref
LUALIB_API void (luaL_unref) (lua_State *L, int t, int ref);

#define luaL_loadfilex mln_luaL_loadfilex
LUALIB_API int (luaL_loadfilex) (lua_State *L, const char *filename,
                                               const char *mode);

#define luaL_loadfile(L,f)	luaL_loadfilex(L,f,NULL)

#define luaL_loadbufferx mln_luaL_loadbufferx
LUALIB_API int (luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                                   const char *name, const char *mode);
#define luaL_loadstring mln_luaL_loadstring
LUALIB_API int (luaL_loadstring) (lua_State *L, const char *s);

#define luaL_newstate mln_luaL_newstate
LUALIB_API lua_State *(luaL_newstate) (void);

#define luaL_len mln_luaL_len
LUALIB_API int (luaL_len) (lua_State *L, int idx);

#define luaL_gsub mln_luaL_gsub
LUALIB_API const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

#define luaL_setfuncs mln_luaL_setfuncs
LUALIB_API void (luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);

#define luaL_getsubtable mln_luaL_getsubtable
LUALIB_API int (luaL_getsubtable) (lua_State *L, int idx, const char *fname);

#define luaL_traceback mln_luaL_traceback
LUALIB_API void (luaL_traceback) (lua_State *L, lua_State *L1,
                                  const char *msg, int level);

#define luaL_requiref mln_luaL_requiref
LUALIB_API void (luaL_requiref) (lua_State *L, const char *modname,
                                 lua_CFunction openf, int glb);

/*
** ===============================================================
** some useful macros
** ===============================================================
*/


#define luaL_newlibtable(L,l)	\
  lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)	(luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))

#define luaL_argcheck(L, cond,numarg,extramsg)	\
		((void)((cond) || luaL_argerror(L, (numarg), (extramsg))))
#define luaL_checkstring(L,n)	(luaL_checklstring(L, (n), NULL))
#define luaL_optstring(L,n,d)	(luaL_optlstring(L, (n), (d), NULL))
#define luaL_checkint(L,n)	((int)luaL_checkinteger(L, (n)))
#define luaL_optint(L,n,d)	((int)luaL_optinteger(L, (n), (d)))
#define luaL_checklong(L,n)	((long)luaL_checkinteger(L, (n)))
#define luaL_optlong(L,n,d)	((long)luaL_optinteger(L, (n), (d)))

#define luaL_typename(L,i)	lua_typename(L, lua_type(L,(i)))

#define luaL_dofile(L, fn) \
	(luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_dostring(L, s) \
	(luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_getmetatable(L,n)	(lua_getfield(L, LUA_REGISTRYINDEX, (n)))

#define luaL_opt(L,f,n,d)	(lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))

#define luaL_loadbuffer(L,s,sz,n)	luaL_loadbufferx(L,s,sz,n,NULL)


/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/

//#define luaL_Buffer mln_luaL_Buffer
typedef struct luaL_Buffer {
  char *b;  /* buffer address */
  size_t size;  /* buffer size */
  size_t n;  /* number of characters in buffer */
  lua_State *L;
  char initb[LUAL_BUFFERSIZE];  /* initial buffer */
} luaL_Buffer;


#define luaL_addchar(B,c) \
  ((void)((B)->n < (B)->size || luaL_prepbuffsize((B), 1)), \
   ((B)->b[(B)->n++] = (c)))

#define luaL_addsize(B,s)	((B)->n += (s))

#define luaL_buffinit mln_luaL_buffinit
LUALIB_API void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
#define luaL_prepbuffsize mln_luaL_prepbuffsize
LUALIB_API char *(luaL_prepbuffsize) (luaL_Buffer *B, size_t sz);
#define luaL_addlstring mln_luaL_addlstring
LUALIB_API void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
#define luaL_addstring mln_luaL_addstring
LUALIB_API void (luaL_addstring) (luaL_Buffer *B, const char *s);
#define luaL_addvalue mln_luaL_addvalue
LUALIB_API void (luaL_addvalue) (luaL_Buffer *B);
#define luaL_pushresult mln_luaL_pushresult
LUALIB_API void (luaL_pushresult) (luaL_Buffer *B);
#define luaL_pushresultsize mln_luaL_pushresultsize
LUALIB_API void (luaL_pushresultsize) (luaL_Buffer *B, size_t sz);
#define luaL_buffinitsize mln_luaL_buffinitsize
LUALIB_API char *(luaL_buffinitsize) (lua_State *L, luaL_Buffer *B, size_t sz);

#define luaL_prepbuffer(B)	luaL_prepbuffsize(B, LUAL_BUFFERSIZE)

/* }====================================================== */



/*
** {======================================================
** File handles for IO library
** =======================================================
*/

/*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*/

#define LUA_FILEHANDLE          "FILE*"


//#define luaL_Stream mln_luaL_Stream
typedef struct luaL_Stream {
  FILE *f;  /* stream (NULL for incompletely created streams) */
  lua_CFunction closef;  /* to close stream (NULL for closed streams) */
} luaL_Stream;

/* }====================================================== */



/* compatibility with old module system */
#if defined(LUA_COMPAT_MODULE)

#define luaL_pushmodule mln_luaL_pushmodule
LUALIB_API void (luaL_pushmodule) (lua_State *L, const char *modname,
                                   int sizehint);
#define luaL_openlib mln_luaL_openlib
LUALIB_API void (luaL_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);

#define luaL_findtable mln_luaL_findtable
const char *(luaL_findtable) (lua_State *L, int idx,
                                   const char *fname, int szhint);

#define luaL_register(L,n,l)	(luaL_openlib(L,(n),(l),0))

#endif


#endif


