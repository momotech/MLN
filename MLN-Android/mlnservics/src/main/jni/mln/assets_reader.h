/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-07-25.
//

#ifndef MMLUA4ANDROID_ASSETS_READER_H
#define MMLUA4ANDROID_ASSETS_READER_H

#include <stdlib.h>
#include <jni.h>
#include <android/asset_manager_jni.h>
#include "lua.h"

#define AR_OK               0
#define AR_NOT_INIT         1
#define AR_FILE_NOT_FOUND   2
#define AR_READ_ERROR       3
#define AR_CONTINUE         100

#define READ_BLOCK          1024

void jni_setAssetManager(JNIEnv *env, jobject jobj, jobject assetManager);

long readFromAssets(const char *name, char *out, size_t max, int *error);

/**
 * return AR_CONTINUE to continue read
 */
typedef int (*fd_reader) (int fd, size_t len, void *ud);

int readFromAssetsByReader(const char *name, fd_reader reader, void *ud);

struct AssetsData {
    AAsset *asset;
    off_t len;
    off_t readed;
    int aes;
    char buff[READ_BLOCK];
    int remain;
};

typedef struct AssetsData AD;

int initAssetsData(AD *ud, const char *name);

const char *preReadData(AD *ad, unsigned short len, unsigned short *readLen);

void destroyAssetsData(AD *ud);

const char *getFromAssets(lua_State *L, void *ud, size_t *size);

#endif //MMLUA4ANDROID_ASSETS_READER_H