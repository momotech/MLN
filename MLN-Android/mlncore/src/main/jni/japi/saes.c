/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  saes.c
//  TestCommand
//
//  Created by XiongFangyu on 2019/4/18.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#include "saes.h"
#include <sys/stat.h>
#include "m_mem.h"

void encrypt(char * data, SIZE len)
{
    SIZE i;
    for (i = 0 ; i < len ; i ++) {
        data[i] = encryptc(data[i]);
    }
}

void encrypt_cpy(char * dest, const char * src, SIZE len)
{
    SIZE i;
    for (i = 0; i < len; i++)
    {
        dest[i] = encryptc(src[i]);
    }
}

void decrypt(char * data, SIZE len)
{
    SIZE i;
    for (i = 0; i < len; i ++) {
        data[i] = decryptc(data[i]);
    }
}

void decrypt_cpy(char *dest, const char *src, SIZE len) {
    SIZE i;
    for (i = 0; i < len; i++)
    {
        dest[i] = decryptc(src[i]);
    }
}

/**
 * 低位加密后放到高位
 */
char * generate_header(SIZE len)
{
    char * ret = (char *)m_malloc(NULL, 0, SOURCE_LEN);
    int i;
    for(i = 0; i < SOURCE_LEN; i++)
    {
        unsigned char d = (unsigned char) (len >> (i << 3));
        ret[i] = encryptc(d);
    }
    return ret;
}

SIZE check_header(const char *__restrict data)
{
    int i;
    for(i = 0; i < HEADER_LEN; i++)
    {
        if (data[i] != EN_HEADER[i])
            return 0;
    }
    SIZE len = 0;
    const char * rd = data + HEADER_LEN;
    for(i = 0; i < SOURCE_LEN; i ++)
    {
        unsigned char d = decryptc(rd[i]);
        len += ((SIZE) d) << (i << 3);
    }
    return len;
}

int check_file(const char *__restrict file) {
    struct stat statbuf;
    stat(file, &statbuf);
    SIZE size = (SIZE)statbuf.st_size;
    FILE * f = fopen(file, "rb");
    if (!f) return 0;
    char header[HEADER_LEN + SOURCE_LEN + 1];
    int r = fread(header, HEADER_LEN + SOURCE_LEN, 1, f);
    fclose(f);
    return r && check_header(header) == (size - HEADER_LEN - SOURCE_LEN);
}