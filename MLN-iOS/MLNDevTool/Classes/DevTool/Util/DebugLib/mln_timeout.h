#ifndef TIMEOUT_H
#define TIMEOUT_H
/*=========================================================================*\
* Timeout management functions
* LuaSocket toolkit
\*=========================================================================*/
#include "mln_lua.h"

/* timeout control structure */
typedef struct mln_t_timeout_ {
    double block;          /* maximum time for blocking calls */
    double total;          /* total number of miliseconds for operation */
    double start;          /* time of start of operation */
} mln_t_timeout;
typedef mln_t_timeout *mln_p_timeout;

int mln_timeout_open(lua_State *L);
void mln_timeout_init(mln_p_timeout tm, double block, double total);
double mln_timeout_get(mln_p_timeout tm);
double mln_timeout_getretry(mln_p_timeout tm);
mln_p_timeout mln_timeout_markstart(mln_p_timeout tm);
double mln_timeout_getstart(mln_p_timeout tm);
double mln_timeout_gettime(void);
int mln_timeout_meth_settimeout(lua_State *L, mln_p_timeout tm);

#define timeout_iszero(tm)   ((tm)->block == 0.0)

#endif /* TIMEOUT_H */
