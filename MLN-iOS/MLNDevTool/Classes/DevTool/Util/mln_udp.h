#ifndef UDP_H
#define UDP_H
/*=========================================================================*\
* UDP object
* LuaSocket toolkit
*
* The udp.h module provides LuaSocket with support for UDP protocol
* (AF_INET, SOCK_DGRAM).
*
* Two classes are defined: connected and unconnected. UDP objects are
* originally unconnected. They can be "connected" to a given address 
* with a call to the setpeername function. The same function can be used to
* break the connection.
\*=========================================================================*/
#include "mln_lua.h"

#include "mln_timeout.h"
#include "mln_socket.h"

/* can't be larger than wsocket.c MAXCHUNK!!! */
#define UDP_DATAGRAMSIZE 8192

typedef struct mln_t_udp_ {
    mln_t_socket sock;
    mln_t_timeout tm;
    int family;
} mln_t_udp;
typedef mln_t_udp *mln_p_udp;

int mln_udp_open(lua_State *L);

#endif /* UDP_H */
