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

typedef void* (*list_alloc) (void *, size_t, size_t);

typedef int (*list_eqauls) (const void *, const void *);

struct list_;

typedef struct list_ List;

List * list_new(list_alloc f, int init, int autoRelist);

int list_ero(List *);

void list_set_equals(List *, list_eqauls);

void list_set_load_factor(List *, float);

void list_free(List *);

void list_add(List *, void *);

void list_relist(List *);

void * list_get(List *, size_t);

size_t list_index(List *, void *);

void * list_remove(List *, size_t);

size_t list_size(List *);

#endif /* List_h */
