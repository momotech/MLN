package com.immomo.mmui.weight;

import android.view.View;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 * 帮助View绘制阴影
 */
public interface IShadowHelper extends IShadow {

    /**
     * 绘制阴影
     */
    void applyShadow(View v);

    void revert(View v);
}
