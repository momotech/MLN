/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/02/22.
//

#ifndef LUA_LOG_H
#define LUA_LOG_H

#if defined(J_API_INFO)
    #if defined(P_ANDROID)
        #include <android/log.h>
        #define LOG_TAG "LUA_J_API"
        #define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
        #define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
        #define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
    #else
        #include <stdio.h>
        #include <stdarg.h>
        #define __LOG_MAX_SIZE 300
        static int __log(char * type, ...) {
            va_list ap;
            va_start(ap, type);
            char * fmt = va_arg(ap, char *);
            char temp[__LOG_MAX_SIZE] = {'\0'};
            int n = vsnprintf(temp, __LOG_MAX_SIZE, fmt, ap);
            va_end(ap);
            if (n > 0) return printf(type, temp);
            return 0;
        }
        #define LOGI(...) __log("i:%s\n", __VA_ARGS__)
        #define LOGE(...) __log("e:%s\n", __VA_ARGS__)
        #define LOGW(...) __log("w:%s\n", __VA_ARGS__)
    #endif
#else
#define LOGI(...)
#define LOGE(...)
#define LOGW(...)
#endif //J_API_INFO
#endif //LUA_LOG_H