#ifndef INET_H 
#define INET_H 
/*=========================================================================*\
* Internet domain functions
* LuaSocket toolkit
*
* This module implements the creation and connection of internet domain
* sockets, on top of the socket.h interface, and the interface of with the
* resolver. 
*
* The function inet_aton is provided for the platforms where it is not
* available. The module also implements the interface of the internet
* getpeername and getsockname functions as seen by Lua programs.
*
* The Lua functions toip and tohostname are also implemented here.
\*=========================================================================*/
#include "mln_lua.h"
#include "mln_socket.h"
#include "mln_timeout.h"

#ifdef _WIN32
#define LUASOCKET_INET_ATON
#endif

int mln_inet_open(lua_State *L);

const char *mln_inet_trycreate(mln_p_socket ps, int family, int type);
const char *mln_inet_tryconnect(mln_p_socket ps, int *family, const char *address,
        const char *serv, mln_p_timeout tm, struct addrinfo *connecthints);
const char *mln_inet_trybind(mln_p_socket ps, const char *address, const char *serv,
        struct addrinfo *bindhints);
const char *mln_inet_trydisconnect(mln_p_socket ps, int family, mln_p_timeout tm);
const char *mln_inet_tryaccept(mln_p_socket server, int family, mln_p_socket client, mln_p_timeout tm);

int mln_inet_meth_getpeername(lua_State *L, mln_p_socket ps, int family);
int mln_inet_meth_getsockname(lua_State *L, mln_p_socket ps, int family);

int mln_inet_optfamily(lua_State* L, int narg, const char* def);
int mln_inet_optsocktype(lua_State* L, int narg, const char* def);

#ifdef LUASOCKET_INET_ATON
int inet_aton(const char *cp, struct in_addr *inp);
#endif

#ifdef LUASOCKET_INET_PTON
const char *inet_ntop(int af, const void *src, char *dst, socklen_t cnt);
int inet_pton(int af, const char *src, void *dst);
#endif

#endif /* INET_H */
