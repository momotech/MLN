/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/06/03.
//

#ifndef __M_MEM_H
#define __M_MEM_H

#include <stdlib.h>
#include <jni.h>

jlong jni_allLvmMemUse(JNIEnv *env, jobject jobj);
void jni_logMemoryInfo(JNIEnv *env, jobject jobj);

/**
 * 申请和释放内存入口，使用此函数能在开启 J_API_INFO 和 MEM_INFO 时
 * 记录内存使用和调用栈信息，方便查找内存泄漏
 * ns > 0 malloc或realloc内存
 * ns == 0 free src
 */
void * m_malloc(void* src, size_t os, size_t ns);

#if defined(J_API_INFO)
/**
 * lua的内存申请释放入口
 * @param ud size_t
 */
void *m_alloc(void *ud, void *ptr, size_t osize, size_t nsize);
/**
 * 通过m_malloc使用的内存
 */
size_t m_mem_use();
/**
 * 删除内存标记
 */
void remove_by_pointer(void *p, size_t size);

#if defined(MEM_INFO)
#include "stack.h"

#define MAX_TRACE_SIZE MAX_STACK_LENGTH

size_t m_map_size();

typedef struct m_mem_info {
    stack_symbol stack_s;    /*申请内存函数*/
    size_t size;        /*占用字节*/
} m_mem_info;

/**
 * 获取未释放的内存信息
 */
m_mem_info ** m_get_mem_infos(size_t * out);

void m_log_mem_infos();
#endif  //MEM_INFO
#endif  //J_API_INFO
#endif  //__M_MEM_H