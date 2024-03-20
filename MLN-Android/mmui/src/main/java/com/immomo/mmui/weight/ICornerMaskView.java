package com.immomo.mmui.weight;

import com.immomo.mls.fun.constants.RectCorner;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 * 可绘制圆角的view
 */
public interface ICornerMaskView {

    void setMaskRadius(@RectCorner.Direction int direction, float radius);

    /**
     * 设置圆角的颜色
     */
    void setMaskColor(int color);
}
