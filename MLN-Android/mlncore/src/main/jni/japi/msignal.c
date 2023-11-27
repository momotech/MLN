//
// Created by XiongFangyu on 2021/1/13.
//

#include "msignal.h"
#ifdef WSTACK
#include "stack.h"
#include "mlog.h"
#include <signal.h>
#include <string.h>
#include <stdlib.h>

#define _LOG_PRE "---------------------"

static void _log_stack() {
    const int SIZE = 10;
    uintptr_t pcs[SIZE] = {0};
    char *mns[SIZE] = {0};
    stack_symbol _ss = {
            pcs, mns, SIZE
    };
    if (!get_call_stack(&_ss, 4, 1)) {
        LOGE(_LOG_PRE "get stack failed!");
        exit(1);
    }
    LOGE(_LOG_PRE "stack trace:");
    for (int i = 0; i < SIZE; ++i) {
        uintptr_t pc = pcs[i];
        if (!pc) continue;
        char *mn = mns[i];
        if (!mn) mn = "unknown";
        LOGE(_LOG_PRE "%s:%x", mn, pc);
    }
    exit(1);
}

static void _when_abort(int a) {
    LOGE(_LOG_PRE "abort!");
    _log_stack();
}

static void _when_egv(int a) {
    LOGE(_LOG_PRE "SIGSEGV!");
    _log_stack();
}
#endif

void start_catch_signal() {
#ifdef WSTACK
    signal(SIGABRT, _when_abort);
    signal(SIGSEGV, _when_egv);
#endif
}