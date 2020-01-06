/*=========================================================================*\
* Input/Output abstraction
* LuaSocket toolkit
\*=========================================================================*/
#include "mln_io.h"

/*=========================================================================*\
* Exported functions
\*=========================================================================*/
/*-------------------------------------------------------------------------*\
* Initializes C structure
\*-------------------------------------------------------------------------*/
void mln_io_init(mln_p_io io, mln_p_send send, mlnp_recv recv, mln_p_error error, void *ctx) {
    io->send = send;
    io->recv = recv;
    io->error = error;
    io->ctx = ctx;
}

/*-------------------------------------------------------------------------*\
* I/O error strings
\*-------------------------------------------------------------------------*/
const char *mln_io_strerror(int err) {
    switch (err) {
        case IO_DONE: return NULL;
        case IO_CLOSED: return "closed";
        case IO_TIMEOUT: return "timeout";
        default: return "unknown error"; 
    }
}
