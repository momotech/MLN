//
// Created by Xiong.Fangyu 2019/02/27.
//

#ifndef J_LOG_H
#define J_LOG_H

#include <jni.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_STRING_LENGTH 1000

void initlog(JNIEnv *env);
void log2java(jlong, int, const char *, void *);
#define JLOGI(L, s) log2java((jlong)L, 1, s, NULL)
#define JLOGL(L)    log2java((jlong)L, -1, NULL, NULL)
#define JLOGE(L, s, p) log2java((jlong)L, 2, s, ((void *)p))

// #define lua_writestring(s, l) JLOGI(s)
// #define lua_writeline() log2java(-1, NULL, NULL)
// #define lua_writestringerror(s, p) log2java(2, s, ((void *)p))

#endif // J_LOG_H