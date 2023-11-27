/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/06/06.
//

#if defined(MEM_INFO)
#ifndef WSTACK
#define WSTACK
#endif
#endif

#if defined(WSTACK)
#include "stack.h"
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

typedef struct _stack {
    uintptr_t * pcs;
    char ** method_name;
    int size;
    int max;
    int ignore;
    int _gmn;
} _stack_info;

static char * new_str(const char * src) {
    char * r = (char *) malloc(sizeof(char *) * (strlen(src) + 1));
    return strcpy(r, src);
}

static _Unwind_Reason_Code unwind_backtrace_callback(struct _Unwind_Context* context, void* arg) {
    uintptr_t pc = _Unwind_GetIP(context);
    _stack_info * t = (_stack_info *) arg;
    if (t->size ++ < t->ignore) return _URC_NO_REASON;
    int i = t->size - 1 - t->ignore;
    if (i >= t->max) return _URC_END_OF_STACK;
    Dl_info info;
    if (pc && dladdr((void *)pc, &info)) {
        t->pcs[i] = (uintptr_t)info.dli_saddr - (uintptr_t)info.dli_fbase;
        if (t->_gmn && info.dli_sname) t->method_name[i] = new_str(info.dli_sname);
        else t->method_name[i] = NULL;
    } else {
        t->pcs[i] = 0;
        t->method_name[i] = NULL;
    }
    return _URC_NO_REASON;
}

int get_call_stack(stack_symbol * out, int ignore, int get_method_name) {
    _stack_info si;
    si.pcs = out->pc;
    si.method_name = out->method_name;
    si.size = 0;
    si.max = out->max;
    si.ignore = ignore;
    si._gmn = get_method_name;
    _Unwind_Backtrace(unwind_backtrace_callback, &si);
    return 1;//ret == _URC_END_OF_STACK;
}
#endif  //WSTACK