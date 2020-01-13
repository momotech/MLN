/*=========================================================================*\
* TCP object
* LuaSocket toolkit
\*=========================================================================*/
#include <string.h>
#include <pthread.h>
#include <sys/poll.h>

#include "mln_lua.h"
#include "mln_lauxlib.h"

#include "mln_auxiliar.h"
#include "mln_socket.h"
#include "mln_inet.h"
#include "mln_options.h"
#include "mln_tcp.h"
#include "mln_isolate.h"

/*=========================================================================*\
* Internal function prototypes
\*=========================================================================*/
static int global_create(lua_State *L);
static int global_create6(lua_State *L);
static int global_connect(lua_State *L);
static int meth_async_poll(lua_State *L);
static int meth_connect(lua_State *L);
static int meth_listen(lua_State *L);
static int meth_getfamily(lua_State *L);
static int meth_bind(lua_State *L);
static int meth_send(lua_State *L);
static int meth_getstats(lua_State *L);
static int meth_setstats(lua_State *L);
static int meth_getsockname(lua_State *L);
static int meth_getpeername(lua_State *L);
static int meth_shutdown(lua_State *L);
static int meth_receive(lua_State *L);
static int meth_accept(lua_State *L);
static int meth_close(lua_State *L);
static int meth_getoption(lua_State *L);
static int meth_setoption(lua_State *L);
static int meth_settimeout(lua_State *L);
static int meth_getfd(lua_State *L);
static int meth_setfd(lua_State *L);
static int meth_dirty(lua_State *L);

/* tcp object methods */
static luaL_Reg tcp_methods[] = {
    {"__gc",        meth_close},
    {"__tostring",  mln_auxiliar_tostring},
    {"accept",      meth_accept},
    {"bind",        meth_bind},
    {"close",       meth_close},
    {"connect",     meth_connect},
    {"asyncpoll",   meth_async_poll},
    {"dirty",       meth_dirty},
    {"getfamily",   meth_getfamily},
    {"getfd",       meth_getfd},
    {"getoption",   meth_getoption},
    {"getpeername", meth_getpeername},
    {"getsockname", meth_getsockname},
    {"getstats",    meth_getstats},
    {"setstats",    meth_setstats},
    {"listen",      meth_listen},
    {"receive",     meth_receive},
    {"send",        meth_send},
    {"setfd",       meth_setfd},
    {"setoption",   meth_setoption},
    {"setpeername", meth_connect},
    {"setsockname", meth_bind},
    {"settimeout",  meth_settimeout},
    {"shutdown",    meth_shutdown},
    {NULL,          NULL}
};

/* socket option handlers */
static mln_t_opt optget[] = {
    {"keepalive",   mln_opt_get_keepalive},
    {"reuseaddr",   mln_opt_get_reuseaddr},
    {"tcp-nodelay", mln_opt_get_tcp_nodelay},
    {"linger",      mln_opt_get_linger},
    {"error",       mln_opt_get_error},
    {NULL,          NULL}
};

static mln_t_opt optset[] = {
    {"keepalive",   mln_opt_set_keepalive},
    {"reuseaddr",   mln_opt_set_reuseaddr},
    {"tcp-nodelay", mln_opt_set_tcp_nodelay},
    {"ipv6-v6only", mln_opt_set_ip6_v6only},
    {"linger",      mln_opt_set_linger},
    {NULL,          NULL}
};

/* functions in library namespace */
static luaL_Reg func[] = {
    {"tcp", global_create},
    {"tcp6", global_create6},
    {"connect", global_connect},
    {NULL, NULL}
};

/*-------------------------------------------------------------------------*\
* Initializes module
\*-------------------------------------------------------------------------*/
int mln_tcp_open(lua_State *L)
{
    /* create classes */
    mln_auxiliar_newclass(L, "tcp{master}", tcp_methods);
    mln_auxiliar_newclass(L, "tcp{client}", tcp_methods);
    mln_auxiliar_newclass(L, "tcp{server}", tcp_methods);
    /* create class groups */
    mln_auxiliar_add2group(L, "tcp{master}", "tcp{any}");
    mln_auxiliar_add2group(L, "tcp{client}", "tcp{any}");
    mln_auxiliar_add2group(L, "tcp{server}", "tcp{any}");
    /* define library functions */
#if LUA_VERSION_NUM > 501 && !defined(LUA_COMPAT_MODULE)
    luaL_setfuncs(L, func, 0);
#else
    luaL_openlib(L, NULL, func, 0);
#endif
    return 0;
}

/*=========================================================================*\
* Lua methods
\*=========================================================================*/
/*-------------------------------------------------------------------------*\
* Just call buffered IO methods
\*-------------------------------------------------------------------------*/
static int meth_send(lua_State *L) {
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{client}", 1);
    return mln_buffer_meth_send(L, &tcp->buf);
}

static int meth_receive(lua_State *L) {
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{client}", 1);
    return mln_buffer_meth_receive(L, &tcp->buf);
}

static int meth_getstats(lua_State *L) {
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{client}", 1);
    return mln_buffer_meth_getstats(L, &tcp->buf);
}

static int meth_setstats(lua_State *L) {
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{client}", 1);
    return mln_buffer_meth_setstats(L, &tcp->buf);
}

/*-------------------------------------------------------------------------*\
* Just call option handler
\*-------------------------------------------------------------------------*/
static int meth_getoption(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    return mln_opt_meth_getoption(L, optget, &tcp->sock);
}

static int meth_setoption(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    return mln_opt_meth_setoption(L, optset, &tcp->sock);
}

/*-------------------------------------------------------------------------*\
* Select support methods
\*-------------------------------------------------------------------------*/
static int meth_getfd(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    lua_pushnumber(L, (int) tcp->sock);
    return 1;
}

/* this is very dangerous, but can be handy for those that are brave enough */
static int meth_setfd(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    tcp->sock = (mln_t_socket) luaL_checknumber(L, 2);
    return 0;
}

static int meth_dirty(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    lua_pushboolean(L, !mln_buffer_isempty(&tcp->buf));
    return 1;
}

/*-------------------------------------------------------------------------*\
* Waits for and returns a client object attempting connection to the
* server object
\*-------------------------------------------------------------------------*/
static int meth_accept(lua_State *L)
{
    mln_p_tcp server = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{server}", 1);
    mln_p_timeout tm = mln_timeout_markstart(&server->tm);
    mln_t_socket sock;
    const char *err = mln_inet_tryaccept(&server->sock, server->family, &sock, tm);
    /* if successful, push client socket */
    if (err == NULL) {
        mln_p_tcp clnt = (mln_p_tcp) lua_newuserdata(L, sizeof(mln_t_tcp));
        mln_auxiliar_setclass(L, "tcp{client}", -1);
        /* initialize structure fields */
        memset(clnt, 0, sizeof(mln_t_tcp));
        mln_socket_setnonblocking(&sock);
        clnt->sock = sock;
        mln_io_init(&clnt->io, (mln_p_send) mln_socket_send, (mlnp_recv) mln_socket_recv,
                (mln_p_error) mln_socket_ioerror, &clnt->sock);
        mln_timeout_init(&clnt->tm, -1, -1);
        mln_buffer_init(&clnt->buf, &clnt->io, &clnt->tm);
        clnt->family = server->family;
        return 1;
    } else {
        lua_pushnil(L);
        lua_pushstring(L, err);
        return 2;
    }
}

/*-------------------------------------------------------------------------*\
* Binds an object to an address
\*-------------------------------------------------------------------------*/
static int meth_bind(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{master}", 1);
    const char *address =  luaL_checkstring(L, 2);
    const char *port = luaL_checkstring(L, 3);
    const char *err;
    struct addrinfo bindhints;
    memset(&bindhints, 0, sizeof(bindhints));
    bindhints.ai_socktype = SOCK_STREAM;
    bindhints.ai_family = tcp->family;
    bindhints.ai_flags = AI_PASSIVE;
    err = mln_inet_trybind(&tcp->sock, address, port, &bindhints);
    if (err) {
        lua_pushnil(L);
        lua_pushstring(L, err);
        return 2;
    }
    lua_pushnumber(L, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Turns a master tcp object into a client object.
\*-------------------------------------------------------------------------*/
static int meth_connect(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    const char *address =  luaL_checkstring(L, 2);
    const char *port = luaL_checkstring(L, 3);
    struct addrinfo connecthints;
    const char *err;
    memset(&connecthints, 0, sizeof(connecthints));
    connecthints.ai_socktype = SOCK_STREAM;
    /* make sure we try to connect only to the same family */
    connecthints.ai_family = tcp->family;
    mln_timeout_markstart(&tcp->tm);
    err = mln_inet_tryconnect(&tcp->sock, &tcp->family, address, port, 
        &tcp->tm, &connecthints);
    /* have to set the class even if it failed due to non-blocking connects */
    mln_auxiliar_setclass(L, "tcp{client}", 1);
    if (err) {
        lua_pushnil(L);
        lua_pushstring(L, err);
        return 2;
    }
    lua_pushnumber(L, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Closes socket used by object
\*-------------------------------------------------------------------------*/
static int meth_close(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    mln_socket_destroy(&tcp->sock);
    lua_pushnumber(L, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Returns family as string
\*-------------------------------------------------------------------------*/
static int meth_getfamily(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    if (tcp->family == PF_INET6) {
        lua_pushliteral(L, "inet6");
        return 1;
    } else {
        lua_pushliteral(L, "inet4");
        return 1;
    }
}

/*-------------------------------------------------------------------------*\
* Puts the sockt in listen mode
\*-------------------------------------------------------------------------*/
static int meth_listen(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{master}", 1);
    int backlog = (int) luaL_optnumber(L, 2, 32);
    int err = mln_socket_listen(&tcp->sock, backlog);
    if (err != IO_DONE) {
        lua_pushnil(L);
        lua_pushstring(L, mln_socket_strerror(err));
        return 2;
    }
    /* turn master object into a server object */
    mln_auxiliar_setclass(L, "tcp{server}", 1);
    lua_pushnumber(L, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Shuts the connection down partially
\*-------------------------------------------------------------------------*/
static int meth_shutdown(lua_State *L)
{
    /* SHUT_RD,  SHUT_WR,  SHUT_RDWR  have  the value 0, 1, 2, so we can use method index directly */
    static const char* methods[] = { "receive", "send", "both", NULL };
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkclass(L, "tcp{client}", 1);
    int how = luaL_checkoption(L, 2, "both", methods);
    mln_socket_shutdown(&tcp->sock, how);
    lua_pushnumber(L, 1);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Just call inet methods
\*-------------------------------------------------------------------------*/
static int meth_getpeername(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    return mln_inet_meth_getpeername(L, &tcp->sock, tcp->family);
}

static int meth_getsockname(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    return mln_inet_meth_getsockname(L, &tcp->sock, tcp->family);
}

/*-------------------------------------------------------------------------*\
* Just call tm methods
\*-------------------------------------------------------------------------*/
static int meth_settimeout(lua_State *L)
{
    mln_p_tcp tcp = (mln_p_tcp) mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    return mln_timeout_meth_settimeout(L, &tcp->tm);
}

/*=========================================================================*\
* Library functions
\*=========================================================================*/
/*-------------------------------------------------------------------------*\
* Creates a master tcp object
\*-------------------------------------------------------------------------*/
static int tcp_create(lua_State *L, int family) {
    mln_t_socket sock;
    const char *err = mln_inet_trycreate(&sock, family, SOCK_STREAM);
    /* try to allocate a system socket */
    if (!err) {
        /* allocate tcp object */
        mln_p_tcp tcp = (mln_p_tcp) lua_newuserdata(L, sizeof(mln_t_tcp));
        memset(tcp, 0, sizeof(mln_t_tcp));
        /* set its type as master object */
        mln_auxiliar_setclass(L, "tcp{master}", -1);
        /* initialize remaining structure fields */
        mln_socket_setnonblocking(&sock);
        if (family == PF_INET6) {
            int yes = 1;
            setsockopt(sock, IPPROTO_IPV6, IPV6_V6ONLY,
                (void *)&yes, sizeof(yes));
        }
        tcp->sock = sock;
        mln_io_init(&tcp->io, (mln_p_send) mln_socket_send, (mlnp_recv) mln_socket_recv,
                (mln_p_error) mln_socket_ioerror, &tcp->sock);
        mln_timeout_init(&tcp->tm, -1, -1);
        mln_buffer_init(&tcp->buf, &tcp->io, &tcp->tm);
        tcp->family = family;
        return 1;
    } else {
        lua_pushnil(L);
        lua_pushstring(L, err);
        return 2;
    }
}

static int global_create(lua_State *L) {
    return tcp_create(L, AF_INET);
}

static int global_create6(lua_State *L) {
    return tcp_create(L, AF_INET6);
}

#if 0
static const char *tryconnect6(const char *remoteaddr, const char *remoteserv,
    struct addrinfo *connecthints, p_tcp tcp) {
    struct addrinfo *iterator = NULL, *resolved = NULL;
    const char *err = NULL;
    /* try resolving */
    err = socket_gaistrerror(getaddrinfo(remoteaddr, remoteserv,
                connecthints, &resolved));
    if (err != NULL) {
        if (resolved) freeaddrinfo(resolved);
        return err;
    }
    /* iterate over all returned addresses trying to connect */
    for (iterator = resolved; iterator; iterator = iterator->ai_next) {
        p_timeout tm = timeout_markstart(&tcp->tm);
        /* create new socket if necessary. if there was no
         * bind, we need to create one for every new family
         * that shows up while iterating. if there was a
         * bind, all families will be the same and we will
         * not enter this branch. */
        if (tcp->family != iterator->ai_family) {
            socket_destroy(&tcp->sock);
            err = socket_strerror(socket_create(&tcp->sock,
                iterator->ai_family, iterator->ai_socktype,
                iterator->ai_protocol));
            if (err != NULL) {
                freeaddrinfo(resolved);
                return err;
            }
            tcp->family = iterator->ai_family;
            /* all sockets initially non-blocking */
            socket_setnonblocking(&tcp->sock);
        }
        /* finally try connecting to remote address */
        err = socket_strerror(socket_connect(&tcp->sock,
            (SA *) iterator->ai_addr,
            (socklen_t) iterator->ai_addrlen, tm));
        /* if success, break out of loop */
        if (err == NULL) break;
    }

    freeaddrinfo(resolved);
    /* here, if err is set, we failed */
    return err;
}
#endif

static int global_connect(lua_State *L) {
    const char *remoteaddr = luaL_checkstring(L, 1);
    const char *remoteserv = luaL_checkstring(L, 2);
    const char *localaddr  = luaL_optstring(L, 3, NULL);
    const char *localserv  = luaL_optstring(L, 4, "0");
    int family = mln_inet_optfamily(L, 5, "unspec");
    mln_p_tcp tcp = (mln_p_tcp) lua_newuserdata(L, sizeof(mln_t_tcp));
    struct addrinfo bindhints, connecthints;
    const char *err = NULL;
    /* initialize tcp structure */
    memset(tcp, 0, sizeof(mln_t_tcp));
    mln_io_init(&tcp->io, (mln_p_send) mln_socket_send, (mlnp_recv) mln_socket_recv,
            (mln_p_error) mln_socket_ioerror, &tcp->sock);
    mln_timeout_init(&tcp->tm, -1, -1);
    mln_buffer_init(&tcp->buf, &tcp->io, &tcp->tm);
    tcp->sock = SOCKET_INVALID;
    tcp->family = PF_UNSPEC;
    /* allow user to pick local address and port */
    memset(&bindhints, 0, sizeof(bindhints));
    bindhints.ai_socktype = SOCK_STREAM;
    bindhints.ai_family = family;
    bindhints.ai_flags = AI_PASSIVE;
    if (localaddr) {
        err = mln_inet_trybind(&tcp->sock, localaddr, localserv, &bindhints);
        if (err) {
            lua_pushnil(L);
            lua_pushstring(L, err);
            return 2;
        }
        tcp->family = bindhints.ai_family;
    }
    /* try to connect to remote address and port */
    memset(&connecthints, 0, sizeof(connecthints));
    connecthints.ai_socktype = SOCK_STREAM;
    /* make sure we try to connect only to the same family */
    connecthints.ai_family = bindhints.ai_family;
    err = mln_inet_tryconnect(&tcp->sock, &tcp->family, remoteaddr, remoteserv,
         &tcp->tm, &connecthints);
    if (err) {
        mln_socket_destroy(&tcp->sock);
        lua_pushnil(L);
        lua_pushstring(L, err);
        return 2;
    }
    mln_auxiliar_setclass(L, "tcp{client}", -1);
    return 1;
}

#pragma mark - Poll socket in background thread
/*-------------------------------------------------------------------------*\
* Poll socket in background thread
\*-------------------------------------------------------------------------*/
typedef struct poll_thread_ctx {
    lua_State *L;
    mln_t_socket socket;
} poll_thread_ctx;

static lua_State* _current_main_state = NULL; // main thread state

static double _begin = 0;
static double mln_current_time(void) {
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000 + time.tv_usec / 1000.0);
}

static int handle_socket_command_error(lua_State *L) {
    if (lua_isstring(L, -1)) {
        const char *errmsg = lua_tostring(L, -1);
        printf("%s\n", errmsg);
    }
    return 0;
}

static void* mln_handle_socket_command_message(void *data) {
    if (!data) return NULL;
    double time = mln_current_time() - _begin; // ms (0.02ms ~ 100ms)
    const char *retvalue = NULL;
    lua_State *L = (lua_State *)data;
    if (_current_main_state != L) {
        return "dead";
    }
    if (time < 900) {
        lua_getglobal(L, "handle_socket_command_message");
        if (lua_isfunction(L, -1)) {
            lua_pushcfunction(L, handle_socket_command_error);
            lua_insert(L, -2);
            lua_pcall(L, 0, 1, -2); // receive socket data to handle breakpoints.
            retvalue = lua_tostring(L, -1);
            lua_pop(L, 1); // remove return value
        } else {
            retvalue = "dead";
            lua_pop(L, 1); // remove it if it is not function which we need.
        }
    }
    return (void *)retvalue;
}

static void* mln_poll_socket_func(void *ctx) {
    if (!ctx) return NULL;
    const char *tname = "com.mln.poll.socket.thread";
    pthread_setname_np(tname);
    poll_thread_ctx *context = (poll_thread_ctx *)ctx;
    lua_State *L = context->L;
    
    int ret;
    struct pollfd pfd;
    pfd.fd = context->socket;
    pfd.events = POLLIN;
    pfd.revents = 0;
    
    while (1) {
        int timeout = 5 * 1000; // ms
        ret = poll(&pfd, 1, timeout);
        if (ret == 0) continue; // timeout should continue and if error will break
        if (ret == -1 && errno == EINTR) continue;
        if (pfd.revents == (POLLHUP | POLLIN) && ret == 1 && errno == ETIMEDOUT) {
            break;
        }
        if (ret < 0 || pfd.revents == POLLNVAL) break;
        _begin = mln_current_time();
        const char *retvalue = (const char *)mln_thread_sync_to_main(L, mln_handle_socket_command_message);
        if (retvalue && strcmp(retvalue, "dead") == 0) {
            break;
        }
    }
    
    if (ret == 0) {
        printf("[%s] poll timeout and nothing happend, will quit current thread.\n", tname);
    } else if (ret < 0) {
        printf("[%s] poll error and will quit current thread. \n", tname);
    }
    
    free(ctx);
    return NULL;
}

static void setup_poll_socket_runloop(lua_State *L, mln_t_socket socket) {
    pthread_t threadId = 0;
    
    poll_thread_ctx *ctx = (poll_thread_ctx *)malloc(sizeof(poll_thread_ctx));
    ctx->L = L;
    ctx->socket = socket;
    int res = pthread_create(&threadId, NULL, mln_poll_socket_func, ctx);
    if (res == 0) { // success
        pthread_detach(threadId);
    } else {
        printf("setup_poll_socket_runloop error: %d", res);
    }
}

static int meth_async_poll(lua_State *L) {
    _current_main_state = L;
    mln_p_tcp tcp = (mln_p_tcp)mln_auxiliar_checkgroup(L, "tcp{any}", 1);
    setup_poll_socket_runloop(L, tcp->sock);
    return 0;
}
