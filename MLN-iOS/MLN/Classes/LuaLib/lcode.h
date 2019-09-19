/*
** $Id: lcode.h,v 1.48.1.1 2007/12/27 13:02:25 roberto Exp $
** Code generator for Lua
** See Copyright Notice in lua.h
*/

#ifndef lcode_h
#define lcode_h

#include "llex.h"
#include "lobject.h"
#include "lopcodes.h"
#include "lparser.h"


/*
** Marks the end of a patch list. It is an invalid value both as an absolute
** address, and as a list link (would link an element to itself).
*/
#define NO_JUMP (-1)


/*
** grep "ORDER OPR" if you change these enums
*/
typedef enum BinOpr {
  OPR_ADD, OPR_SUB, OPR_MUL, OPR_DIV, OPR_MOD, OPR_POW,
  OPR_CONCAT,
  OPR_NE, OPR_EQ,
  OPR_LT, OPR_LE, OPR_GT, OPR_GE,
  OPR_AND, OPR_OR,
  OPR_NOBINOPR
} BinOpr;


typedef enum UnOpr { OPR_MINUS, OPR_NOT, OPR_LEN, OPR_NOUNOPR } UnOpr;


#define getcode(fs,e)	((fs)->f->code[(e)->u.s.info])

#define luaK_codeAsBx(fs,o,A,sBx)	luaK_codeABx(fs,o,A,(sBx)+MAXARG_sBx)

#define luaK_setmultret(fs,e)	luaK_setreturns(fs, e, LUA_MULTRET)

#define luaK_codeABx mln_luaK_codeABx
LUAI_FUNC int luaK_codeABx (FuncState *fs, OpCode o, int A, unsigned int Bx);
#define luaK_codeABC mln_luaK_codeABC
LUAI_FUNC int luaK_codeABC (FuncState *fs, OpCode o, int A, int B, int C);
#define luaK_fixline mln_luaK_fixline
LUAI_FUNC void luaK_fixline (FuncState *fs, int line);
#define luaK_nil mln_luaK_nil
LUAI_FUNC void luaK_nil (FuncState *fs, int from, int n);
#define luaK_reserveregs mln_luaK_reserveregs
LUAI_FUNC void luaK_reserveregs (FuncState *fs, int n);
#define luaK_checkstack mln_luaK_checkstack
LUAI_FUNC void luaK_checkstack (FuncState *fs, int n);
#define luaK_stringK mln_luaK_stringK
LUAI_FUNC int luaK_stringK (FuncState *fs, TString *s);
#define luaK_numberK mln_luaK_numberK
LUAI_FUNC int luaK_numberK (FuncState *fs, lua_Number r);
#define luaK_dischargevars mln_luaK_dischargevars
LUAI_FUNC void luaK_dischargevars (FuncState *fs, expdesc *e);
#define luaK_exp2anyreg mln_luaK_exp2anyreg
LUAI_FUNC int luaK_exp2anyreg (FuncState *fs, expdesc *e);
#define luaK_exp2nextreg mln_luaK_exp2nextreg
LUAI_FUNC void luaK_exp2nextreg (FuncState *fs, expdesc *e);
#define luaK_exp2val mln_luaK_exp2val
LUAI_FUNC void luaK_exp2val (FuncState *fs, expdesc *e);
#define luaK_exp2RK mln_luaK_exp2RK
LUAI_FUNC int luaK_exp2RK (FuncState *fs, expdesc *e);
#define luaK_self mln_luaK_self
LUAI_FUNC void luaK_self (FuncState *fs, expdesc *e, expdesc *key);
#define luaK_indexed mln_luaK_indexed
LUAI_FUNC void luaK_indexed (FuncState *fs, expdesc *t, expdesc *k);
#define luaK_goiftrue mln_luaK_goiftrue
LUAI_FUNC void luaK_goiftrue (FuncState *fs, expdesc *e);
#define luaK_storevar mln_luaK_storevar
LUAI_FUNC void luaK_storevar (FuncState *fs, expdesc *var, expdesc *e);
#define luaK_setreturns mln_luaK_setreturns
LUAI_FUNC void luaK_setreturns (FuncState *fs, expdesc *e, int nresults);
#define luaK_setoneret mln_luaK_setoneret
LUAI_FUNC void luaK_setoneret (FuncState *fs, expdesc *e);
#define luaK_jump mln_luaK_jump
LUAI_FUNC int luaK_jump (FuncState *fs);
#define luaK_ret mln_luaK_ret
LUAI_FUNC void luaK_ret (FuncState *fs, int first, int nret);
#define luaK_patchlist mln_luaK_patchlist
LUAI_FUNC void luaK_patchlist (FuncState *fs, int list, int target);
#define luaK_patchtohere mln_luaK_patchtohere
LUAI_FUNC void luaK_patchtohere (FuncState *fs, int list);
#define luaK_concat mln_luaK_concat
LUAI_FUNC void luaK_concat (FuncState *fs, int *l1, int l2);
#define luaK_getlabel mln_luaK_getlabel
LUAI_FUNC int luaK_getlabel (FuncState *fs);
#define luaK_prefix mln_luaK_prefix
LUAI_FUNC void luaK_prefix (FuncState *fs, UnOpr op, expdesc *v);
#define luaK_infix mln_luaK_infix
LUAI_FUNC void luaK_infix (FuncState *fs, BinOpr op, expdesc *v);
#define luaK_posfix mln_luaK_posfix
LUAI_FUNC void luaK_posfix (FuncState *fs, BinOpr op, expdesc *v1, expdesc *v2);
#define luaK_setlist mln_luaK_setlist
LUAI_FUNC void luaK_setlist (FuncState *fs, int base, int nelems, int tostore);


#endif
