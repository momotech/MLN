//
//  mempool.c
//  CMemoryPool
//
//  Created by XiongFangyu on 2021/1/19.
//  Copyright © 2021 XiongFangyu. All rights reserved.
//

#include <string.h>
#include "mempool.h"

/// pool内存池个数
#define pool_arr_size(p) ((p)->arr_size)
/// 给定chunk列的长度
#define pool_chunk_size(p,i) ((p)->current_size_arr[(i)])
/// 当前chunk列长度
#define pool_current_size(p) pool_chunk_size((p), (p)->current_index)
/// 给定chunk列使用长度
#define pool_chunk_using(p, i) ((p)->using_count_arr[(i)])
/// 当前chunk列使用长度
#define pool_crrent_using(p) pool_chunk_using(p, (p)->current_index)
/// 给定chunk列剩余长度
#define pool_chunk_remain(p,i) (pool_chunk_size(p,i) - pool_chunk_using(p, i))
/// 当前chunk列剩余长度
#define pool_current_remain(p) pool_chunk_remain(p, (p)->current_index)
/// 给定chunk列头
#define pool_chunk_start(p, i) ((mem_chunk *) (p)->start_arr[(i)])
/// 当前chunk列头
#define pool_current_chunk_start(p) pool_chunk_start(p, (p)->current_index)
/// 给定chunk列尾
#define pool_chunk_end(p, i) pool_chunk_start(p, i) + pool_chunk_size(p, i)
/// 当前chunk列尾
#define pool_current_chunk_end(p) pool_chunk_end(p, (p)->current_index)
/// 给给定chunk增加使用次数
#define pool_add_use_count(p, i, s) pool_chunk_using(p,i) += (s)
/// 给当前chunk增加使用次数
#define pool_add_current_use_count(p, s) pool_add_use_count(p, (p)->current_index, s)
/// chunk flag占用字节
#define pool_chunk_flag(p) (p)->chunk_flag_size
/// 当前是否是内存池最后一列
#define pool_current_is_last(p) ((p)->current_index == (p)->arr_size - 1)
#define pool_current(p) (mem_chunk *) ((p)->current)

#define chunk_count(c) ((c)->flag[0])
#define chunk_pre_count(c) ((c)->flag[1])
#define chunk_using(c) ((c)->flag[2])
#define ptr_to_chunk(m, p) (mem_chunk *) (((int8_t *) (p)) - pool_chunk_flag(m))
#define next_chunk(c) ((mem_chunk *) ((c) + chunk_count(c)))
#define pre_chunk(c) ((mem_chunk *) ((c) - chunk_pre_count(c)))
#define set_pre_count(n, c) chunk_pre_count(n) = chunk_count(c)
#define add_count(c, s) chunk_count(c) += (s)

static inline mem_size pool_all_using_size(mem_pool *);
static inline mem_size find_index(mem_pool *mp, void *ptr);
static inline mem_size need_chunk_count(mem_pool *mp, mp_size size);
static inline void combine_next(mem_pool *mp, mem_chunk *chunk, mem_chunk *next, mem_chunk *end);
static inline mem_size alloc_block(mem_pool *mp);

mem_pool *mp_new_pool(mp_size init, mp_size max) {
    if (init > max || init > MP_MAX_SIZE)
        return NULL;
    if (init % MP_CHUNK_SIZE != 0) {
        init = init / MP_CHUNK_SIZE + 1;
    } else {
        init = init / MP_CHUNK_SIZE;
    }
    if (max >= MP_MAX_SIZE) {
        max = (mem_size) (((mem_size)1) << MP_CHUNK_BITS) - 1;
    } else if (max % MP_CHUNK_SIZE != 0) {
        max = max / MP_CHUNK_SIZE + 1;
    } else {
        max = max / MP_CHUNK_SIZE;
    }

    mem_pool *mp = (mem_pool *) malloc(sizeof(mem_pool));
    if (!mp) {
        return NULL;
    }
    memset(mp, 0, sizeof(mem_pool));
    mp->init = init;
    mp->max = max;
    mp->start_arr = (void **) malloc(sizeof(void *));
    if (!mp->start_arr) {
        mp_free_pool(mp);
        return NULL;
    }
    pool_arr_size(mp) = 1;
    memset(mp->start_arr, 0, sizeof(void *));
    mp->current_size_arr = (mem_size *) malloc(sizeof(mem_size));
    if (!mp->current_size_arr) {
        mp_free_pool(mp);
        return NULL;
    }
    pool_chunk_size(mp, 0) = init;
    mp->using_count_arr = (mem_size *) malloc(sizeof(mem_size));
    if (!mp->using_count_arr) {
        mp_free_pool(mp);
        return NULL;
    }
    pool_chunk_using(mp, 0) = 0;
    void *p = malloc(init * MP_CHUNK_SIZE);
    if (!p) {
        mp_free_pool(mp);
        return NULL;
    }
    mp->start_arr[0] = p;
    mp->current = p;

    mem_chunk *mc = (mem_chunk *)p;
    chunk_count(mc) = init;
    chunk_pre_count(mc) = 0;
    chunk_using(mc) = 0;

    mp->chunk_flag_size = mc->_using - (int8_t *) mc;
    mp->use_mem = init * MP_CHUNK_SIZE
            + 2 * sizeof(mem_size)
            + sizeof(void *)
            + sizeof(mem_pool);
    return mp;
}

void mp_clear_pool(mem_pool *mp) {
    mem_size count = pool_arr_size(mp);
    for (mem_size i = 0; i < count; i ++) {
        mem_chunk *start = pool_chunk_start(mp, i);
        mem_size s = pool_chunk_size(mp, i);
        chunk_using(start) = 0;
        chunk_pre_count(start) = 0;
        chunk_count(start) = s;
        pool_chunk_using(mp, i) = 0;
        pool_chunk_size(mp, i) = s;
    }
    mp->current = mp->start_arr[0];
    mp->current_index = 0;
}

void mp_free_pool(mem_pool *mp) {
    mem_size count = pool_arr_size(mp);
    for (mem_size i = 0; i < count; i ++) {
        if (mp->start_arr[i])
            free(mp->start_arr[i]);
    }
    free(mp->start_arr);
    free(mp->current_size_arr);
    free(mp->using_count_arr);
    free(mp);
}

void *mp_alloc(mem_pool *mp, mp_size size) {
    mem_size chunk_count = need_chunk_count(mp, size);
    if (chunk_count > mp->init) {
        fprintf(stderr, "need %d chunk, by init is %d", chunk_count, mp->init);
        return NULL;
    }
    int has_alloc = 0;
    mem_chunk *start = pool_current_chunk_start(mp);
    mem_chunk *current = pool_current(mp);
    mem_chunk *end = pool_current_chunk_end(mp);
    mem_size can_use_count = pool_current_remain(mp);
    /// 可用空间不足
    while (can_use_count < chunk_count) {
        /// 当前index不是最后一个时，说明后续还有空block可使用
        int need_alloc = pool_current_is_last(mp);
        if (!need_alloc) {
            mp->current_index ++;
        } else {
            /// 申请内存
            if (alloc_block(mp) == 0) {
                return NULL;
            }
            has_alloc = 1;
        }
        start = pool_current_chunk_start(mp);
        current = pool_current(mp);
        end = pool_current_chunk_end(mp);
        can_use_count = pool_current_remain(mp);
        if (need_alloc) {
            break;
        }
    }
    if (current + chunk_count > end) {
        if (has_alloc)
            return NULL;
        /// 不能直接分配内存了, 查找现有剩余内存
        mem_size start_index = 0;
        mem_size start_size = pool_arr_size(mp);
        /// 遍历所有内存块
        while (start_index < start_size) {
            can_use_count = pool_chunk_remain(mp, start_index);
            if (can_use_count < chunk_count) {
                start_index ++;
                continue;
            }
            start = pool_chunk_start(mp, start_index);
            current = start;
            end = pool_chunk_end(mp, start_index);
            while (can_use_count >= chunk_count) {
                if (chunk_using(current)) {
                    current = next_chunk(current);
                    continue;
                }
                mem_size old_count = chunk_count(current);
                if (old_count < chunk_count) {
                    current = next_chunk(current);
                    can_use_count -= old_count;
                    continue;
                }
                /// 可用
                chunk_count(current) = chunk_count;
                /// 设置正在使用
                chunk_using(current) = 1;
                void *ret = (void *) current->_using;
                current = next_chunk(current);
                /// 大于说明下一个chunk没有被使用，设置下一个index和count
                if (old_count > chunk_count) {
                    chunk_using(current) = 0;
                    chunk_pre_count(current) = chunk_count;
                    chunk_count(current) = old_count - chunk_count;
                    mem_chunk *next = next_chunk(current);
                    if (next < end) {
                        if (!chunk_using(next))
                            combine_next(mp, current, next, end);
                        else
                            set_pre_count(next, current);
                    }
                }
                    /// 如果等于说明下一个chunk被使用了
                else if (current != end) {
                    chunk_pre_count(current) = chunk_count;
                }
                pool_chunk_using(mp, start_index) += chunk_count;
                return ret;
            }
            start_index++;
        }
        /// 当前内存块遍历完无可用，申请内存
        if (alloc_block(mp) == 0) {
            return NULL;
        }
        start = pool_current_chunk_start(mp);
        current = pool_current(mp);
        end = pool_current_chunk_end(mp);
        can_use_count = pool_current_remain(mp);
    }
    if (current + chunk_count <= end) {
        mem_size remain = chunk_count(current) - chunk_count;
        /// 设置使用chunk数量
        chunk_count(current) = chunk_count;
        /// 设置正在使用
        chunk_using(current) = 1;
        void *ret = (void *) current->_using;
        current = next_chunk(current);
        /// 若下一个chunk不是最后一个，设置下一个chunk的index
        if (remain > 0) {
            chunk_pre_count(current) = chunk_count;
            chunk_using(current) = 0;
            chunk_count(current) = remain;
        }
        pool_add_current_use_count(mp, chunk_count);
        mp->current = (void *) current;
        return ret;
    }
    return NULL;
}

void *mp_realloc(mem_pool *mp, void *ptr, mp_size nsize) {
    if (!ptr) {
        return mp_alloc(mp, nsize);
    }
    if (nsize <= 0) {
        mp_free(mp, ptr);
        return NULL;
    }
    mem_size index = find_index(mp, ptr);
    mem_chunk *chunk = ptr_to_chunk(mp, ptr);
    /// need_count 表示新大小需要的chunk个数
    mem_size need_count = need_chunk_count(mp, nsize);
    if (need_count == chunk_count(chunk)) {
        return ptr;
    }
    /// 说明缩小了，尽量free一些chunk
    if (need_count < chunk_count(chunk)) {
        mem_size remain = chunk_count(chunk) - need_count;
        chunk_count(chunk) = need_count;
        chunk = next_chunk(chunk);
        chunk_using(chunk) = 0;
        chunk_count(chunk) = remain;
        chunk_pre_count(chunk) = need_count;
        pool_chunk_using(mp, index) -= remain;
        /// 向后合并free块
        mem_chunk *next = next_chunk(chunk);
        mem_chunk *end = pool_chunk_end(mp, index);
        if (next < end) {
            if (!chunk_using(next))
                combine_next(mp, chunk, next, end);
            else
                set_pre_count(next, chunk);
        }
        return ptr;
    }
    mem_chunk *next = next_chunk(chunk);
    mem_chunk *end = pool_chunk_end(mp, index);
    if (next < end && !chunk_using(next)) {
        /// need_count 表示需要的更多的chunk个数
        need_count -= chunk_count(chunk);
        mem_size has_count = chunk_count(next);
        /// 表示后续chunk可以接在当前chunk后继续使用
        if (has_count >= need_count) {
            pool_chunk_using(mp, index) += need_count;
            add_count(chunk, need_count);
            int next_is_current = next == mp->current;
            next = next_chunk(chunk);
            if (has_count > need_count) {
                /// 说明next没有被使用
                chunk_using(next) = 0;
                chunk_count(next) = has_count - need_count;
                set_pre_count(next, chunk);
                chunk = next;
                next = next_chunk(next);
                if (next < end) {
                    if (!chunk_using(next))
                        combine_next(mp, chunk, next, end);
                    else
                        set_pre_count(next, chunk);
                }
            }
            /// 说明next被使用了
            else if (next < end) {
                set_pre_count(next, chunk);
            }
            if (next_is_current) {
                mp->current = next;
            }
            return ptr;
        }
    }
    void *new_ptr = mp_alloc(mp, nsize);
    if (!new_ptr)
        return NULL;
    mem_size osize = chunk_count(chunk) * MP_CHUNK_SIZE - pool_chunk_flag(mp);
    memcpy(new_ptr, ptr, osize < nsize ? osize : nsize);
    mp_free(mp, ptr);
    return new_ptr;
}

void mp_free(mem_pool *mp, void *ptr) {
    if (!ptr) return;
    mem_size index = find_index(mp, ptr);
    mem_chunk *chunk = ptr_to_chunk(mp, ptr);
    if (!chunk_using(chunk)) {
        fprintf(stderr, "pointer %p is freed before", ptr);
        abort();
    }
    chunk_using(chunk) = 0;
    pool_chunk_using(mp, index) -= chunk_count(chunk);

    mem_chunk *end = pool_chunk_end(mp, index);
    mem_chunk *next = next_chunk(chunk);
    /// 向前合并free块
    mem_chunk *pre = pre_chunk(chunk);
    if (pre != chunk && !chunk_using(pre)) {
        add_count(pre, chunk_count(chunk));
        chunk = pre;
        if (next < end) {
            set_pre_count(next, chunk);
        }
    }
    /// 向后合并free块
    if (next < end && !chunk_using(next))
        combine_next(mp, chunk, next, end);
}

static inline mem_size alloc_block(mem_pool *mp) {
    mem_size next = mp->max - pool_all_using_size(mp);
    if (next > mp->init)
        next = mp->init;
    void *block = malloc(next * MP_CHUNK_SIZE);
    if (!block) {
        fprintf(stderr, "malloc next block(%lu) failed", next * MP_CHUNK_SIZE);
        return 0;
    }
    mem_size arr_size = pool_arr_size(mp) + 1;
    void **start_arr = (void **) realloc(mp->start_arr, sizeof(void *) * arr_size);
    if (!start_arr) {
        fprintf(stderr, "malloc start_arr(%lu) failed", sizeof(void *) * arr_size);
        free(block);
        return 0;
    }
    pool_arr_size(mp) = arr_size;
    mp->start_arr = start_arr;
    mp->start_arr[arr_size - 1] = NULL;
    mem_size *current_size_arr = (mem_size *) realloc(mp->current_size_arr, sizeof(mem_size) * arr_size);
    if (!current_size_arr) {
        fprintf(stderr, "malloc current_size_arr(%lu) failed", sizeof(mem_size) * arr_size);
        free(block);
        return 0;
    }
    current_size_arr[arr_size - 1] = next;
    mp->current_size_arr = current_size_arr;
    mem_size *using_count_arr = (mem_size *) realloc(mp->using_count_arr, sizeof(mem_size) * arr_size);
    if (!using_count_arr) {
        fprintf(stderr, "malloc using_count_arr(%lu) failed", sizeof(mem_size) * arr_size);
        free(block);
        return 0;
    }
    using_count_arr[arr_size - 1] = 0;
    mp->using_count_arr = using_count_arr;
    mp->use_mem += next * MP_CHUNK_SIZE + sizeof(void *) + 2 * sizeof(mem_size);
    mp->start_arr[arr_size - 1] = block;
    mp->current_index ++;
    mp->current = block;
    mem_chunk *start = (mem_chunk *) block;
    chunk_using(start) = 0;
    chunk_pre_count(start) = 0;
    chunk_count(start) = next;
    return next;
}

static inline void combine_next(mem_pool *mp, mem_chunk *chunk, mem_chunk *next, mem_chunk *end) {
    if (next == mp->current) {
        add_count(chunk, chunk_count(next));
        mp->current = chunk;
        return;
    }
    add_count(chunk, chunk_count(next));
    next = next_chunk(next);
    if (next < end) {
        set_pre_count(next, chunk);
    }
}

static inline mem_size find_index(mem_pool *mp, void *ptr) {
    mem_size i = 0;
    mem_chunk *start;
    mem_chunk *end;
    while (i < pool_arr_size(mp)) {
        start = pool_chunk_start(mp, i);
        end = pool_chunk_end(mp, i);
        if (ptr > (void *) start && ptr < (void *) end) {
            break;
        }
        i ++;
    }
    if (i == pool_arr_size(mp)) {
        fprintf(stderr, "pointer(%p) is not in this pool(%p)!", ptr, mp);
        abort();
    }
    return i;
}

static inline mem_size need_chunk_count(mem_pool *mp, mp_size size) {
    mem_size chunk_count;
    if (size <= MP_CHUNK_USING_SIZE) {
        chunk_count = 1;
    } else {
        chunk_count = (size - MP_CHUNK_USING_SIZE) / MP_CHUNK_SIZE + 1;
        if (chunk_count * MP_CHUNK_SIZE - pool_chunk_flag(mp) < size)
        chunk_count++;
    }
    return chunk_count;
}

static inline mem_size pool_all_using_size(mem_pool *mp) {
    mem_size len = pool_arr_size(mp);
    if (len == 0)
        return 0;
    return mp->using_count_arr[len - 1] + mp->init * (len - 1);
}

//<editor-fold desc="test">
#ifdef MEM_POOL_TEST
void mp_test(mem_pool *mp) {
    mem_size i = 0;
    mem_chunk *start;
    mem_chunk *end;
    mem_chunk *next;
    mem_size using_count;
    /// 检查已使用
    for (; i < mp->current_index; i ++) {
        start = pool_chunk_start(mp, i);
        end = pool_chunk_end(mp, i);
        next = next_chunk(start);
        using_count = pool_chunk_using(mp, i);
        if (chunk_pre_count(start) != 0)
            abort();
        while (next < end) {
            if (!chunk_using(start) && !chunk_using(next))
                abort();
            if (chunk_count(start) != chunk_pre_count(next))
                abort();
            if (chunk_using(start))
                using_count -= chunk_count(start);
            start = next;
            next = next_chunk(start);
        }
        if (chunk_using(start))
            using_count -= chunk_count(start);
        if (using_count != 0)
            abort();
    }

    start = pool_chunk_start(mp, i);
    if (chunk_pre_count(start) != 0)
        abort();
    end = pool_chunk_end(mp, i);
    if (mp->current < (void *) start || mp->current > (void *) end)
        abort();
    using_count = pool_chunk_using(mp, i);
    if (using_count != 0) {
        next = next_chunk(start);
        while (next < pool_current(mp)) {
            if (!chunk_using(start) && !chunk_using(next))
                abort();
            if (chunk_count(start) != chunk_pre_count(next))
                abort();
            if (chunk_using(start))
                using_count -= chunk_count(start);
            start = next;
            next = next_chunk(start);
        }
        if (next != pool_current(mp))
            abort();
        if (chunk_using(start))
            using_count -= chunk_count(start);
    } else if (chunk_count(start) != pool_chunk_size(mp, i))
        abort();
    if (using_count != 0)
        abort();

    for (i = mp->current_index + 1; i < mp->arr_size ; i++) {
        start = pool_chunk_start(mp, i);
        if (chunk_using(start))
            abort();
        if (chunk_pre_count(start) != 0)
            abort();
        end = pool_chunk_end(mp, i);
        next = next_chunk(start);
        if (next != end)
            abort();
        using_count = pool_chunk_using(mp, i);
        if (using_count != 0)
            abort();
    }
}
#endif
//</editor-fold>