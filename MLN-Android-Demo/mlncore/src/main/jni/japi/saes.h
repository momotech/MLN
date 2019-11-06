//
//  saes.h
//  TestCommand
//
//  Created by XiongFangyu on 2019/4/18.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#ifndef saes_h
#define saes_h

#include <stdio.h>

#define SIZE            unsigned long long

#define HEADER          "\x73\x61\x65\x73"//sens
#define EN_HEADER       "\x21\x33\x37\x21"//sencrypt(HEADER,4)
#define HEADER_LEN      4
#define SOURCE_LEN      sizeof(SIZE)
#define KEY1            0xfae821
#define KEY2            0xdbc573
#define encryptc(c)    (c ^ KEY1 ^ KEY2)
#define decryptc(c)    (c ^ KEY2 ^ KEY1)
/**
 * 加密原始数据
 */
void encrypt(char * data, SIZE len);
/**
 * 将src加密数据拷贝到dest中
 */
void encrypt_cpy(char * dest, const char * src, SIZE len);
/**
 * 解密原始数据
 */
void decrypt(char * data, SIZE len);
/**
 * 将长度加密并转换成字符串
 * 字符串长度为 SOURCE_LEN
 * 记得调用free
 */
char * generate_header(SIZE len);
/**
 * 检查头部是否正确
 * 正确，返回原始数据长度
 * 错误，返回0
 */
SIZE check_header(const char *__restrict data);
/**
 * 检查文件是否是使用saes加密
 */
int check_file(const char *__restrict in);
#endif /* saes_h */
