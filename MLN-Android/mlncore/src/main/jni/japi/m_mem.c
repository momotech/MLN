/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/06/04.
//

#include <string.h>
#include <pthread.h>
#include "m_mem.h"
#include "map.h"
#include "global_define.h"

#if defined(J_API_INFO)
static size_t all_size = 0;
static void save_trace(void *p, size_t s);
static void remove_trace(void *p, size_t s);
#if defined(MEM_INFO)
/**
 * ptr--->m_mem_info
 */
static Map* __map = NULL;
static pthread_rwlock_t rwlock;
static void init_map();
#endif
#endif

void jni_logMemoryInfo(JNIEnv *env, jobject jobj) {
#if defined(J_API_INFO) && defined(MEM_INFO)
    m_log_mem_infos();
#endif
}

void * m_malloc(void* src, size_t os, size_t ns) {
    if (ns == 0) {
        #if defined(J_API_INFO)
        all_size -= os;
        remove_trace(src, os);
        #endif
        free(src);
        return NULL;
    }
    #if defined(J_API_INFO)
    if (src) remove_trace(src, os);
    #endif
    void * nb = realloc(src, ns);
    #if defined(J_API_INFO)
    if (nb) {
        all_size += (src) ? (ns - os) : ns;
        save_trace(nb, ns);
    }
    #endif
    return nb;
}

#if defined(J_API_INFO)

size_t m_mem_use() {
    return all_size;
}

#if defined(MEM_INFO)
#include "mlog.h"
size_t m_map_size() {
    if (!__map) return 0;
    pthread_rwlock_rdlock(&rwlock);
    size_t s = map_size(__map);
    pthread_rwlock_unlock(&rwlock);
    return s;
}

m_mem_info ** m_get_mem_infos(size_t * out) {
    if (!__map) {
        if (out) *out = 0;
        return NULL;
    }
    pthread_rwlock_rdlock(&rwlock);
    size_t s = map_size(__map);
    pthread_rwlock_unlock(&rwlock);
    m_mem_info ** ret = (m_mem_info **) malloc(sizeof(m_mem_info *) * s);
    if (!ret) {
        if (out) *out = 0;
        return NULL;
    }
    Map_Entry * eo = (Map_Entry *) malloc(sizeof(Map_Entry) * s);
    if (!eo) {
        if (out) *out = 0;
        return NULL;
    }
    memset(eo, 0, sizeof(Map_Entry) * s);
    pthread_rwlock_rdlock(&rwlock);
    size_t rs = map_entrys(__map, eo, s);
    pthread_rwlock_unlock(&rwlock);
    if (out) *out = rs;
    size_t i;
    for (i = 0; i < rs; i++) {
        ret[i] = (m_mem_info *) eo[i].value;
    }
    free(eo);
    return ret;
}

void m_log_mem_infos() {
    #if defined(ENV_64) //64位机器
    static const int MAX = 2000;
    static const int TEMP = 16 + 4;
    static const int R_MAX = MAX - 7 * TEMP;
    #else               //32位
    static const int MAX = 500;
    static const int TEMP = 8 + 4;
    static const int R_MAX = MAX - 7 * TEMP;
    #endif
    if (!__map) {
        LOGE("map is null");
        return;
    }
    pthread_rwlock_rdlock(&rwlock);
    size_t size = map_size(__map);
    pthread_rwlock_unlock(&rwlock);
    LOGE("map size: %d", size);
    if (size == 0) return;
    Map_Entry * eo = (Map_Entry *) malloc(sizeof(Map_Entry) * size);
    if (!eo) {
        LOGE("malloc failed!");
        return;
    }
    memset(eo, 0, sizeof(Map_Entry) * size);
    pthread_rwlock_rdlock(&rwlock);
    size = map_entrys(__map, eo, size);
    pthread_rwlock_unlock(&rwlock);
    
    size_t i;
    int j;
    char temp[TEMP];
    char logstr[MAX];
    int logindex = 0;
    int l;
    for (i = 0; i < size; i++) {
        if (logindex >= R_MAX) {
            memcpy(logstr + logindex, "...\n", 4);
            logindex += 4;
            break;
        }
        Map_Entry entry = eo[i];
        m_mem_info * info = (m_mem_info *)entry.value;
        for (j = 0; j < MAX_TRACE_SIZE; j ++) {
            uintptr_t pc = info->stack_s.pc[j];
            if (!pc) continue;
            char * mn = info->stack_s.method_name[j];
            if (mn) {
                l = strlen(mn);
                memcpy(logstr + logindex, mn, l);
                logindex += l;
            } else {
                memcpy(logstr + logindex, "unknown", 7);
                logindex += 7;
            }
            l = snprintf(temp, TEMP, " %x", pc);
            memcpy(logstr + logindex, temp, l);
            logindex += l;
            memcpy(logstr + logindex, ",", 1);
            logindex ++;
        }
        l = snprintf(temp, TEMP, "%dB, ", info->size);
        memcpy(logstr + logindex, temp, l);
        logindex += l;
        l = snprintf(temp, TEMP, "%p", entry.key);
        if (l == TEMP)
            l = TEMP - 1;
        memcpy(logstr + logindex, temp, l);
        logindex += l;
        memcpy(logstr + logindex, "\n", 1);
        logindex ++;
    }
    memcpy(logstr + logindex, "\0", 1);
    LOGE("memory leak in: \n%s", logstr);
    free(eo);
}

static void free_mt(m_mem_info * mt) {
    int i = 0;
    while (mt->stack_s.method_name[i])
    {
        free(mt->stack_s.method_name[i]);
        mt->stack_s.method_name[i++] = NULL;
    }
    free(mt->stack_s.method_name);
    mt->stack_s.method_name = NULL;
    free(mt->stack_s.pc);
    mt->stack_s.pc = NULL;
    free(mt);
}

unsigned int p_hash (const void * k) {
    return (unsigned int) k;
}

static void init_map() {
    if (!__map) {
        __map = map_new(NULL, 100);
        if (map_ero(__map)) {
            map_free(__map);
            __map = NULL;
        } else {
            map_set_free(__map, NULL, NULL);
            map_set_equals(__map, NULL);
            map_set_hash(__map, p_hash);
            pthread_rwlock_init(&rwlock, NULL);
        }
    }
}
#endif  //MEM_INFO

void remove_by_pointer(void * p, size_t s) {
    all_size -= s;
    remove_trace(p, s);
}

static void save_trace(void *p, size_t s) {
#if defined(MEM_INFO)
    init_map();
    if (!__map) return;
    pthread_rwlock_rdlock(&rwlock);
    m_mem_info * mt = (m_mem_info *) map_get(__map, p);
    pthread_rwlock_unlock(&rwlock);
    if (mt) {
        mt->size = s;
        return;
    }
    mt = (m_mem_info * )malloc(sizeof(m_mem_info));
    memset(mt, 0, sizeof(m_mem_info));
    stack_symbol *_ss = &mt->stack_s;
    _ss->method_name = (char **) malloc(sizeof(char *) * MAX_STACK_LENGTH);
    _ss->pc = malloc(sizeof(uintptr_t) * MAX_STACK_LENGTH);
    _ss->max = MAX_STACK_LENGTH;
    get_call_stack(_ss, 2, 1);
    mt->size = s;

    pthread_rwlock_wrlock(&rwlock);
    map_put(__map, p, mt);
    pthread_rwlock_unlock(&rwlock);
#endif
}

static void remove_trace(void *p, size_t os) {
#if defined(MEM_INFO)
    if (!__map) return;
    pthread_rwlock_rdlock(&rwlock);
    m_mem_info * mt = (m_mem_info *) map_get(__map, p);
    pthread_rwlock_unlock(&rwlock);
    if (mt) {
        mt->size -= os;
        if (!mt->size) {
            pthread_rwlock_wrlock(&rwlock);
            map_remove(__map, p);
            pthread_rwlock_unlock(&rwlock);
            free_mt(mt);
        }
    }
#endif
}
#endif