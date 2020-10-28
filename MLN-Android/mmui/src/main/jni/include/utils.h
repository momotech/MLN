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

#ifndef JAPI_UTILS_H
#define JAPI_UTILS_H

#include <string.h>
/**
 * 复制字符串，记得调用free
 */
char * copystr(const char *s);
/**
 * 拼接字符串
 * @param out 拼接结果在out中
 * @param len out长度
 * @return 1: 拼接成功; 0:失败
 */
int join_string(const char *a, const char *b, char *out, size_t len);
/**
 * 拼接字符串，记得调用free
 */
char * joinstr(const char *, const char *);
/**
 * 拼接字符串
 * @param out 拼接结果在out中
 * @param len out长度
 * @return 1: 拼接成功; 0:失败
 */
int join_3string(const char *a, const char *b, const char *c, char *out, size_t len);
/**
 * 拼接字符串，记得调用free
 */
char * join3str(const char *, const char *, const char *);
/**
 * 格式化字符串
 * @param out 拼接结果在out中
 * @param len out长度
 * @return <0:失败; 字符实际长度
 */
int format_string(char *out, size_t len, const char *fmt, ...);
/**
 * 格式化字符串，记得调用free
 */
char * formatstr(const char *fmt, ...);
/**
 * 格式化长字符串，记得调用free
 */
char * formatlongstr(const char *fmt, ...);
/**
 * 将字符串转化为int，若非数字字符串或非整形，则返回0，成功转换，返回1
 * @param out 转换后的数字
 * @return 0:失败;1:成功
 */
int string_to_int(const char *str, int *out);

#endif  //JAPI_UTILS_H