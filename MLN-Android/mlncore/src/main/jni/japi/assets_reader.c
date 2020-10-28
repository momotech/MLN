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

#include "assets_reader.h"
#include "saes.h"
#include <unistd.h>
#include <string.h>


static AAssetManager *assetManager = NULL;

void jni_setAssetManager(JNIEnv *env, jobject jobj, jobject am) {
    assetManager = AAssetManager_fromJava(env, am);
}

int readFromAssets(const char *name, char *out, size_t max, int *error) {
    if (!assetManager) {
        if (error) *error = AR_NOT_INIT;
        return 0;
    }

    AAsset *asset = AAssetManager_open(assetManager, name, AASSET_MODE_BUFFER);
    if (!asset) {
        if (error) *error = AR_FILE_NOT_FOUND;
        return 0;
    }

    off_t len = AAsset_getLength(asset);

    int ret = AAsset_read(asset, out, max > len ? len : max);
    AAsset_close(asset);

    if (ret < 0) {
        if (error) *error = AR_READ_ERROR;
        return ret;
    }
    if (error) *error = AR_OK;
    return ret;
}

int readFromAssetsByReader(const char *name, fd_reader reader, void *ud) {
    if (!assetManager) return AR_NOT_INIT;

    AAsset *asset = AAssetManager_open(assetManager, name, AASSET_MODE_BUFFER);
    if (!asset) return AR_FILE_NOT_FOUND;

    off_t len = AAsset_getLength(asset);
    off_t start = 0;
    off_t length = 0;
    int fd = AAsset_openFileDescriptor(asset, &start, &length);
    lseek(fd, start, SEEK_CUR);

    int ret;
    while ((ret = reader(fd, (size_t) len, ud)) == AR_CONTINUE);

    close(fd);
    AAsset_close(asset);

    return ret;
}

int initAssetsData(AD *ud, const char *name) {
    if (!assetManager) return AR_NOT_INIT;
    memset(ud, 0, sizeof(AD));

    ud->asset = AAssetManager_open(assetManager, name, AASSET_MODE_BUFFER);
    if (!ud->asset) return AR_FILE_NOT_FOUND;

    ud->len = AAsset_getLength(ud->asset);
    return AR_OK;
}

const char *preReadData(AD *ad, unsigned short len, unsigned short *readLen) {
    if (!ad->asset) return NULL;

    int r = AAsset_read(ad->asset, ad->buff, (size_t)len);
    if (r <= 0) return NULL;
    if (readLen) *readLen = (unsigned short) r;

    return ad->buff;
}

void destroyAssetsData(AD *ud) {
    if (ud->asset)
        AAsset_close(ud->asset);
    ud->asset = NULL;
}

const char *getFromAssets(lua_State *L, void *ud, size_t *size) {
    AD *ad = (AD *) ud;
    if (!ad->asset)
        return NULL;

    (void) L; /* not used */

    if (ad->remain > 0) {
        *size = (size_t) ad->remain;
        ad->remain = 0;
        return ad->buff;
    }

    /// 检查文件是否已读完
    if (ad->readed == ad->len)
        return NULL;

    int r = AAsset_read(ad->asset, ad->buff, READ_BLOCK);
    if (r <= 0)
        return NULL;

    ad->readed += r;
    *size = (size_t) r;
    if (ad->aes) decrypt(ad->buff, (SIZE) r);
    return ad->buff;
}