//
// Created by MOMO on 2020-07-09.
//
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "statistics_require.h"
#include "m_mem.h"
#include "utils.h"
#include "mlog.h"

#define InitCount 10

/// 是否开启统计功能
static int open = 0;
static requireCallback _callback;
static require_str_callback _str_callback;
#define _get_millsecond(t) ((t)->tv_sec * 1000000.0 + (t)->tv_usec)

static char *_to_json(Map *map);

/**
 * key: fromType(char*)
 * value: map<fileName(char*),time(size_t)>
 */
static Map *statisticsMap;

static void _free_str(void *v) {
    char *str = (char *) v;
    m_malloc(str, sizeof(char) * (strlen(str) + 1), 0);
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

    map_set_free(map, _free_str, NULL);
    return map;
}

void setOpenRequireStatistics(int o) {
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
};

int isOpenRequireStatistics() {
#ifdef STATISTIC_PERFORMANCE
    return open;
#else
    return 0;
#endif
}

void statistics_searcher_Call(const char *fromType, const char *filename, double time) {
#ifdef STATISTIC_PERFORMANCE
    if (!isOpenRequireStatistics() || !statisticsMap)
        return;

    Map *files = (Map *) map_get(statisticsMap, fromType);
    if (!files) {
        files = initMethodsMap();
        if (!files)
            return;
        map_put(statisticsMap, copystr(fromType), files);
    }

    map_put(files, copystr(filename), (int)time);
#endif
}

void notifyRequireCallback() {
#ifdef STATISTIC_PERFORMANCE
    if (statisticsMap) {
        if (_callback) {
            _callback(statisticsMap);
        } else if (_str_callback) {
            char *str = _to_json(statisticsMap);
            _str_callback(str);
            m_malloc(str, (strlen(str) + 1) * sizeof(char), 0);
        }
    }
    map_remove_all(statisticsMap);
#endif
}

void setRequireCallback(requireCallback c) {
#ifdef STATISTIC_PERFORMANCE
    _callback = c;
    _str_callback = NULL;
#endif
};

void setRequireStrCallback(require_str_callback c) {
#ifdef STATISTIC_PERFORMANCE
    _callback = NULL;
    _str_callback = c;
#endif
}

double getStartTime() {
    struct timeval now = {0};
    gettimeofday(&now, NULL);
    return _get_millsecond(&now);
};

double getoffsetTime(double last) {
    struct timeval now = {0};
    gettimeofday(&now, NULL);

    return _get_millsecond(&now) - last;
};


//<editor-fold desc="to string">

static char *_int_to_string(const void *value, int *needFree) {
    size_t count = (size_t) value;
    char number[20] = {0};
    sprintf(number, "%f", count * 0.001f);
    if (needFree) *needFree = 1;
    return copystr(number);
}

static char *_inner_map_to_json(const void *value, int *needFree) {
    Map *map = (Map *) value;
    if (needFree) *needFree = 1;
    return map_to_string(map, NULL, _int_to_string);
}

static char *_to_json(Map *map) {
    return map_to_string(map, NULL, _inner_map_to_json);
}
//</editor-fold>