//
// Created by Xiong.Fangyu 2019/06/03.
//

#ifndef __M_MEM_H
#define __M_MEM_H

#include <stdlib.h>

/**
 * 申请和释放内存入口，使用此函数能在开启 J_API_INFO 和 MEM_INFO 时
 * 记录内存使用和调用栈信息，方便查找内存泄漏
 * ns > 0 malloc或realloc内存
 * ns == 0 free src
 */
void * m_malloc(void* src, size_t os, size_t ns);

///参考实现
void * m_malloc(void* src, size_t os, size_t ns) {
    if (ns == 0) {
        free(src);
        return NULL;
    }
    void * nb = realloc(src, ns);
    return nb;
}
#endif