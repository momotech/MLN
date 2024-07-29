/*
** $Id: ltm.h,v 2.11.1.1 2013/04/12 18:48:47 roberto Exp $
** Tag methods
** See Copyright Notice in lua.h
*/

#ifndef ltm_h
#define ltm_h


#include "lobject.h"


/*
* WARNING: if you change the order of this enumeration,
* grep "ORDER TM"
*/
#define TMS mln_TMS
typedef enum {
  TM_INDEX,
  TM_NEWINDEX,
  TM_GC,
  TM_MODE,
  TM_LEN,
  TM_EQ,  /* last tag method with `fast' access */
  TM_ADD,
  TM_SUB,
  TM_MUL,
  TM_DIV,
  TM_MOD,
  TM_POW,
  TM_UNM,
  TM_LT,
  TM_LE,
  TM_CONCAT,
  TM_CALL,
  TM_N		/* number of elements in the enum */
} TMS;



#define gfasttm(g,et,e) ((et) == NULL ? NULL : \
  ((et)->flags & (1u<<(e))) ? NULL : luaT_gettm(et, e, (g)->tmname[e]))

#define fasttm(l,et,e)	gfasttm(G(l), et, e)

#define ttypename(x)	luaT_typenames_[(x) + 1]
#define objtypename(x)	ttypename(ttypenv(x))

#define luaT_typenames_ mln_luaT_typenames_
LUAI_DDEC const char *const luaT_typenames_[LUA_TOTALTAGS];

#define luaT_gettm mln_luaT_gettm
LUAI_FUNC const TValue *luaT_gettm (Table *events, TMS event, TString *ename);
#define luaT_gettmbyobj mln_luaT_gettmbyobj
LUAI_FUNC const TValue *luaT_gettmbyobj (lua_State *L, const TValue *o,
                                                       TMS event);
#define luaT_init mln_luaT_init
LUAI_FUNC void luaT_init (lua_State *L);

#endif
