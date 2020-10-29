/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;


import android.content.Context;

import com.immomo.mls.fun.constants.MeasurementType;

import org.luaj.vm2.LuaValue;

/**
 * Dimension
 *
 * @author song
 */
public class DimenUtil {
    public static float sScale = -1;
    public static float spScale = -1;
    public static int WRAP_CONTENT;
    public static int MATCH_PARENT;
    private static long lastUpdateTime;

    public static void init(Context context) {
        sScale = AndroidUtil.getDensity(context);
        spScale = AndroidUtil.getScaleDensity(context);
        WRAP_CONTENT = (int) (MeasurementType.WRAP_CONTENT * sScale + 0.5f);
        MATCH_PARENT = (int) (MeasurementType.MATCH_PARENT * sScale + 0.5f);
        lastUpdateTime = System.currentTimeMillis();
    }

    public static void updateScale(Context context) {
        /// 100ms内重复设置无效
        if (System.currentTimeMillis() - lastUpdateTime <= 100)
            return;
        init(context);
    }

    public static boolean isWrapContent(int scaleSize) {
        return scaleSize == WRAP_CONTENT;
    }

    public static boolean isMatchParent(int scaleSize) {
        return scaleSize == MATCH_PARENT;
    }

    public static int check(int scaleSize) {
        if (scaleSize == WRAP_CONTENT)
            return MeasurementType.WRAP_CONTENT;
        if (scaleSize == MATCH_PARENT)
            return MeasurementType.MATCH_PARENT;
        return scaleSize;
    }

    /**
     * convert a value to px，返回给Android系统的必须是整数
     *
     * @param value
     * @return
     */
    public static int dpiToPx(LuaValue value) {
        if (value != null && value.isNumber()) {
            return (int) (value.toDouble() * sScale + 0.5f);//向上取整数
        }
        return 0;
    }

    /**
     * convert a value to px，返回给Android系统的必须是整数
     * 支持NAN类型，给Flex新布局使用
     * @param value
     * @return
     */
    public static float dpiToPxWithNaN(LuaValue value) {
        if (value != null && value.isNumber()) {
            if(Float.isNaN(value.toFloat())){
                return value.toFloat();
            }
            return (int) (value.toFloat() * sScale + 0.5f);//向上取整数
        }
        return 0;
    }

    /**
     * convert a value to px，返回给Android系统的必须是整数
     *
     * @param value
     * @return
     */
    public static int dpiToPx(LuaValue value, int defaultValue) {
        if (value != null && value.isNumber()) {
            return (int) (value.toDouble() * sScale + 0.5f);//向上取整数
        }
        return defaultValue;
    }

    public static Integer dpiToPx(LuaValue value, Integer defaultValue) {
        if (value != null && value.isNumber()) {
            return (int) (value.toDouble() * sScale + 0.5f);//向上取整数
        }
        return defaultValue;
    }


    /**
     * convert dpi to px，返回给Android系统的必须是整数
     *
     * @param dpi
     * @return
     */
    public static int dpiToPx(float dpi) {
        return (int) (dpi * sScale);
    }

    public static int dpiToPx(double dpi) {
        return (int) (dpi * sScale + 0.5);
    }

    /**
     * 支持NAN类型，给Flex新布局使用
     */
    public static float dpiToPxWithNaN(float dpi) {
        if (Float.isNaN(dpi)) {
            return dpi;
        }
        return (int) (dpi * sScale);
    }

    /**
     * convert px to dpi ，返回给Lua层的调用，必须是浮点数
     *
     * @param px
     * @return
     */
    public static float pxToDpi(float px) {
        return px / sScale;
    }

    /**
     * 将sp值转换为px值，保证文字大小不变，给Android系统整数
     *
     * @param spValue（DisplayMetrics类中属性scaledDensity）
     * @return
     */
    public static int spToPx(float spValue) {
        return (int) (spValue * spScale);
    }

    /**
     * 将px转成sp值，返回给Lua层的调用，必须是浮点数
     *
     * @param pxValue
     * @return
     */
    public static float pxToSp(float pxValue) {
        return pxValue / spScale;
    }

}