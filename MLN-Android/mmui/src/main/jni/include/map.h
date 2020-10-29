/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by Xiong.fangyu 2019/05/21
 */
#ifndef MAP_H
#define MAP_H

#include <stdio.h>
/// map 申请内存错误
#define ER_MEM 1

/**
 * 计算key的hash值函数
 */
typedef unsigned int (*map_hash)(const void *);

/**
 * 判断key是否相等的函数
 */
typedef int (*map_equals)(const void *, const void *);

/**
 * 释放key或value的函数
 */
typedef void (*map_free_kv)(void *);

/**
 * 内部申请内存函数
 */
typedef void *(*map_alloc)(void *, size_t, size_t);

/**
 * 遍历函数，返回0表示继续遍历，1表示遍历完成
 * @see map_traverse
 * @param ud 自定义数据
 */
typedef int (*map_look_fun)(const void *key, const void *value, void *ud);

struct map_;

typedef struct map_ Map;
/**
 * @see map_entrys
 */
typedef struct m_entry {
    void *key;
    void *value;
} Map_Entry;
/**
 * 创建map结构
 * @param f    内存申请函数，可为空
 * @param init 初始化数量
 * @return map or NULL
 */
Map *map_new(map_alloc f, int init);
/**
 * 检查map是否有错误
 * @return 0: 无错误
 */
int map_ero(Map *);
/**
 * 设置扩容参数，默认0。75
 */
void map_set_load_factor(Map *, float);
/**
 * 设置计算key的hash函数
 * 默认值为计算string类型的函数
 */
void map_set_hash(Map *, map_hash);
/**
 * 设置判断key是否相同的函数
 * 默认值为判断string是否相同的函数
 */
void map_set_equals(Map *, map_equals);
/**
 * 设置key、value释放内存函数
 * 默认为使用free函数
 * 在调用map_free时会调用key、value的释放函数
 * 在调用map_remove时会，若传入的key和map中存储的key不同，则会调用释放函数释放存储key
 * 若不想被调用，则设置为空
 */
void map_set_free(Map *, map_free_kv, map_free_kv);
/**
 * 设置自定义数据
 */
void map_set_ud(Map *, void *);
/**
 * 获取用户自定义数据
 */
void *map_get_ud(Map *);
/**
 * 释放map对象
 */
void map_free(Map *);
/**
 * 存储key-value
 * @return 若map中已有key对应的value，则返回原始value，并存储新value
 */
void *map_put(Map *map, void *key, void *value);
/**
 * 获取map中对应key的value
 */
void *map_get(Map *map, const void *key);
/**
 * 移除map中对应key的value，并返回
 */
void *map_remove(Map *map, const void *key);
/**
 * 移除map钟所有数据
 */
void map_remove_all(Map *map);
/**
 * 获取map中key-value个数
 */
size_t map_size(Map *);
/**
 * 获取map中申请表的长度
 */
size_t map_table_size(Map *);
/**
 * 获取map中的key-value对，最多获取size个
 * @param map  目标map
 * @param out  存放key-value对
 * @param size 最大长度
 * @return 实际获取的长度
 */
size_t map_entrys(Map *map, Map_Entry *out, size_t size);
/**
 * 遍历map
 * @param map 目标map
 * @param traverse_function 遍历到每个key-value，并调用此函数
 * @param ud  自定义数据，并在调用traverse_function传入到第三个参数
 */
void map_traverse(Map *map, map_look_fun traverse_function, void *ud);

#if defined(J_API_INFO)
/**
 * 计算指针所占用内存
 * @see map_set_sizeof
 */
typedef size_t (*sizeof_kv)(void *);
/**
 * 计算map消耗内存
 * 最好配合map_set_sizeof使用
 */
size_t map_mem(Map *);
/**
 * 设置map中key和value占用内存函数
 * @see map_mem计算时使用
 */
void map_set_sizeof(Map *, sizeof_kv, sizeof_kv);

#endif

typedef char *(*map_value_to_string)(const void *value, int *needFree);
char *map_to_string(Map *, map_value_to_string, map_value_to_string);
#endif  //MAP_H