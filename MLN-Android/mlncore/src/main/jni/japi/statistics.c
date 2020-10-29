//
// Created by XiongFangyu on 2020-05-12.
//

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "statistics.h"
#include "m_mem.h"
#include "utils.h"
#include "mlog.h"

#define InitCount 10
/// 是否开启统计功能
static int open = 0;
static callback _callback = NULL;
static str_callback _str_callback = NULL;

static char *_inner_map_to_json(const void *value, int *needFree);

//<editor-fold desc="time">
#define COUNT_KEY "\"count\""
#define TIME_KEY "\"time\""
#define BRACKET_PRE "{"
#define BRACKET_POST "}"
#define COLON ":"
#define COMMA ","

typedef struct _param {
    int count;
    double time;
} _param;

//</editor-fold>

//<editor-fold desc="map init">
/**
 * key: class name (const char*)
 * value: map(key:method(const char*), value:count(int))
 */
static Map* statisticsMap;

static void _free_str(void *v) {
    char *str = (char *) v;
    m_malloc(str, sizeof(char) * (strlen(str) + 1), 0);
}

static void _free_param(void *v) {
    m_malloc(v, sizeof(_param), 0);
}

static void _free_map(void *v) {
    Map *map = (Map *) v;
    map_free(map);
}

static void initStatisticsMap() {
    statisticsMap = map_new(m_malloc, InitCount);
    if (map_ero(statisticsMap)) {
        map_free(statisticsMap);
        statisticsMap = NULL;
        return;
    }
    map_set_free(statisticsMap, _free_str, _free_map);
}

static Map *initMethodsMap() {
    Map *map = map_new(m_malloc, InitCount);
    if (map_ero(map)) {
        map_free(map);
        return NULL;
    }
    map_set_free(map, _free_str, _free_param);
    return map;
}
//</editor-fold>

void setOpenStatistics(int o) {
#ifdef STATISTIC_PERFORMANCE
    // 现在打开
    if (o && !open) {
        open = o;
        initStatisticsMap();
    }
    // 现在关闭
    else if (!o && open) {
        open = o;
        map_free(statisticsMap);
    }
#endif
}

int isOpenStatistics() {
#ifdef STATISTIC_PERFORMANCE
    return open;
#else
    return 0;
#endif
}

void userdataMethodCall(const char* clz, const char* method, const double time) {
#ifdef STATISTIC_PERFORMANCE
    if (!isOpenStatistics() || !statisticsMap)
        return;
    Map *methods = (Map *) map_get(statisticsMap, clz);
    if (!methods) {
        methods = initMethodsMap();
        if (!methods)
            return;
        map_put(statisticsMap, copystr(clz), methods);
    }
    _param *params = (_param *) map_get(methods, method);
    if (!params) {
        params = m_malloc(NULL, 0, sizeof(_param));
        params->count = 0;
        params->time = 0;
        map_put(methods, copystr(method), params);
    }
    params->count += 1;
    params->time += time;
#endif
}

void staticMethodCall(const char* clz, const char* method, const double time) {
#ifdef STATISTIC_PERFORMANCE
    if (!isOpenStatistics() || !statisticsMap)
        return;

    Map *methods = (Map *) map_get(statisticsMap, clz);
    if (!methods) {
        methods = initMethodsMap();
        if (!methods)
            return;
        map_put(statisticsMap, copystr(clz), methods);
    }
    _param *params = (_param *) map_get(methods, method);
    if (!params) {
        params = m_malloc(NULL, 0, sizeof(_param));
        params->count = 0;
        params->time = 0;
        map_put(methods, copystr(method), params);
    }
    params->count += 1;
    params->time += time;
#endif
}

void notifyStatisticsCallback() {
#ifdef STATISTIC_PERFORMANCE
    if (statisticsMap) {
        if (_callback) {
            _callback(statisticsMap);
        } else if (_str_callback) {
            char *str = map_to_string(statisticsMap, NULL, _inner_map_to_json);
            _str_callback(str);
            m_malloc(str, (strlen(str) + 1) * sizeof(char), 0);
        }
        map_remove_all(statisticsMap);
    }
#endif
}

void setCallback(callback c) {
#ifdef STATISTIC_PERFORMANCE
    _callback = c;
    _str_callback = NULL;
#endif
}

void setStrCallback(str_callback c) {
#ifdef STATISTIC_PERFORMANCE
    _callback = NULL;
    _str_callback = c;
#endif
}

//<editor-fold desc="to string">

static char *_int_to_string(const void *value, int *needFree) {
    _param *params = (_param *) value;
    char count[10] = {0};
    char time[20] = {0};
    sprintf(count, "%d", params->count);
    sprintf(time, "%lf", params->time);
    if (needFree) *needFree = 1;
    char *str = (char *) malloc(
            strlen(BRACKET_PRE) +
            strlen(COUNT_KEY) + strlen(COLON) + strlen(count) +
            strlen(COMMA) +
            strlen(TIME_KEY) + strlen(COLON) + strlen(time) +
            strlen(BRACKET_POST) + 1);
    strcpy(str, BRACKET_PRE);
    strcat(str, COUNT_KEY);
    strcat(str, COLON);
    strcat(str, count);
    strcat(str, COMMA);
    strcat(str, TIME_KEY);
    strcat(str, COLON);
    strcat(str, time);
    strcat(str, BRACKET_POST);
    strcat(str, "\0");
    return str;
}

static char *_inner_map_to_json(const void *value, int *needFree) {
    Map *map = (Map *) value;
    if (needFree) *needFree = 1;
    return map_to_string(map, NULL, _int_to_string);
}
//</editor-fold>