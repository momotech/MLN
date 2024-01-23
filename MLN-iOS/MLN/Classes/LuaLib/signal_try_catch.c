//
// Created by XiongFangyu on 8/20/21.
//

#include "signal_try_catch.h"

void sig_handler(int signal) {
    longjmp(_g_jmp_buf, signal);
}