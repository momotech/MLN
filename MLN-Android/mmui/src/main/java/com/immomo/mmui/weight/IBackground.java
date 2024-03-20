package com.immomo.mmui.weight;

import android.graphics.drawable.Drawable;

import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.constants.RectCorner;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 *
 * 处理背景
 * 可绘制纯色、渐变色、或其他图片
 * 支持涟漪效果
 */
public interface IBackground {
    void setBackgroundRadius(float r);
    void setBackgroundRadius(float topLeft,
                             float topRight,
                             float bottomLeft,
                             float bottomRight);
    void setBackgroundRadius(@RectCorner.Direction int direction, float radius);

    float getBackgroundRadius(@RectCorner.Direction int direction);

    void setBackgroundColor(int color);

    int getBackgroundColor();

    void setBGDrawable(Drawable d);

    void setGradientColor(int start, int end, @GradientType.Type int type);

    void setDrawRipple(boolean drawRipple);
}
