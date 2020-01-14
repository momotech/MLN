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
/**
 * java设置Assets对象，并缓存
 * @param assetManager java的assetsManager对象
 */
void jni_setAssetManager(JNIEnv *env, jobject jobj, jobject assetManager);

/**
 * 读取Assets下name文件，将数据读到out里，最多读取max字节
 * @param name 文件名
 * @param out  数据，长度必须>=max
 * @param max  最多读取字节数
 * @param error 若传入，则返回后，存储错误码
 * @return 读取时机长度，若读取错误（error=AR_READ_ERROR），则返回读取异常码（负值）
 */
int readFromAssets(const char *name, char *out, size_t max, int *error);

/**
 * return AR_CONTINUE to continue read
 */
typedef int (*fd_reader) (int fd, size_t len, void *ud);
/**
 * 通过fd_reader读取assets下文件
 * @param name   文件名
 * @param reader 读取函数
 * @param ud     自定义数据
 * @return 返回读取结果(fd_reader返回结果)
 */
int readFromAssetsByReader(const char *name, fd_reader reader, void *ud);

///------------------------lua使用的读取方式-----------------------------
///集成读取、缓存、加密功能
///使用方法：
///1、通过initAssetsData初始化struct AssetsData
///2、直接读取preReadData，或通过lua函数读取
///3、通过destroyAssetsData销毁结构体
struct AssetsData {
    AAsset *asset;
    off_t len;
    off_t readed;
    int aes;
    char buff[READ_BLOCK];
    int remain;
};

typedef struct AssetsData AD;
/**
 * 通过文件名name，初始化结构体
 * @param ud   AssetsData结构
 * @param name assets下的文件名
 * @return AR_OK: 成功
 */
int initAssetsData(AD *ud, const char *name);
/**
 * 直接读取指定长度数据
 * @param ad  已初始化过的数据
 * @param len 指定字节数
 * @param readLen 若传入，返回真实读取的字节数
 * @return 读取成功，返回读取的字节，长度为readLen；失败返回空
 */
const char *preReadData(AD *ad, unsigned short len, unsigned short *readLen);
/**
 * 销毁结构体
 */
void destroyAssetsData(AD *ud);
/**
 * 实现lua_Reader
 */
const char *getFromAssets(lua_State *L, void *ud, size_t *size);

#endif //MMLUA4ANDROID_ASSETS_READER_H