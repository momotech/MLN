//
// Created by MOMO on 2020-07-09.
//

#ifndef MMLUA4ANDROID_STATISTICS_REQUIRE_H
#define MMLUA4ANDROID_STATISTICS_REQUIRE_H

#include "map.h"

#define FROM_SEARCHER_JAVA "Java"
#define FROM_SEARCHER_LUA "Lua"
#define FROM_SEARCHER_ASSET "Asset"

#define InitMethodName "<Init>"

/**
 * 函数回调
 * 参数为字典 fromType(char*)->methods(map<fileName(char*),time(size_t)>)
 */
typedef void (*requireCallback)(Map *);
/**
 * 回调函数
 */
typedef void (*require_str_callback) (const char *json);

/**
 * 开关统计功能
 */
void setOpenRequireStatistics(int open);

/**
 * 判断是否打开了统计功能
 */
int isOpenRequireStatistics();

/**
 * 统计require调用时间
 */
void statistics_searcher_Call(const char *fromType, const char *filename, double time);

double getStartTime();

double getoffsetTime(double last);

/**
 * 通知回调统计信息
 */
void notifyRequireCallback();

/**
 * 设置回调
 * @param c 回调
 */
void setRequireCallback(requireCallback c);
void setRequireStrCallback(require_str_callback c);

#endif //MMLUA4ANDROID_STATISTICS_REQUIRE_H
