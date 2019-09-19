/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight.load;

import android.content.Context;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;

/**
 * Created by XiongFangyu on 2018/6/21.
 */
public class DefaultLoadView extends View implements ILoadView {

    private Animation anim;
    private boolean visible = false;
    private boolean attached = false;
    private boolean startedAnim = false;

    public DefaultLoadView(Context context) {
        this(context, null);
    }

    public DefaultLoadView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DefaultLoadView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        visible = true;
        attached = false;
        startedAnim = false;
    }

    @Override
    public void startAnim() {
        startedAnim = true;
        checkAnim();
    }

    @Override
    public void stopAnim() {
        startedAnim = false;
        checkAnim();
    }

    @Override
    public void showLoadAnimView() {
        setVisibility(VISIBLE);
        startAnim();
    }

    @Override
    public void hideLoadAnimView() {
        setVisibility(GONE);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        attached = false;
        checkAnim();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        attached = true;
        checkAnim();
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        visible = visibility == VISIBLE;
        checkAnim();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    private void initAnim() {
        if (anim == null) {
            RotateAnimation rotateAnimation = new RotateAnimation(
                    0, 359,
                    Animation.RELATIVE_TO_SELF, 0.5f,
                    Animation.RELATIVE_TO_SELF, 0.5f
            );
            rotateAnimation.setDuration(800);
            rotateAnimation.setInterpolator(new LinearInterpolator());
            rotateAnimation.setRepeatCount(Animation.INFINITE);
            rotateAnimation.setRepeatMode(Animation.RESTART);
            anim = rotateAnimation;
        }
    }

    private void checkAnim() {
        if (startedAnim && visible && attached) {
            initAnim();
            clearAnimation();
            startAnimation(anim);
        } else {
            clearAnimation();
        }
    }
}