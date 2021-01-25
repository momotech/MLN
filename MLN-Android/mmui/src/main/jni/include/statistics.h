//
// Created by XiongFangyu on 2020-05-12.
//

#ifndef MMLUA4ANDROID_STATISTICS_H
#define MMLUA4ANDROID_STATISTICS_H

#include "map.h"

#define InitMethodName "<Init>"

/**
 * 回调函数
 * 参数为字典 className(char*)->methods(map<methodName(char*),count(size_t)>)
 */
typedef void (*callback) (Map *);
/**
 * 回调函数
 */
typedef void (*str_callback) (const char *json);

/**
 * 开关统计功能
 */
void setOpenStatistics(int open);
/**
 * 判断是否打开了统计功能
 */
int isOpenStatistics();
/**
 * userdata相关函数调用
 * @param clz 类名
 * @param method 方法名，若为@code InitMethodName，表示构造函数
 * @see InitMethodName
 */
void userdataMethodCall(const char* clz, const char* method, const double time);
/**
 * 静态相关函数调用
 * @param clz 类名
 * @param method 方法名
 */
void staticMethodCall(const char* clz, const char* method, const double time);
/**
 * 设置回调，和setStrCallback互斥
 * @param c 调用次数达到一定，回调
 */
void setCallback(callback c);
/**
 * 设置回调，和setCallback互斥
 * @param c  调用次数达到一定，回调
 */
void setStrCallback(str_callback c);
/**
 * 通知回调统计信息
 */
void notifyStatisticsCallback();

#endif //MMLUA4ANDROID_STATISTICS_H
