#ifndef SOCKET_H
#define SOCKET_H
/*=========================================================================*\
* Socket compatibilization module
* LuaSocket toolkit
*
* BSD Sockets and WinSock are similar, but there are a few irritating
* differences. Also, not all *nix platforms behave the same. This module
* (and the associated usocket.h and wsocket.h) factor these differences and
* creates a interface compatible with the io.h module.
\*=========================================================================*/
#include "mln_io.h"

/*=========================================================================*\
* Platform specific compatibilization
\*=========================================================================*/
#ifdef _WIN32
#include "wsocket.h"
#else
#include "mln_usocket.h"
#endif

/*=========================================================================*\
* The connect and accept functions accept a timeout and their
* implementations are somewhat complicated. We chose to move
* the timeout control into this module for these functions in
* order to simplify the modules that use them. 
\*=========================================================================*/
#include "mln_timeout.h"

/* we are lazy... */
typedef struct sockaddr mln_SA;

/*=========================================================================*\
* Functions bellow implement a comfortable platform independent 
* interface to sockets
\*=========================================================================*/
int mln_socket_open(void);
int mln_socket_close(void);
void mln_socket_destroy(mln_p_socket ps);
void mln_socket_shutdown(mln_p_socket ps, int how); 
int mln_socket_sendto(mln_p_socket ps, const char *data, size_t count, 
        size_t *sent, mln_SA *addr, socklen_t addr_len, mln_p_timeout tm);
int mln_socket_recvfrom(mln_p_socket ps, char *data, size_t count, 
        size_t *got, mln_SA *addr, socklen_t *addr_len, mln_p_timeout tm);

void mln_socket_setnonblocking(mln_p_socket ps);
void mln_socket_setblocking(mln_p_socket ps);

int mln_socket_waitfd(mln_p_socket ps, int sw, mln_p_timeout tm);
int mln_socket_select(mln_t_socket n, fd_set *rfds, fd_set *wfds, fd_set *efds, 
        mln_p_timeout tm);

int mln_socket_connect(mln_p_socket ps, mln_SA *addr, socklen_t addr_len, mln_p_timeout tm); 
int mln_socket_create(mln_p_socket ps, int domain, int type, int protocol);
int mln_socket_bind(mln_p_socket ps, mln_SA *addr, socklen_t addr_len); 
int mln_socket_listen(mln_p_socket ps, int backlog);
int mln_socket_accept(mln_p_socket ps, mln_p_socket pa, mln_SA *addr, 
        socklen_t *addr_len, mln_p_timeout tm);

const char *mln_socket_hoststrerror(int err);
const char *mln_socket_gaistrerror(int err);
const char *mln_socket_strerror(int err);

/* these are perfect to use with the io abstraction module 
   and the buffered input module */
int mln_socket_send(mln_p_socket ps, const char *data, size_t count, 
        size_t *sent, mln_p_timeout tm);
int mln_socket_recv(mln_p_socket ps, char *data, size_t count, size_t *got, mln_p_timeout tm);
int mln_socket_write(mln_p_socket ps, const char *data, size_t count, 
        size_t *sent, mln_p_timeout tm);
int mln_socket_read(mln_p_socket ps, char *data, size_t count, size_t *got, mln_p_timeout tm);
const char *mln_socket_ioerror(mln_p_socket ps, int err);

int mln_socket_gethostbyaddr(const char *addr, socklen_t len, struct hostent **hp);
int mln_socket_gethostbyname(const char *addr, struct hostent **hp);

#endif /* SOCKET_H */
