#ifndef IO_H
#define IO_H
/*=========================================================================*\
* Input/Output abstraction
* LuaSocket toolkit
*
* This module defines the interface that LuaSocket expects from the
* transport layer for streamed input/output. The idea is that if any
* transport implements this interface, then the buffer.c functions
* automatically work on it.
*
* The module socket.h implements this interface, and thus the module tcp.h
* is very simple.
\*=========================================================================*/
#include <stdio.h>
#include "mln_lua.h"

#include "mln_timeout.h"

/* IO error codes */
enum {
    IO_DONE = 0,        /* operation completed successfully */
    IO_TIMEOUT = -1,    /* operation timed out */
    IO_CLOSED = -2,     /* the connection has been closed */
	IO_UNKNOWN = -3     
};

/* interface to error message function */
typedef const char *(*mln_p_error) (
    void *ctx,          /* context needed by send */
    int err             /* error code */
);

/* interface to send function */
typedef int (*mln_p_send) (
    void *ctx,          /* context needed by send */
    const char *data,   /* pointer to buffer with data to send */
    size_t count,       /* number of bytes to send from buffer */
    size_t *sent,       /* number of bytes sent uppon return */
    mln_p_timeout tm        /* timeout control */
);

/* interface to recv function */
typedef int (*mlnp_recv) (
    void *ctx,          /* context needed by recv */
    char *data,         /* pointer to buffer where data will be writen */
    size_t count,       /* number of bytes to receive into buffer */
    size_t *got,        /* number of bytes received uppon return */
    mln_p_timeout tm        /* timeout control */
);

/* IO driver definition */
typedef struct mln_t_io_ {
    void *ctx;          /* context needed by send/recv */
    mln_p_send send;        /* send function pointer */
    mlnp_recv recv;        /* receive function pointer */
    mln_p_error error;      /* strerror function */
} mln_t_io;
typedef mln_t_io *mln_p_io;

void mln_io_init(mln_p_io io, mln_p_send send, mlnp_recv recv, mln_p_error error, void *ctx);
const char *mln_io_strerror(int err);

#endif /* IO_H */

