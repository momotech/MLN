/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud;

import android.view.View;

import androidx.annotation.IntDef;

import com.immomo.mls.util.DimenUtil;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by Xiong.Fangyu on 2020-01-02
 */
public class MeasureMode {
    /**
     * 最大模式，当前'View'可设置的大小不可超过给定值
     */
    public static final int AT_MOST = 1;
    /**
     * 绝对模式，建议当前'View'大小为给定值
     */
    public static final int EXACTLY = 2;
    /**
     * 不指定模式，当前'View'大小可任意设置
     */
    public static final int UNSPECIFIED = 3;

    @IntDef({AT_MOST, EXACTLY, UNSPECIFIED})
    @Retention(RetentionPolicy.SOURCE)
    public @interface SizeMode {}

    public static int getMeasureSpecMode(@SizeMode int mode, double size) {
        int px = DimenUtil.dpiToPx(size);
        switch (mode) {
            case AT_MOST:
                return View.MeasureSpec.makeMeasureSpec(px, View.MeasureSpec.AT_MOST);
            case EXACTLY:
                return View.MeasureSpec.makeMeasureSpec(px, View.MeasureSpec.EXACTLY);
            default:
                return View.MeasureSpec.makeMeasureSpec(px, View.MeasureSpec.UNSPECIFIED);
        }
    }
}
