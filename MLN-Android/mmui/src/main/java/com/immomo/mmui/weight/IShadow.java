package com.immomo.mmui.weight;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 * 阴影，支持圆角
 */
public interface IShadow {
    /**
     * 设置shadow参数
     * @param color 阴影颜色
     * @param w 阴影宽
     * @param h 阴影高
     * @param shadowRadius 阴影模糊度
     * @param alpha 阴影透明度
     */
    void setShadow(int color,
                   int w, int h,
                   float shadowRadius,
                   float alpha);

    /**
     * @param roundRadius 阴影圆角弧度
     */
    void setRoundRadiusForShadow(float roundRadius);
}
