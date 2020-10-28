/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  List.h
//  List
//
//  Created by XiongFangyu on 2019/6/5.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#ifndef _List_h
#define _List_h

#include <stdio.h>

/**
 * 申请内存和释放内存的函数
 */
typedef void* (*list_alloc) (void *, size_t, size_t);

/**
 * 判断value是否相等
 */
typedef int (*list_eqauls) (const void *, const void *);
/**
 * 遍历函数，返回0表示继续遍历，1表示遍历完成
 * @see list_traverse
 * @param ud 自定义数据
 */
typedef int (*list_look_fun) (const void *value, void *ud);

struct list_;

typedef struct list_ List;
/**
 * 初始化列表
 * @param f 内存分配函数，可为空
 * @param init 初始化大小
 * @param autoRelist 0|1 是否自动去除列表中空内容
 * @return 内存分配出错，返回空
 */
List * list_new(list_alloc f, int init, int autoRelist);

/**
 * 是否有error
 * @return 0: 无错误
 */
int list_ero(List *);
/**
 * 设置判断函数
 */
void list_set_equals(List *, list_eqauls);
/**
 * 设置扩容参数，默认0。75
 */
void list_set_load_factor(List *, float);
/**
 * 销毁列表
 */
void list_free(List *);
/**
 * 向列表中增加数据
 */
void list_add(List *, void *);
/**
 * 重组列表，清空空数据
 */
void list_relist(List *);
/**
 * 获取相应位置下的数据
 */
void * list_get(List *, size_t);
/**
 * 遍历list
 * @param list 目标list
 * @param fun  遍历每个非空数据，并调用此函数
 * @param ud   自定义数据
 */
void list_traverse(List *list, list_look_fun fun, void *ud);
/**
 * 获取数据相应位置
 * @return 若有错误，返回list_size + 2; 未查找到数据，返回list_size + 1
 */
size_t list_index(List *, void *);
/**
 * 移除某个位置数据
 * @return 若原有位置有数据，则返回原有数据
 */
void * list_remove(List *, size_t);
/**
 * 移除某个数据
 */
void list_remove_obj(List *, void *);
/**
 * 当前列表中数据个数
 */
size_t list_size(List *);

#endif /* List_h */