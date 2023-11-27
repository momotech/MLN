//
//  mempool.h
//  CMemoryPool
//
//  Created by XiongFangyu on 2021/1/19.
//  Copyright © 2021 XiongFangyu. All rights reserved.
//

#ifndef mempool_h
#define mempool_h

#include <stdlib.h>
#include <stdio.h>

#ifdef J_API_INFO
#define MEM_POOL_TEST
#endif

typedef struct mem_pool mem_pool;
typedef struct mem_chunk mem_chunk;
/// chunk内给用户可用内存为16B
#define MP_CHUNK_USING_SIZE 16
/// index count使用
typedef uint16_t mem_size;

struct mem_chunk {
    /*
     * 保持内存对齐，共8B
     * chunk_count(c) 获取count
     * chunk_pre_count(c) 获取pre_count
     * chunk_using(c) 获取using
     */
    mem_size flag[4];
    /*用户使用内存*/
    int8_t _using[MP_CHUNK_USING_SIZE];
};

struct mem_pool {
    /*chunk flag占用字节*/
    mem_size chunk_flag_size;
    /*start初始mem_chunk个数*/
    mem_size init;
    /*start最大mem_chunk个数*/
    mem_size max;
    /*当前池内数组个数，using_count_arr current_size_arr start_arr*/
    mem_size arr_size;
    /*当前mem_chunk个数*/
    mem_size *current_size_arr;
    /*已使用个数*/
    mem_size *using_count_arr;
    /*当前空余内存在内存池的位置*/
    mem_size current_index;
    /*内存池所使用内存大小*/
    size_t use_mem;
    /*内存池开始位置*/
    void **start_arr;
    /*当前空余内存位置，当使用完后，不在赋值*/
    void *current;
};
/// 用16位来存储index，则最大可支持2^16 - 1个内存块
#define MP_CHUNK_BITS 16
/// 内存池由mem_chunk来分片，方便遍历查找，大小为2^4 (16) Byte
#define MP_CHUNK_SIZE sizeof(mem_chunk)
/// 最大可配置内存
#define MP_MAX_SIZE ((((mp_size)1) << MP_CHUNK_BITS ) * MP_CHUNK_SIZE)
/**
 * 内存大小单位，最大支持 0x1400000大小
 */
typedef uint32_t mp_size;
/**
 * 新建内存池，可分配初始内存大小和最大大小
 */
mem_pool *mp_new_pool(mp_size, mp_size);
/**
 * 申请内存，可能返回NULL，申请的内存大小，必须小于初始内存大小
 */
void *mp_alloc(mem_pool *, mp_size);
/**
 * 重新申请内存，可能返回NULL，申请的内存大小，必须小于初始内存大小
 */
void *mp_realloc(mem_pool *, void *, mp_size);
/**
 * 释放内存
 */
void mp_free(mem_pool *, void *);
/**
 * 清空内存
 */
void mp_clear_pool(mem_pool *);
/**
 * 释放内存池
 */
void mp_free_pool(mem_pool *);

#ifdef MEM_POOL_TEST
void mp_test(mem_pool *);
#endif // MEM_POOL_TEST
#endif /* mempool_h */
