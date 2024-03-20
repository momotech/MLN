package com.immomo.mmui.ud.anim;

import android.view.View;

import com.immomo.mmui.TouchableView;

import org.luaj.vm2.Globals;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by Xiong.Fangyu on 2020/10/27
 */
public abstract class BaseGestureBehavior extends PercentBehavior implements IGestureBehavior, View.OnTouchListener {
    /**
     * 截止距离
     */
    protected float endDistance;
    /**
     * 交互是否可被触发
     */
    protected boolean enable;
    /**
     * targetView是否跟随手势,可用来实现跟手
     */
    protected boolean followEnable;
    /**
     * function(TouchType type,number distance,numer velocity)
     */
    protected InteractiveBehaviorCallback callback;
    /**
     * 手势view
     */
    protected TouchableView touchableView;

    protected float lastPercent = 0;

    protected Set<PercentBehavior> innerPercentBehaviors = new HashSet<>();

    @Override
    public float getMax() {
        return endDistance;
    }

    @Override
    public void setOverBoundary(boolean overBoundary) {
        this.overBoundary = overBoundary;
    }

    @Override
    public boolean isOverBoundary() {
        return this.overBoundary;
    }

    @Override
    public void setEnable(boolean enable) {
        this.enable = enable;
    }

    @Override
    public boolean isEnable() {
        return this.enable;
    }

    @Override
    public void setFollowEnable(boolean followEnable) {
        this.followEnable = followEnable;
    }

    @Override
    public boolean isFollowEnable() {
        return this.followEnable;
    }

    @Override
    public void setTouchBlock(Globals g, long f) {
        if (f == 0)
            callback = null;
        else
            callback = new InteractiveBehaviorCallback(g.getL_State(), f);
    }

    @Override
    public void setTargetView(TouchableView view) {
        if (touchableView != null) {
            touchableView.removeOnTouchListener(this);
        }
        this.touchableView = view;
        view.addOnTouchListener(this);
    }

    @Override
    public void setMax(float endDistance) {
        this.endDistance = endDistance;
        if (!Float.isNaN(minPercent)) {
            minDistance = (float) (minPercent * endDistance);
        }
        if (!Float.isNaN(maxPercent)) {
            maxDistance = (float) (maxPercent * endDistance);
        }
    }

    @Override
    public void setAnimation(UDBaseAnimation oa) {
        super.setAnimation(oa);
        innerPercentBehaviors.add(oa.getPercentBehavior());
        if (endDistance != 0) {
            setMax(endDistance);
        }
    }

    @Override
    public void update(float percent) {
        lastPercent = percent;
        for (PercentBehavior pb : innerPercentBehaviors) {
            pb.update(percent);
        }
    }

    @Override
    public void clearAnim() {
        innerPercentBehaviors.clear();
    }

    @Override
    public void clear() {
        super.clear();
        if (touchableView != null)
            touchableView.removeOnTouchListener(this);
        touchableView = null;
        if (callback != null)
            callback.destroy();
        callback = null;
        innerPercentBehaviors.clear();
    }
}
