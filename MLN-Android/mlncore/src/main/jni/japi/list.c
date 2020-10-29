/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  List.c
//  List
//
//  Created by XiongFangyu on 2019/6/5.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#include "list.h"
#include <stdlib.h>
#include <string.h>

static int resize(List *);

static void * default_alloc(void * p, size_t os, size_t ns) {
    if (ns == 0) {
        free(p);
        return NULL;
    }
    return realloc(p, ns);
}

struct list_ {
    void ** arr;        /*数组*/
    size_t _len;        /*数组长度*/
    size_t _arr_used;   /*数组占位，若自动重新排列，则和size相同*/
    size_t size;        /*实际元素个数*/
    int _c;             /*错误代码*/
    float load_factor;  /*增长值*/
    char autoRelist;    /*自动从新排列(中间不会有空位)*/
    list_alloc f_alloc; /*申请和释放内存, nonnull*/
    list_eqauls f_equals;   /*判断内容相等的函数, nullable*/
};

List * list_new(list_alloc f, int init, int autoRelist) {
    f = !f ? default_alloc : f;
    List * list = (List *) f (NULL, 0, sizeof(List));
    if (!list) return NULL;
    list->_len = 0;
    list->size = 0;
    list->_arr_used = 0;
    list->_c = 0;
    list->load_factor = 0.75F;
    list->f_alloc = f;
    list->f_equals = NULL;
    list->_len = (size_t) init;
    list->arr = (void **) f(NULL, 0, sizeof(void *) * init);
    list->autoRelist = (char) autoRelist;
    if (!list->arr) {
        list->_c = 1;
        return list;
    }
    memset(list->arr, 0, sizeof(void *) * init);
    return list;
}

int list_ero(List * list) {
    return list->_c;
}

void list_set_equals(List * list, list_eqauls f) {
    if (list->_c) return;
    list->f_equals = f;
}

void list_set_load_factor(List * list, float f) {
    if (list->_c) return;
    list->load_factor = f;
}

void list_free(List * list) {
    if (list->arr) list->f_alloc(list->arr, sizeof(void *) * list->_len, 0);
    list->arr = NULL;
    list->f_alloc(list, sizeof(List), 0);
}

void list_relist(List * list) {
    if (list->size == list->_arr_used) return;
    size_t i, j;
    for (i = 0, j = 0; i < list->_arr_used; i ++) {
        void * p = list->arr[i];
        if (p && j != i) {
            list->arr[j ++] = p;
            list->arr[i] = NULL;
        }
    }
    list->_arr_used = list->size;
}

void list_add(List * list, void * v) {
    if (list->_c) return;
    if (!v && !list->autoRelist) return;
    if (list->_arr_used >= list->_len) {
        if (list->_arr_used > list->size) list_relist(list);
        else if (resize(list)) return;
    }
    list->arr[list->_arr_used ++] = v;
    list->size ++;
}

void * list_get(List * list, size_t index) {
    if (list->_c) return NULL;
    if (index >= list->_arr_used) return NULL;
    return list->arr[index];
}

void list_traverse(List *list, list_look_fun fun, void *ud) {
    if (list->_c) return;
    size_t i = 0;
    for (; i < list->_arr_used; ++i) {
        if (list->arr[i]) {
            if (fun(list->arr[i], ud))
                break;
        }
    }
}

size_t list_index(List * list, void * v) {
    if (list->_c) return list->size + 2;
    size_t i;
    for (i = 0; i < list->_arr_used; i ++) {
        void * v1 = list->arr[i];
        if (v1 == v) return i;
        if (list->f_equals && list->f_equals(v1, v)) return i;
    }
    return list->size + 1;
}

void * list_remove(List * list, size_t index) {
    if (list->_c) return NULL;
    if (index >= list->_arr_used) return NULL;
    void * ret = list->arr[index];
    list->arr[index] = NULL;
    list->size -= ret ? 1 : 0;
    if (list->autoRelist) {
        size_t i;
        for (i = index; i <= list->size; i ++) {
            if (i < list->size)
                list->arr[i] = list->arr[i + 1];
            else
                list->arr[i] = NULL;
        }
        list->_arr_used --;
    }
    return ret;
}

void list_remove_obj(List *list, void *obj) {
    if (list->_c) return;
    size_t i;
    int find = 0;
    for (i = 0; i < list->_arr_used; ++i) {
        if (list->arr[i] == obj
            || (list->f_equals && list->f_equals(list->arr[i], obj))) {
            list->arr[i] = NULL;
            list->size --;
            find = 1;
            break;
        }
    }
    if (find && list->autoRelist) {
        size_t index;
        for (index = i; index <= list->size; index ++) {
            if (index < list->size)
                list->arr[index] = list->arr[index + 1];
            else
                list->arr[index] = NULL;
        }
        list->_arr_used --;
    }
}

size_t list_size(List * list) {
    if (list->_c) return 0;
    return list->size;
}

static int resize(List * list) {
    size_t old = list->_len;
    size_t newl = (size_t) (old * list->load_factor) + old;
    newl = newl <= old ? old + 1 : newl;
    list->arr = list->f_alloc(list->arr, sizeof(void *) * old, sizeof(void *) * newl);
    if (!list->arr) {
        list->_c = 1;
        return 1;
    }
    list->_len = newl;
    memset(list->arr + old * sizeof(void *), 0, (newl - old) * sizeof(void *));
    return 0;
}