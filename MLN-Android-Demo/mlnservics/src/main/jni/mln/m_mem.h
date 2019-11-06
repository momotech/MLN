//
// Created by Xiong.Fangyu 2019/06/03.
//

#ifndef __M_MEM_H
#define __M_MEM_H
#include <stdlib.h>

/**
 * ns > 0 malloc或realloc内存
 * ns == 0 free src
 */
void * m_malloc(void* src, size_t os, size_t ns);
#if defined(J_API_INFO)
/**
 * 通过m_malloc使用的内存
 */
size_t m_mem_use();
/**
 * 删除标记
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