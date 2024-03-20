package com.immomo.mmui.weight;

import android.view.MotionEvent;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 */
public interface IBackgroundDrawable extends IBackground {

    void onRippleTouchEvent(MotionEvent event);
}
