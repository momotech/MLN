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