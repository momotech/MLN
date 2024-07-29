/*
** $Id: llex.h,v 1.72.1.1 2013/04/12 18:48:47 roberto Exp $
** Lexical Analyzer
** See Copyright Notice in lua.h
*/

#ifndef llex_h
#define llex_h

#include "lobject.h"
#include "lzio.h"
#include "lparser.h"

#define FIRST_RESERVED	257



/*
* WARNING: if you change the order of this enumeration,
* grep "ORDER RESERVED"
*/
#define RESERVED mln_RESERVED
enum RESERVED {
  /* terminal symbols denoted by reserved words */
  TK_AND = FIRST_RESERVED, TK_BREAK,
  TK_DO, TK_ELSE, TK_ELSEIF, TK_END, TK_FALSE, TK_FOR, TK_FUNCTION,
  TK_GOTO, TK_IF, TK_IN, TK_LOCAL, TK_NIL, TK_NOT, TK_OR, TK_REPEAT,
  TK_RETURN, TK_THEN, TK_TRUE, TK_UNTIL, TK_WHILE,
  /* other terminal symbols */
  TK_CONCAT, TK_DOTS, TK_EQ, TK_GE, TK_LE, TK_NE, TK_DBCOLON, TK_EOS,
  TK_NUMBER, TK_NAME, TK_STRING
};

/* number of reserved words */
#define NUM_RESERVED	(cast(int, TK_WHILE-FIRST_RESERVED+1))


typedef union {
  lua_Number r;
  TString *ts;
} SemInfo;  /* semantics information */


//#define Token mln_Token
typedef struct Token {
  int token;
  SemInfo seminfo;
} Token;


/* state of the lexer plus state of the parser when shared by all
   functions */
typedef struct LexState {
  int current;  /* current character (charint) */
  int linenumber;  /* input line counter */
  int lastline;  /* line of last token `consumed' */
  Token t;  /* current token */
  Token lookahead;  /* look ahead token */
  struct FuncState *fs;  /* current function (parser) */
  struct lua_State *L;
  ZIO *z;  /* input stream */
  Mbuffer *buff;  /* buffer for tokens */
  struct Dyndata *dyd;  /* dynamic structures used by the parser */
  TString *source;  /* current source name */
  TString *envn;  /* environment variable name */
  char decpoint;  /* locale decimal point */
} LexState;


#define luaX_init mln_luaX_init
LUAI_FUNC void luaX_init (lua_State *L);
#define luaX_setinput mln_luaX_setinput
LUAI_FUNC void luaX_setinput (lua_State *L, LexState *ls, ZIO *z,
                              TString *source, int firstchar);
#define luaX_newstring mln_luaX_newstring
LUAI_FUNC TString *luaX_newstring (LexState *ls, const char *str, size_t l);
#define luaX_next mln_luaX_next
LUAI_FUNC void luaX_next (LexState *ls);
#define luaX_lookahead mln_luaX_lookahead
LUAI_FUNC int luaX_lookahead (LexState *ls);
#define luaX_syntaxerror mln_luaX_syntaxerror
LUAI_FUNC l_noret luaX_syntaxerror (LexState *ls, const char *s);
#define luaX_token2str mln_luaX_token2str
LUAI_FUNC const char *luaX_token2str (LexState *ls, int token);


#endif
