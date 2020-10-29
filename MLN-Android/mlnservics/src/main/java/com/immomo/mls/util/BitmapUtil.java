/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

import com.immomo.mls.MLSEngine;

import java.io.ByteArrayOutputStream;

/**
 * 图片相关的jni操作
 * Project momodev
 * Package com.immomo.momo.util.jni
 * Created by tangyuchun on 11/11/16.
 */

public class BitmapUtil {

    /**
     * 生成一张高斯模糊的图片
     *
     * @param src
     * @param radius
     * @return
     */
    public static Bitmap blurBitmap(Bitmap src, int radius) {
        if (src == null || radius <= 1 || !MLSEngine.isLibInit(MLSEngine.BLUR_LIB)) {
            return src;
        }
        nativeBlurBitmap(src, radius);
        return src;
    }

    /**
     * 生成一张高斯模糊图片，通过scale缩放原图
     *
     * @param src
     * @param scale  缩放比例
     * @param radius
     * @return
     */
    public static Bitmap blurBitmap(Bitmap src, int scale, int radius) {
        if (scale <= 1)
            return blurBitmap(src, radius);
        final Bitmap result = Bitmap.createScaledBitmap(src, src.getWidth() / scale, src.getHeight() / scale, false);
        return blurBitmap(result, radius);
    }

    public static Bitmap rotateBitmap(Bitmap src, int rotate) {
        Matrix matrix = new Matrix();
        matrix.setRotate(rotate);
        return Bitmap.createBitmap(src, 0, 0, src.getWidth(), src.getHeight(), matrix, true);
    }

    public static int[] getBitmapInfo(String path) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, options);
        int[] result = new int[2];
        result[0] = options.outWidth;
        result[1] = options.outHeight;
        return result;
    }

    /**
     * 根据宽高等比缩放
     *
     * @param src
     * @param w
     * @param h
     * @return
     */
    public static Bitmap scaleBitmap(Bitmap src, int w, int h) {
        int width = src.getWidth();
        int height = src.getHeight();
        // 计算缩放比例
        float scaleWidth = ((float) w) / width;
        float scaleHeight = ((float) h) / height;
        if (scaleWidth > 1 && scaleHeight > 1) {
            return src;
        }
        float scale = scaleWidth > scaleHeight ? scaleHeight : scaleWidth;
        // 取得想要缩放的matrix参数
        Matrix matrix = new Matrix();
        matrix.postScale(scale, scale);
        // 得到新的图片
        return Bitmap.createBitmap(src, 0, 0, width, height, matrix,
                true);
    }

    public static int calculateInSampleSize(
            int width, int height, int reqWidth, int reqHeight) {
        // Raw height and width of image
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {

            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            // Calculate the largest inSampleSize value that is a power of 2 and keeps both
            // height and width larger than the requested height and width.
            while ((halfHeight / inSampleSize) >= reqHeight
                    && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }

        return inSampleSize;
    }

    /**
     * 更改bitmap透明度
     * @param srcBitmap
     * @param alpha 透明度[0~100], 0完全透明
     * @return
     */
    public static Bitmap generateAlphaBitmap(Bitmap srcBitmap, int alpha) {
        int[] argb = new int[srcBitmap.getWidth() * srcBitmap.getHeight()];
        srcBitmap.getPixels(argb, 0, srcBitmap.getWidth(), 0, 0, srcBitmap
                .getWidth(), srcBitmap.getHeight());// 获得图片的ARGB值
        alpha = alpha * 255 / 100;

        for (int i = 0; i < argb.length; i++) {
            argb[i] = (alpha << 24) | (argb[i] & 0x00FFFFFF);
        }

        srcBitmap = Bitmap.createBitmap(argb, srcBitmap.getWidth(), srcBitmap
                .getHeight(), Bitmap.Config.ARGB_8888);

        return srcBitmap;
    }

    public static Bitmap reSetBitmapConfig(Bitmap bitmap) {
        ByteArrayOutputStream dataByte = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, dataByte);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inPreferredConfig = Bitmap.Config.RGB_565;
        bitmap = BitmapFactory.decodeByteArray(dataByte.toByteArray(), 0, dataByte.size(), opts);
        return bitmap;
    }

    private static native void nativeBlurBitmap(Bitmap src, int radius);
}