/*
** $Id: lauxlib.h,v 1.88.1.1 2007/12/27 13:02:25 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/


#ifndef lauxlib_h
#define lauxlib_h


#include <stddef.h>
#include <stdio.h>

#include "mln_lua.h"


#if defined(LUA_COMPAT_GETN)
#define luaL_getn mln_luaL_getn
LUALIB_API int (luaL_getn) (lua_State *L, int t);
#define luaL_setn mln_luaL_setn
LUALIB_API void (luaL_setn) (lua_State *L, int t, int n);
#else
#define luaL_getn(L,i)          ((int)lua_objlen(L, i))
#define luaL_setn(L,i,j)        ((void)0)  /* no op! */
#endif

#if defined(LUA_COMPAT_OPENLIB)
#define luaL_openlib    mln_luaL_openlib
#define luaI_openlib	luaL_openlib
#else
#define luaI_openlib mln_luaI_openlib
#endif


/* extra error code for `luaL_load' */
#define LUA_ERRFILE     (LUA_ERRERR+1)


typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;


LUALIB_API void (luaI_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);
#define luaL_register mln_luaL_register
LUALIB_API void (luaL_register) (lua_State *L, const char *libname,
                                const luaL_Reg *l);
#define luaL_getmetafield mln_luaL_getmetafield
LUALIB_API int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
#define luaL_callmeta mln_luaL_callmeta
LUALIB_API int (luaL_callmeta) (lua_State *L, int obj, const char *e);
#define luaL_typerror mln_luaL_typerror
LUALIB_API int (luaL_typerror) (lua_State *L, int narg, const char *tname);
#define luaL_argerror mln_luaL_argerror
LUALIB_API int (luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
#define luaL_checklstring mln_luaL_checklstring
LUALIB_API const char *(luaL_checklstring) (lua_State *L, int numArg,
                                                          size_t *l);
#define luaL_tolstring mln_luaL_tolstring
LUALIB_API const char *(luaL_tolstring) (lua_State *L, int numArg,
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

#define luaL_checkstack mln_luaL_checkstack
LUALIB_API void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
#define luaL_checktype mln_luaL_checktype
LUALIB_API void (luaL_checktype) (lua_State *L, int narg, int t);
#define luaL_checkany mln_luaL_checkany
LUALIB_API void (luaL_checkany) (lua_State *L, int narg);

#define luaL_newmetatable mln_luaL_newmetatable
LUALIB_API int   (luaL_newmetatable) (lua_State *L, const char *tname);
#define luaL_checkudata mln_luaL_checkudata
LUALIB_API void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);

#define luaL_where mln_luaL_where
LUALIB_API void (luaL_where) (lua_State *L, int lvl);
#define luaL_error mln_luaL_error
LUALIB_API int (luaL_error) (lua_State *L, const char *fmt, ...);

#define luaL_checkoption mln_luaL_checkoption
LUALIB_API int (luaL_checkoption) (lua_State *L, int narg, const char *def,
                                   const char *const lst[]);

#define luaL_ref mln_luaL_ref
LUALIB_API int (luaL_ref) (lua_State *L, int t);
#define luaL_unref mln_luaL_unref
LUALIB_API void (luaL_unref) (lua_State *L, int t, int ref);

#define luaL_loadfile mln_luaL_loadfile
LUALIB_API int (luaL_loadfile) (lua_State *L, const char *filename);
#define luaL_loadbuffer mln_luaL_loadbuffer
LUALIB_API int (luaL_loadbuffer) (lua_State *L, const char *buff, size_t sz,
                                  const char *name);
#define luaL_loadstring mln_luaL_loadstring
LUALIB_API int (luaL_loadstring) (lua_State *L, const char *s);

#define luaL_newstate mln_luaL_newstate
LUALIB_API lua_State *(luaL_newstate) (void);


#define luaL_gsub mln_luaL_gsub
LUALIB_API const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

#define luaL_findtable mln_luaL_findtable
LUALIB_API const char *(luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);




/*
** ===============================================================
** some useful macros
** ===============================================================
*/

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

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/



typedef struct luaL_Buffer {
  char *p;			/* current position in buffer */
  int lvl;  /* number of strings in the stack (level) */
  lua_State *L;
  char buffer[LUAL_BUFFERSIZE];
} luaL_Buffer;

#define luaL_addchar(B,c) \
  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), \
   (*(B)->p++ = (char)(c)))

/* compatibility only */
#define luaL_putchar(B,c)	luaL_addchar(B,c)

#define luaL_addsize(B,n)	((B)->p += (n))

#define luaL_buffinit mln_luaL_buffinit
LUALIB_API void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
#define luaL_prepbuffer mln_luaL_prepbuffer
LUALIB_API char *(luaL_prepbuffer) (luaL_Buffer *B);
#define luaL_addlstring mln_luaL_addlstring
LUALIB_API void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
#define luaL_addstring mln_luaL_addstring
LUALIB_API void (luaL_addstring) (luaL_Buffer *B, const char *s);
#define luaL_addvalue mln_luaL_addvalue
LUALIB_API void (luaL_addvalue) (luaL_Buffer *B);
#define luaL_pushresult mln_luaL_pushresult
LUALIB_API void (luaL_pushresult) (luaL_Buffer *B);


/* }====================================================== */


/* compatibility with ref system */

/* pre-defined references */
#define LUA_NOREF       (-2)
#define LUA_REFNIL      (-1)

#define lua_ref(L,lock) ((lock) ? luaL_ref(L, LUA_REGISTRYINDEX) : \
      (lua_pushstring(L, "unlocked references are obsolete"), lua_error(L), 0))

#define lua_unref(L,ref)        luaL_unref(L, LUA_REGISTRYINDEX, (ref))

#define lua_getref(L,ref)       lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))


#define luaL_reg	luaL_Reg

#endif


