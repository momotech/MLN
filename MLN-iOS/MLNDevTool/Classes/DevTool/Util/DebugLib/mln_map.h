/**
 * Created by Xiong.fangyu 2019/05/21
 */
#ifndef MAP_H
#define MAP_H

#include <stdio.h>

typedef unsigned int (*map_hash) (const void *);

typedef int (*map_equals) (const void *, const void *);

typedef void (*map_free_kv) (void *);

typedef void * (*map_alloc) (void* , size_t , size_t );

struct map_;

typedef struct map_ Map;

typedef struct m_entry {
    void * key;
    void * value;
} Map_Entry;

Map * map_new(map_alloc f, int init);

int map_ero(Map *);

void map_set_load_factor(Map *, float);

void map_set_hash(Map *, map_hash);

void map_set_equals(Map *, map_equals);

void map_set_free(Map *, map_free_kv, map_free_kv);

void map_free(Map *);

void * map_put(Map * map, void * key, void * value);

void * map_get(Map *map, const void *key);

void * map_remove(Map * map, const void * key);

size_t map_size(Map *);

size_t map_table_size(Map *);

size_t map_entrys(Map * map, Map_Entry * out, size_t size);

#if defined(J_API_INFO)
typedef size_t (*sizeof_kv) (void *);

size_t map_mem(Map *);

void map_set_sizeof(Map *, sizeof_kv, sizeof_kv);
#endif
#endif  //MAP_H
