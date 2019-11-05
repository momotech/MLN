/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.graphics.Color;

/**
 * Created by Xiong.Fangyu on 2019/4/24
 */
public class ColorUtils {

    private static final String COLOR_PATTERN_WRAP = "rgb(";
    private static final String COLOR_PATTERN_WRAP_A = "rgba(";

    private static boolean isAndroidColor(String s) {
        return s.charAt(0) == '#';
    }

    /**
     * 解析 "RGBA"类型颜色
     * 如："#ffffffff" 后两个ff是Alpha通道
     *
     * @param colorString
     * @return
     */
    private static int parseRGBAString(String colorString) {
        StringBuilder builder;
        if (colorString.charAt(0) == '#') {
            builder = new StringBuilder();
            if (colorString.length() == 9) {
                builder.append(colorString, 0, 1);
                builder.append(colorString, 7, 9);
                builder.append(colorString, 1, 7);
            } else if (colorString.length() == 7) {
                builder.append(colorString, 0, 1);
                builder.append(colorString, 1, 7);
            } else {
                return Color.parseColor(colorString);
            }
        } else {
            return Color.parseColor(colorString);
        }
        return Color.parseColor(builder.toString());
    }

    public static int setColorString(String colorStr) {
        if (colorStr == null || colorStr.length() == 0) {
            throw new IllegalArgumentException("Color string is empty!");
        }
        colorStr = colorStr.trim().toLowerCase();
        if (isAndroidColor(colorStr)) {
            return parseRGBAString(colorStr);
        } else if (colorStr.startsWith(COLOR_PATTERN_WRAP) && colorStr.endsWith(")")) {
            colorStr = colorStr.substring(4, colorStr.length() - 1);
            String[] rgb = colorStr.split(",");
            if (rgb.length != 3) {
                throw new IllegalArgumentException("rgb Color must have 3 value. eg: rgb(255,255,255) is white color");
            }
            int r, g, b;
            try {
                r = Integer.valueOf(rgb[0].trim());
                g = Integer.valueOf(rgb[1].trim());
                b = Integer.valueOf(rgb[2].trim());
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("parse color number failed", e);
            }
            if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
                throw new IllegalArgumentException("rgb value must be in [0, 255]");
            }

            return 0xff000000 | (r << 16) | (g << 8) | b;
        }
        if (colorStr.startsWith(COLOR_PATTERN_WRAP_A) && colorStr.endsWith(")")) {
            colorStr = colorStr.substring(5, colorStr.length() - 1);
            String[] argb = colorStr.split(",");
            if (argb.length != 4) {
                throw new IllegalArgumentException("rgba Color must have 4 value. eg: rgba(255,255,255, 1) is white color");
            }
            int r, g, b, a;
            try {
                a = (int) (Float.valueOf(argb[3]) * 255);
                r = Integer.valueOf(argb[0].trim());
                g = Integer.valueOf(argb[1].trim());
                b = Integer.valueOf(argb[2].trim());
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("parse color number failed", e);
            }
            if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255) {
                throw new IllegalArgumentException("rgb value must be in [0, 255]");
            }
            return (a << 24) | (r << 16) | (g << 8) | b;
        } else {
            throw new IllegalArgumentException("Unknown color");
        }
    }

    /**
     * 转换为android的颜色表达方式#argb
     */
    public static String toHexColorString(int color) {
        final StringBuilder sb = new StringBuilder("#");
        for (int i = 3; i >= 0; i --) {
            int c = (color >>> (i << 3)) & 0xff;
            if (c < 0x10) {
                sb.append('0');
            }
            sb.append(Integer.toHexString(c));
        }
        return sb.toString();
    }

    public static String toRGBAColorString(int color) {
        final StringBuilder sb = new StringBuilder(COLOR_PATTERN_WRAP_A);
        for (int i = 2; i >= 0; i --) {
            int c = (color >>> (i << 3)) & 0xff;
            sb.append(c).append(',');
        }
        int a = (color >>> 24) & 0xff;
        if (a == 0)
            sb.append(0);
        else if (a == 255)
            sb.append(1);
        else
            sb.append(a / 255f);
        return sb.append(')').toString();
    }

    /**
     * 计算动画使用
     */
    public static int evaluate(float fraction, int startInt, int endInt) {
        float startA = ((startInt >> 24) & 0xff) / 255.0f;
        float startR = ((startInt >> 16) & 0xff) / 255.0f;
        float startG = ((startInt >>  8) & 0xff) / 255.0f;
        float startB = ( startInt        & 0xff) / 255.0f;

        float endA = ((endInt >> 24) & 0xff) / 255.0f;
        float endR = ((endInt >> 16) & 0xff) / 255.0f;
        float endG = ((endInt >>  8) & 0xff) / 255.0f;
        float endB = ( endInt        & 0xff) / 255.0f;

        // convert from sRGB to linear
        startR = (float) Math.pow(startR, 2.2);
        startG = (float) Math.pow(startG, 2.2);
        startB = (float) Math.pow(startB, 2.2);

        endR = (float) Math.pow(endR, 2.2);
        endG = (float) Math.pow(endG, 2.2);
        endB = (float) Math.pow(endB, 2.2);

        // compute the interpolated color in linear space
        float a = startA + fraction * (endA - startA);
        float r = startR + fraction * (endR - startR);
        float g = startG + fraction * (endG - startG);
        float b = startB + fraction * (endB - startB);

        // convert back to sRGB in the [0..255] range
        a = a * 255.0f;
        r = (float) Math.pow(r, 1.0 / 2.2) * 255.0f;
        g = (float) Math.pow(g, 1.0 / 2.2) * 255.0f;
        b = (float) Math.pow(b, 1.0 / 2.2) * 255.0f;

        return Math.round(a) << 24 | Math.round(r) << 16 | Math.round(g) << 8 | Math.round(b);
    }
}