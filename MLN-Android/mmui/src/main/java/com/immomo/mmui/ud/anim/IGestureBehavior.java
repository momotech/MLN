package com.immomo.mmui.ud.anim;

import com.immomo.mmui.TouchableView;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2020/10/27
 */
public interface IGestureBehavior {
    void setMax(float dis);

    float getMax();

    void setOverBoundary(boolean overBoundary);

    boolean isOverBoundary();

    void setEnable(boolean enable);

    boolean isEnable();

    void setFollowEnable(boolean followEnable);

    boolean isFollowEnable();

    void setTouchBlock(Globals g, long f);

    void setTargetView(TouchableView view);

    void clearAnim();
}
