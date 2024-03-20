package com.immomo.mmui.weight;

import com.immomo.mls.fun.constants.RectCorner;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 *
 * 可切割圆角
 */
public interface Clippable {
    void setClipRadius(float r);
    void setClipRadius(float topLeft,
                       float topRight,
                       float bottomLeft,
                       float bottomRight);
    void setClipRadius(@RectCorner.Direction int direction, float radius);

    float getClipRadius(@RectCorner.Direction int direction);
    float[] getClipRadii();
}
