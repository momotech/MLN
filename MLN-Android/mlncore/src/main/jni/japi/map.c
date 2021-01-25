/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
#include <stdlib.h>
#include <string.h>
#include "map.h"

#define map_index(map, hash) (unsigned int)(hash % map->_len)

#define map_error(map) (map->_c)

#define map_free_entry(k,v,entry) {if (k) k((entry)->key); if (v) v((entry)->value);}

typedef struct _map_entry
{
    unsigned int hash;          /*key的hash值*/
    void * key;                 /*key 默认为字符串*/
    void * value;               /*value*/
    struct _map_entry * next;   /*hash冲突时使用链表解决*/
} _Entry;

struct map_
{
    size_t size;            /*map里键值对实际个数*/
    _Entry ** table;        /*存储键值对，长度为_len(>size)，对key取hash值，再使用map_index及为键值对的下标*/
    size_t _len;            /*长度为table数组的长度*/
    float load_factor;      /*每次扩充map时，长度增量*/
    size_t _thres_hold;     /*size长度>=_thres_hold时，扩充map*/
    map_hash f_hash;        /*计算key hash值的函数*/
    map_equals f_equals;    /*判断key相同的函数*/
    map_free_kv f_free_k;   /*释放key的函数*/
    map_free_kv f_free_v;   /*释放value的函数*/
    int _c;                 /*错误代码*/
    map_alloc f_alloc;      /*内存申请或释放函数*/
    void *ud;               /*用户自定义数据*/
#if defined(J_API_INFO)
    sizeof_kv f_sizeof_k;   /*计算key内存使用*/
    sizeof_kv f_sizeof_v;   /*计算value内存使用*/
    size_t _mem;            /*内存消耗*/
#endif
};

#define EntrySize sizeof(_Entry)
#define EntryPSize sizeof(_Entry*)

static void resize(Map *);
static _Entry * find(Map * map, _Entry * head, const void * key, unsigned int hash);
static _Entry * find_with_pre(Map * map, _Entry * head, _Entry ** pre, const void * key, unsigned int hash);
static unsigned int str_hash(const void * str);
static int str_equals(const void * a, const void * b);
static void s_free(void * p);

static void * default_alloc(void* p, size_t os, size_t ns) {
    if (ns == 0) {
        free(p);
        return NULL;
    }
    return realloc(p, ns);
}

Map * map_new(map_alloc f, int init) {
    f = !f ? default_alloc : f;
    Map * map = (Map *) f(NULL, 0, sizeof(Map));
    if (!map) return NULL;
    map->size = 0;
    map->load_factor = 0.75f;
    map->_thres_hold = init;
    map->f_hash = str_hash;
    map->f_equals = str_equals;
    map->f_free_k = s_free;
    map->f_free_v = s_free;
    map->_len = 0;
    map->_c = 0;
    map->f_alloc = f;
#if defined(J_API_INFO)
    map->f_sizeof_k = NULL;
    map->f_sizeof_v = NULL;
    map->_mem = sizeof(Map);
#endif
    
    int len = (int) (init * 1.75f);
    size_t ms = EntryPSize * len;
    map->table = (_Entry **) f(NULL, 0, ms);
    if (!map->table) {
        map->_c = ER_MEM;
        return map;
    }
    memset(map->table, 0, ms);
    map->_len = len;
#if defined(J_API_INFO)
    map->_mem += ms;
#endif
    return map;
}

int map_ero(Map * map) {
    return map_error(map);
}

void map_set_load_factor(Map * map, float t) {
    if (map_error(map)) return;
    map->load_factor = t;
    map->_thres_hold = (size_t)(map->_len / (1 + t));
}

void map_set_hash(Map * map, map_hash f) {
    if (map_error(map)) return;
    map->f_hash = f;
}

void map_set_equals(Map * map, map_equals f) {
    if (map_error(map)) return;
    map->f_equals = f;
}

void map_set_free(Map * map, map_free_kv fk, map_free_kv fv) {
    if (map_error(map)) return;
    map->f_free_k = fk;
    map->f_free_v = fv;
}

void map_set_ud(Map *map, void *ud) {
    if (map_error(map)) return;
    map->ud = ud;
}

void *map_get_ud(Map *map) {
    return map->ud;
}

void map_free(Map * map) {
    map_free_kv fk = map->f_free_k;
    map_free_kv fv = map->f_free_v;
    size_t i;
    for (i = 0; i < map->_len; i++) {
        _Entry* entry = map->table[i];
        if (!entry) continue;
        do {
            map_free_entry(fk, fv, entry);
            _Entry * temp = entry->next;
            map->f_alloc(entry, EntrySize, 0);
            entry = temp;
        } while (entry);
    }
    map->f_alloc(map->table, EntryPSize * map->_len, 0);
    map->f_hash = NULL;
    map->f_equals = NULL;
    map->f_free_k = NULL;
    map->f_free_v = NULL;
#if defined(J_API_INFO)
    map->f_sizeof_k = NULL;
    map->f_sizeof_v = NULL;
    map->_mem = 0;
#endif
    map->f_alloc(map, sizeof(Map), 0);
}

void map_remove_all(Map *map) {
    map_free_kv fk = map->f_free_k;
    map_free_kv fv = map->f_free_v;
    size_t i;
    for (i = 0; i < map->_len; i++) {
        _Entry* entry = map->table[i];
        if (!entry) continue;
        do {
            map_free_entry(fk, fv, entry);
            _Entry * temp = entry->next;
            map->f_alloc(entry, EntrySize, 0);
            entry = temp;
        } while (entry);
        map->table[i] = NULL;
    }
    map->size = 0;
}

void * map_put(Map * map, void * key, void * value) {
    if (map_error(map)) return NULL;
    unsigned int hash = map->f_hash(key);
    unsigned int i = map_index(map, hash);
    _Entry * entry = map->table[i];
    void * ret = NULL;
    int add = 0;
    /// 未存储过
    if (!entry) {
        entry = (_Entry *) map->f_alloc(NULL, 0, EntrySize);
        map->table[i] = entry;
        if (!entry) {
            map->_c = ER_MEM;
            add = 0;
        } else {
            entry->hash = hash;
            entry->key = key;
            entry->value = value;
            entry->next = NULL;
            #if defined(J_API_INFO)
            map->_mem += EntrySize 
                        + (map->f_sizeof_k ? map->f_sizeof_k(key) : 0)
                        + (map->f_sizeof_v ? map->f_sizeof_v(value) : 0);
            #endif
            add = 1;
        }
    } else {
        _Entry *e = find(map, entry, key, hash);
        /// 已有相同key
        if (e) {
            ret = e->value;
            e->value = value;
            #if defined(J_API_INFO)
            map->_mem += (map->f_sizeof_v ? map->f_sizeof_v(value) - map->f_sizeof_v(ret): 0);
            #endif
            add = 0;
        }
        /// hash碰撞，在链表头增加
        else {
            e = (_Entry *) map->f_alloc(NULL, 0, EntrySize);
            if (!e) {
                map->_c = ER_MEM;
                add = 0;
            } else {
                e->hash = hash;
                e->key = key;
                e->value = value;
                map->table[i] = e;
                e->next = entry;
                #if defined(J_API_INFO)
                map->_mem += EntrySize 
                            + (map->f_sizeof_k ? map->f_sizeof_k(key) : 0)
                            + (map->f_sizeof_v ? map->f_sizeof_v(value) : 0);
                #endif
                add = 1;
            }
        }
    }
    map->size += add;
    if (map->size >= map->_thres_hold) resize(map);
    return ret;
}

void * map_get(Map *map, const void *key) {
    if (map_error(map)) return NULL;
    unsigned int hash = map->f_hash(key);
    unsigned int i = map_index(map, hash);
    _Entry * entry = map->table[i];
    if (!entry) return NULL;
    _Entry *e = find(map, entry, key, hash);
    if (e) return e->value;
    return NULL;
}

void * map_remove(Map * map, const void * key) {
    if (map_error(map)) return NULL;
    unsigned int hash = map->f_hash(key);
    unsigned int i = map_index(map, hash);
    _Entry *entry = map->table[i];
    if (!entry) return NULL;
    
    _Entry *pre = entry;
    _Entry *e = find_with_pre(map, entry, &pre, key, hash);
    if (e) {
        map->size --;
        void * ret = e->value;
        e->hash = 0;
        if (key != e->key && map->f_free_k) {
            #if defined(J_API_INFO)
            map->_mem -= (map->f_sizeof_k ? map->f_sizeof_k(e->key) : 0);
            #endif
            map->f_free_k(e->key);
        }
        /// 对应entry就在头部，直接去掉头部
        if (e == entry) {
            map->table[i] = e->next;
        }
        /// 不在头部，去掉节点
        else {
            pre->next = e->next;
        }
        e->next = NULL;
        e->key = NULL;
        #if defined(J_API_INFO)
        map->_mem -= EntrySize - (map->f_sizeof_v ? map->f_sizeof_v(ret) : 0);
        #endif
        map->f_alloc(e, EntrySize, 0);
        return ret;
    }
    return NULL;
}

size_t map_size(Map * map) {
    if (map_error(map)) return 0;
    return map->size;
}

size_t map_table_size(Map * map) {
    return map->_len;
}

size_t map_entrys(Map * map, Map_Entry * out, size_t size) {
    if (map_error(map) || !out || !size) return 0;
    
    size_t ret = 0;
    size_t i;
    for (i = 0; i < map->_len && ret < size; i++) {
        _Entry * temp = map->table[i];
        if (!temp) continue;
        do {
            out[ret].key = temp->key;
            out[ret].value = temp->value;
            ret ++;
        } while (ret < size && (temp = temp->next));
    }
    
    return ret;
}

void map_traverse(Map *map, map_look_fun traverse_function, void *ud) {
    if (map_error(map) || !traverse_function) return;

    size_t i;
    int result = 0;
    for (i = 0; i < map->_len && !result; i++) {
        _Entry * temp = map->table[i];
        if (!temp) continue;
        do {
            result = traverse_function(temp->key, temp->value, ud);
        } while ((temp = temp->next) && !result);
    }
}

static unsigned int str_hash(const void * str) {
    const char *s = (const char *) str;
    int h = 0;
    for (; *s; s++)
        h = *s+h*31;
    return h;
}

static int str_equals(const void * a, const void * b) {
    const char * ba = (const char *) a;
    const char * bb = (const char *) b;
    return strcmp(ba, bb) == 0;
}

static void s_free(void * p) {
    free(p);
}

static _Entry * find(Map * map, _Entry * head, const void * key, unsigned int hash) {
    _Entry * e = head;
    while (e) {
        if (e->key == key) break;
        if (map->f_equals && map->f_equals(e->key, key)) break;
        e = e->next;
    }
    return e;
}

static _Entry * find_with_pre(Map * map, _Entry * head, _Entry ** pre, const void * key, unsigned int hash) {
    _Entry * e = head;
    while (e) {
        if (e->key == key) break;
        if (map->f_equals && map->f_equals(e->key, key)) break;
        *pre = e;
        e = e->next;
    }
    return e;
}

static void resize(Map *map) {
    size_t old_len = map->_len;
    size_t new_len = (size_t)(map->_len * map->load_factor) + map->_len;
    if (new_len <= old_len) new_len = old_len + 1;
    
    _Entry ** old_table = map->table;
    map->table = (_Entry **)map->f_alloc(NULL, 0, EntryPSize * new_len);
    if (!map->table) {
        map->_c = ER_MEM;
        return;
    }
    memset(map->table, 0, EntryPSize * new_len);
    map->_len = new_len;
    map->_thres_hold = old_len;
    /// 调整数据位置
    size_t i;
    for (i = 0; i < old_len; i++) {
        _Entry* entry = old_table[i];
        if (!entry) continue;
        old_table[i] = NULL;
        _Entry* temp;
        _Entry* next;
        do {
            /// 寻找对应hash值新的位置
            unsigned int ni = map_index(map, entry->hash);
            temp = map->table[ni];
            map->table[ni] = entry;
            next = entry->next;
            entry->next = temp;
            entry = next;
        } while(entry);
    }
    map->f_alloc(old_table, EntryPSize * old_len, 0);
    #if defined(J_API_INFO)
    map->_mem += EntryPSize * (new_len - old_len);
    #endif
}

//<editor-fold desc="to string">
#define _f_error (char) 1
#define _f_malloc (char) 2
#define _f_finf (char) 4

#define _is_error(d) (((d)->flag) & _f_error)
#define _set_error(d) (d)->flag = (((d)->flag) | _f_error)

#define _is_malloc(d) (((d)->flag) & _f_malloc)
#define _set_malloc(d) (d)->flag = (((d)->flag) | _f_malloc)

#define _is_in_first(d) (((d)->flag) & _f_finf)
#define _set_not_in_first(d) (d)->flag = (((d)->flag) & ~(_f_finf))

typedef struct _data {
    char* str;
    size_t len;
    size_t i;
    /// 使用3位
    /// * * * *
    /// *     1   是否有错误
    /// *   1     str是否是堆内存
    /// * 1       map是否是第一个数据
    char flag;
    map_value_to_string k2s;
    map_value_to_string v2s;
    map_alloc allocFun;
} _data;

/**
 * 增加字符串的长度
 * @return 0：成功
 */
int _increase_str(_data *d, size_t min) {
    map_alloc m_malloc = d->allocFun;
    if (d->len - d->i < min) {
        /// 字符串放不下的情况
        size_t newlen = (size_t) (d->len * 1.75f);
        size_t needlen = min + d->i;
        newlen = newlen < needlen ? needlen : newlen;
        if (_is_malloc(d)) {
            d->str = m_malloc(d->str, d->len * sizeof(char), newlen);
            memset(d->str + d->len, 0, newlen - d->len);
        } else {
            char *new_str = m_malloc(NULL, 0, newlen);
            if (!new_str)
                return 1;
            memcpy(new_str, d->str, d->len);
            d->str = new_str;
        }
        if (!d->str) {
            //有错误
            return 1;
        }
        d->len = newlen;
        _set_malloc(d);
    }
    return 0;
}

int _map_look_to_json(const void *key, const void *value, void *ud) {
    _data *d = (_data *)ud;
    int needFreeKeyStr;
    int needFreeValueStr;
    char *keystr = d->k2s(key, &needFreeKeyStr);
    char *valuestr = d->v2s(value, &needFreeValueStr);
    size_t sl = strlen(keystr);
    size_t vl = strlen(valuestr);
    int isFirstData = _is_in_first(d);
    if (_increase_str(d, vl + sl + (isFirstData ? 3 : 4))) { //"key": 多"":三个字符，第二个数据在前面多一个','
        if (needFreeKeyStr)
            d->allocFun(keystr, (sl + 1) * sizeof(char), 0);
        if (needFreeValueStr)
            d->allocFun(valuestr, (vl + 1) * sizeof(char), 0);
        _set_error(d);
        return 1;
    }
    if (!isFirstData)
        d->str[d->i++] = ',';
    else
        _set_not_in_first(d);
//    LOGI("%s 开始, \n\tstr:%s\n\tlen:%d\n\ti:%d", clz, d->str, d->len, d->i);
    d->str[d->i++] = '"';
    memcpy(&d->str[d->i], keystr, sl * sizeof(char));
    d->i += sl;
    d->str[d->i++] = '"';
    d->str[d->i++] = ':';
    /// "key":  完成
    memcpy(&d->str[d->i], valuestr, vl * sizeof(char));
    d->i += vl;
    if (needFreeKeyStr)
        d->allocFun(keystr, (sl + 1) * sizeof(char), 0);
    if (needFreeValueStr)
        d->allocFun(valuestr, (vl + 1) * sizeof(char), 0);
    return 0;
}

static char *__default_to_string(const void *v, int *needFree) {
    if (needFree) *needFree = 0;
    return (char *)v;
}

char *map_to_string(Map *map, map_value_to_string k2s, map_value_to_string v2s) {
    if (map_error(map)) return NULL;
    static const size_t len = 100;
    char str[len] = {'{', '\0'};
    if (!k2s)
        k2s = __default_to_string;
    if (!v2s)
        v2s = __default_to_string;
    _data d = {str, len, 1,   _f_finf, k2s, v2s, map->f_alloc};
    map_traverse(map, _map_look_to_json, &d);
    if (_is_error(&d) || _increase_str(&d, d.len + 2))
        return NULL;
    d.str[d.i++] = '}';
    d.str[d.i] = '\0';
    char *ret = map->f_alloc(NULL, 0, (strlen(d.str) + 1) * sizeof(char));
    if (ret) {
        strcpy(ret, d.str);
    }
    if (_is_malloc(&d)) {
        map->f_alloc(d.str, d.len * sizeof(char), 0);
    }
    return ret;
}
//</editor-fold>

#if defined(J_API_INFO)
size_t map_mem(Map * map) {
    return map->_mem;
}

void map_set_sizeof(Map * map, sizeof_kv k, sizeof_kv v) {
    map->f_sizeof_k = k;
    map->f_sizeof_v = v;
}
#endif