/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.utils;

import android.graphics.Color;

import androidx.annotation.ColorInt;

public class ColorUtil {
    private ColorUtil() {
        throw new IllegalStateException("Utility class :ColorUtil");
    }

    public static float[] colorToArray(int color) {

        float[] floats = new float[4];

        floats[0] = (float) Color.alpha(color);
        floats[1] = (float) Color.red(color);
        floats[2] = (float) Color.green(color);
        floats[3] = (float) Color.blue(color);

        return floats;
    }

    public static void colorToArray(float[] floats, int color) {
        floats[0] = (float) Color.alpha(color);
        floats[1] = (float) Color.red(color);
        floats[2] = (float) Color.green(color);
        floats[3] = (float) Color.blue(color);
    }


    /**
     * Return a color-int from alpha, red, green, blue float components
     * in the range \([0..1]\). If the components are out of range, the
     * returned color is undefined.
     *
     * @param alpha Alpha component \([0..1]\) of the color
     * @param red   Red component \([0..1]\) of the color
     * @param green Green component \([0..1]\) of the color
     * @param blue  Blue component \([0..1]\) of the color
     */
    @ColorInt
    public static int argb(float alpha, float red, float green, float blue) {
        return ((int) (alpha * 255.0f + 0.5f) << 24) |
                ((int) (red * 255.0f + 0.5f) << 16) |
                ((int) (green * 255.0f + 0.5f) << 8) |
                (int) (blue * 255.0f + 0.5f);
    }

}