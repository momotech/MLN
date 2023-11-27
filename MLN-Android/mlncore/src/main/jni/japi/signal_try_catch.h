//
// Created by XiongFangyu on 8/20/21.
//

#ifndef MMLUA4ANDROID_SIGNAL_TRY_CATCH_H
#define MMLUA4ANDROID_SIGNAL_TRY_CATCH_H
#include <setjmp.h>
#include <signal.h>
#include "signal_try_catch.h"

jmp_buf *_g_jmp_buf;

#define _try(sig)   int __sig = sig;                \
                    sighandler_t _old_s_h = signal((__sig), sig_handler); \
                    jmp_buf _buf;                   \
                    int _jr = setjmp(_buf);         \
                    if (!_jr) _g_jmp_buf = &_buf;   \
                    if (!_jr)

#define _catch(e)   signal(__sig, _old_s_h);        \
                    int e = _jr;                    \
                    if (!e) _g_jmp_buf = NULL;      \
                    else

void sig_handler(int signal);
#endif //MMLUA4ANDROID_SIGNAL_TRY_CATCH_H
