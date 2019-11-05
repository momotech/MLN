/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.graphics.drawable.Drawable;

import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.other.Size;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public interface IBorderRadiusView extends IBorderRadius, IRippleView, GradientType {

    void setBgColor(int color);

    void setBgDrawable(Drawable drawable);

    void setDrawRadiusBackground(boolean draw);

    int getBgColor();

    void setGradientColor(int start, int end, int type);

    void setRadiusColor(int color);

    void setAddShadow(int color, Size offset, float shadowRadius, float alpha);
}