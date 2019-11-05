/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
#include <jni.h>
#include <android/log.h>
#include <android/bitmap.h>

#include "blur.c"

#define LOG_D(...) __android_log_print(ANDROID_LOG_DEBUG,"bitmap_util" ,__VA_ARGS__)

/*
 * Class:     com.immomo.mls.util.BitmapUtil
 * Method:    nativeBlurBitmap
 * Signature: (Landroid/graphics/Bitmap;I)V
 */
JNIEXPORT void JNICALL Java_com_immomo_mls_util_BitmapUtil_nativeBlurBitmap
  (JNIEnv *env, jclass cls, jobject srcbmp, jint radius){
    AndroidBitmapInfo infoIn;
    void *pixels;

    // Get image info
    if (AndroidBitmap_getInfo(env, srcbmp, &infoIn) != ANDROID_BITMAP_RESULT_SUCCESS) {
        LOG_D("AndroidBitmap_getInfo failed!");
        return;
    }

    // Check image
    if (infoIn.format != ANDROID_BITMAP_FORMAT_RGBA_8888 &&
        infoIn.format != ANDROID_BITMAP_FORMAT_RGB_565) {
        LOG_D("Only support ANDROID_BITMAP_FORMAT_RGBA_8888 and ANDROID_BITMAP_FORMAT_RGB_565");
        return;
    }

    // Lock all images
    if (AndroidBitmap_lockPixels(env, srcbmp, &pixels) != ANDROID_BITMAP_RESULT_SUCCESS) {
        LOG_D("AndroidBitmap_lockPixels failed!");
        return;
    }
    // height width
    int h = infoIn.height;
    int w = infoIn.width;

    // Start
    if (infoIn.format == ANDROID_BITMAP_FORMAT_RGBA_8888) {
        pixels = blur_ARGB_8888((int *) pixels, w, h, radius);
    } else if (infoIn.format == ANDROID_BITMAP_FORMAT_RGB_565) {
        pixels = blur_RGB_565((short *) pixels, w, h, radius);
    }

    // End
    // Unlocks everything
    AndroidBitmap_unlockPixels(env, srcbmp);
}