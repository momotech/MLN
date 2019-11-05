/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/04/12.
//

#include "utils.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "m_mem.h"

#define MIN_SIZE 400
#define MAX_SIZE 1024

/**
 * 复制字符串，记得调用free
 */
char * copystr(const char *s)
{
    char *result = m_malloc(NULL, 0, (strlen(s) + 1) * sizeof(char));
    if (!result) return NULL;
    strcpy(result, s);
    return result;
}
/**
 * 拼接字符串，记得调用free
 */
char * joinstr(const char *a, const char *b)
{
    size_t len = (strlen(a)+strlen(b)+1);
    char *result = m_malloc(NULL, 0, len * sizeof(char));
    if (!result) return NULL;
    memset(result, 0, len);
    strcpy(result, a);
    strcat(result, b);
    return result;
}
/**
 * 拼接字符串，记得调用free
 */
char * join3str(const char *a, const char *b, const char *c) {
    size_t len = (strlen(a) + strlen(b) + strlen(c) + 1);
    char *ret = m_malloc(NULL, 0, len * sizeof(char));
    if (!ret) return NULL;

    memset(ret, 0, len);
    strcpy(ret, a);
    strcat(ret, b);
    strcat(ret, c);
    return ret;
}

/**
 * 记得调用free
 */
char * formatstr(const char *fmt, ...)
{
    char temp[MIN_SIZE];
    va_list argp;
    va_start(argp, fmt);
    int n = vsnprintf(temp, MIN_SIZE, fmt, argp);
    va_end(argp);
    if (n > 0 && n < MIN_SIZE)
    {
        char *ret = (char *)m_malloc(NULL, 0, sizeof(char) * (n + 1));
        memcpy(ret, temp, n);
        ret[n] = '\0';
        return ret;
    }
    return NULL;
}
/**
 * 记得调用free
 */
char * formatlongstr(const char *fmt, ...)
{
    char temp[MAX_SIZE];
    va_list argp;
    va_start(argp, fmt);
    int n = vsnprintf(temp, MAX_SIZE, fmt, argp);
    va_end(argp);
    if (n > 0)
    {
        char *ret = (char *)m_malloc(NULL, 0, sizeof(char) * (n + 1));
        memcpy(ret, temp, n);
        ret[n] = '\0';
        return ret;
    }
    return NULL;
}