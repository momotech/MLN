/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;

import android.graphics.Color;

/**
 * Description: UDColor 对应的javaUserData
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-15 15:39
 */
public class MMUIColor {
    private int color;

    public MMUIColor(int color) {
        this.color = color;
    }

    public static MMUIColor getColor(int color) {
        MMUIColor mmuiColor = new MMUIColor(color);
        return mmuiColor;
    }

    public int getColor() {
        return color;
    }

    public void setColor(int color) {
        this.color = color;
    }

    public void setAlpha(int a) {
        color = Color.argb(a, Color.red(color), Color.green(color), Color.blue(color));
    }

    public void setRed(int a) {
        color = Color.argb(Color.alpha(color), a, Color.green(color), Color.blue(color));
    }

    public void setGreen(int a) {
        color = Color.argb(Color.alpha(color), Color.red(color), a, Color.blue(color));
    }

    public void setBlue(int a) {
        color = Color.argb(Color.alpha(color), Color.red(color), Color.green(color), a);
    }

    public int getAlpha() {
        return (color == 0) ? 255 : Color.alpha(color);
    }

    public int getRed() {
        return Color.red(color);
    }

    public int getGreen() {
        return Color.green(color);
    }

    public int getBlue() {
        return Color.blue(color);
    }
}