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
/**
 * 复制字符串，记得调用free
 */
char * copystr(const char *s);
/**
 * 拼接字符串，记得调用free
 */
char * joinstr(const char *, const char *);
/**
 * 拼接字符串，记得调用free
 */
char * join3str(const char *, const char *, const char *);
/**
 * 格式化字符串，记得调用free
 */
char * formatstr(const char *fmt, ...);
/**
 * 格式化长字符串，记得调用free
 */
char * formatlongstr(const char *fmt, ...);

#endif  //JAPI_UTILS_H