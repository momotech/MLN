/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

/**
 * Created by XiongFangyu on 2018/6/28.
 */
public class RefreshView extends CircleImageView {
    private static final int CIRCLE_BG_LIGHT = 0xFFFAFAFA;
    private static final int SCHEME_COLOR = 0xff3462ff;

    private float offsetY = 0f;
    private float refreshY = 0f;
    private long progressAnimDuration = 300;

    private MaterialProgressDrawable mProgress;

    private ValueAnimator progressAnim;

    public RefreshView(ViewGroup parent) {
        this(parent.getContext());
        setLayoutParams(generateLayoutParams(parent));
    }

    public RefreshView(Context context) {
        super(context, CIRCLE_BG_LIGHT);
        init(context);
    }

    private void init(Context context) {
        mProgress = new MaterialProgressDrawable(context, this);
        mProgress.setArrowScale(1f);
        mProgress.showArrow(true);
        mProgress.setColorSchemeColors(SCHEME_COLOR);
        mProgress.setAlpha(255);
        setImageDrawable(mProgress);
    }

    public void showArrow(boolean show) {
        mProgress.showArrow(show);
    }

    public void setProgressRotation(float rotation) {
        mProgress.setProgressRotation(rotation);
    }

    public void stopAnimation() {
        mProgress.stop();
    }

    public void setStartEndTrim(float startAngle, float endAngle) {
        mProgress.setStartEndTrim(startAngle, endAngle);
    }

    public void startAnimation() {
        showArrow(false);
        mProgress.start();
    }

    public void setProgressColor(int color) {
        mProgress.setColorSchemeColors(color);
    }

    public void setProgressBgColor(int color) {
        setBackgroundColor(color);
    }

    public void setOffsetY(float dy) {
        offsetY = dy;
        if (offsetY < 0) {
            offsetY = 0;
        }
        setTranslationY(offsetY);
        if (refreshY > 0) {
            float p = offsetY / refreshY;
            if (p > 1) {
                p = 1;
            }
            setAlpha(p);
            setScaleX(p);
            setScaleY(p);
        }
    }

    public void fadeOut(float dy) {
        offsetY = dy;
        if (offsetY < 0) {
            offsetY = 0;
        }

        if (refreshY > 0) {
            float p = offsetY / refreshY;
            if (p > 1) {
                p = 1;
            }
            setAlpha(p);
            setScaleX(p);
            setScaleY(p);
        }
    }

    public float getOffsetY() {
        return offsetY;
    }

    public void setRefreshOffsetY(float refreshY) {
        this.refreshY = refreshY;
    }

    public void removeProgress(boolean anim) {
        if (!anim) {
            setVisibility(View.GONE);
            stopAnimation();
            removeByParent();
        } else {
            if (progressAnim != null && progressAnim.isRunning()) {
                return;
            }
            if (getVisibility() != VISIBLE) {
                removeByParent();
                return;
            }
            initProgressAnim();
            progressAnim.start();
        }
    }

    private void endProgressAnim() {
        if (progressAnim != null && progressAnim.isRunning()) {
            progressAnim.cancel();
        }
    }

    public void addProgressInContainer(ViewGroup parent) {
        endProgressAnim();
        if (parent != null && getParent() == null) {
            parent.addView(this);
        }
        setVisibility(View.VISIBLE);
        startAnimation();
        setOffsetY(refreshY);
    }

    public ViewGroup.LayoutParams generateLayoutParams(ViewGroup parent) {
        if (parent instanceof FrameLayout) {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.gravity = Gravity.CENTER_HORIZONTAL;
            return params;
        } else if (parent instanceof RelativeLayout) {
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.addRule(RelativeLayout.CENTER_HORIZONTAL);
            return params;
        }
        return new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    public void setProgressAnimDuration(long d) {
        progressAnimDuration = d;
    }

    private void initProgressAnim() {
        if (progressAnim == null) {
            ValueAnimator anim = ValueAnimator.ofFloat(refreshY, 0).setDuration(progressAnimDuration);
            anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    float v = (float) animation.getAnimatedValue();
                    fadeOut(v);
                }
            });
            anim.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    setVisibility(View.GONE);
                    stopAnimation();
                    removeByParent();
                }
            });
            progressAnim = anim;
        }
    }

    private void removeByParent() {
        if (getParent() instanceof ViewGroup) {
            ((ViewGroup) getParent()).removeView(RefreshView.this);
        }
    }
}