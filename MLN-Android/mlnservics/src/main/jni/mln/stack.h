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

#ifndef __STACK_H
#define __STACK_H

#if defined(MEM_INFO)
#include <unwind.h>
#define MAX_STACK_LENGTH 5

typedef struct stack_symbol {
    uintptr_t pc[MAX_STACK_LENGTH];         //  调用栈相对位置
    char * method_name[MAX_STACK_LENGTH];   //  对应调用栈函数名称 nullable
} stack_symbol;

/**
 * 获取调用栈
 * out: 存储调用栈信息
 * ignore: 忽略调用层数
 * get_method_name: 是否获取函数名称，若为1，则out->method_name[n]不为空，且使用malloc申请内存；反之为空
 * return 1: 获取成功; 0: 获取失败
 */
int get_call_stack(stack_symbol * out, int ignore, int get_method_name);
#endif  //MEM_INFO

#endif