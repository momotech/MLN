#ifndef TCP_H
#define TCP_H
/*=========================================================================*\
* TCP object
* LuaSocket toolkit
*
* The tcp.h module is basicly a glue that puts together modules buffer.h,
* timeout.h socket.h and inet.h to provide the LuaSocket TCP (AF_INET,
* SOCK_STREAM) support.
*
* Three classes are defined: master, client and server. The master class is
* a newly created tcp object, that has not been bound or connected. Server
* objects are tcp objects bound to some local address. Client objects are
* tcp objects either connected to some address or returned by the accept
* method of a server object.
\*=========================================================================*/
#include "mln_lua.h"

#include "mln_buffer.h"
#include "mln_timeout.h"
#include "mln_socket.h"

typedef struct mln_t_tcp_ {
    mln_t_socket sock;
    mln_t_io io;
    mln_t_buffer buf;
    mln_t_timeout tm;
    int family;
} mln_t_tcp;

typedef mln_t_tcp *mln_p_tcp;

int mln_tcp_open(lua_State *L);

#endif /* TCP_H */
