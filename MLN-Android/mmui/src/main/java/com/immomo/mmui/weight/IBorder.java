package com.immomo.mmui.weight;

import com.immomo.mls.fun.constants.RectCorner;

/**
 * Created by Xiong.Fangyu on 2020/11/3
 *
 * 处理边框
 */
public interface IBorder {

    void setCornerRadius(float radius);
    void setRadius(float topLeft,
                   float topRight,
                   float bottomLeft,
                   float bottomRight);
    void setRadius(@RectCorner.Direction int direction, float radius);

    float getRadius(@RectCorner.Direction int direction);
    float[] getRadii();

    void setStrokeWidth(float width);
    float getStrokeWidth();

    void setStrokeColor(int color);
    int getStrokeColor();
}
