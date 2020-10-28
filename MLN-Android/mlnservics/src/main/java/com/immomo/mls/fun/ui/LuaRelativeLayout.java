/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.ud.view.UDRelativeLayout;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.weight.BorderRadiusRelativeLayout;
import com.immomo.mls.util.LuaViewUtil;

import org.luaj.vm2.LuaValue;

import androidx.annotation.NonNull;

public class LuaRelativeLayout<U extends UDRelativeLayout> extends BorderRadiusRelativeLayout implements ILViewGroup<U> {
    protected U userdata;
    private ViewLifeCycleCallback cycleCallback;

    public LuaRelativeLayout(Context context, U userdata) {
        super(context);
        this.userdata = userdata;
        setViewLifeCycleCallback(userdata);
    }

    @Override
    public void bringSubviewToFront(UDView child) {

    }

    @Override
    public void sendSubviewToBack(UDView child) {

    }

    public void alignParentDependsRules(UDView sourceUDView, int rule) {

        View sourceView = sourceUDView.getView();

        ViewGroup.LayoutParams sourceViewLayoutParams = sourceView.getLayoutParams();

        if (this instanceof ILViewGroup) {
            ILViewGroup g = (ILViewGroup) this;
            sourceViewLayoutParams = g.applyLayoutParams(sourceViewLayoutParams,
                    sourceUDView.udLayoutParams);
        }

        ((RelativeLayout.LayoutParams) sourceViewLayoutParams).addRule(rule);
        addView(LuaViewUtil.removeFromParent(sourceView), sourceViewLayoutParams);
    }

    public void leftTopRightBottom(UDView sourceUDView, UDView relativeUDView, int rules) {

        View sourceView = sourceUDView.getView();
        View relativeView = relativeUDView.getView();
        if (relativeView == null)
            return;

        ViewGroup.LayoutParams relativeViewLayoutParams = relativeView.getLayoutParams();
        ViewGroup.LayoutParams sourceViewLayoutParams = sourceView.getLayoutParams();

        if (this instanceof ILViewGroup) {
            ILViewGroup g = (ILViewGroup) this;
            relativeViewLayoutParams = g.applyLayoutParams(relativeViewLayoutParams,
                    relativeUDView.udLayoutParams);

            sourceViewLayoutParams = g.applyLayoutParams(sourceViewLayoutParams,
                    sourceUDView.udLayoutParams);
        }

        LuaViewUtil.setId(sourceView);
        addView(LuaViewUtil.removeFromParent(sourceView), sourceViewLayoutParams);
        sourceView.setLayoutParams(sourceViewLayoutParams);

        ((RelativeLayout.LayoutParams) relativeViewLayoutParams).addRule(rules, sourceView.getId());
        relativeView.setLayoutParams(relativeViewLayoutParams);

        addView(LuaViewUtil.removeFromParent(relativeView), relativeViewLayoutParams);
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        LayoutParams ret = parseLayoutParams(src);
        ret.setMargins(udLayoutParams.realMarginLeft, udLayoutParams.realMarginTop, udLayoutParams.realMarginRight, udLayoutParams.realMarginBottom);
        return ret;
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return src;
    }

    @Override
    public U getUserdata() {
        return userdata;
    }

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        getUserdata().measureOverLayout(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        getUserdata().layoutOverLayout(left, top, right, bottom);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        getUserdata().drawOverLayout(canvas);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }
    }

    private LayoutParams parseLayoutParams(ViewGroup.LayoutParams src) {
        if (src == null) {
            src = generateNewWrapContentLayoutParams();
        } else if (!(src instanceof LayoutParams)) {
            if (src instanceof MarginLayoutParams) {
                src = generateNewLayoutParams((MarginLayoutParams) src);
            } else {
                src = generateNewLayoutParams(src);
            }
        }
        return (LayoutParams) src;
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewWrapContentLayoutParams() {
        return new LuaRelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewLayoutParams(MarginLayoutParams src) {
        return new LayoutParams(src);
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewLayoutParams(ViewGroup.LayoutParams src) {
        return new LayoutParams(src);
    }
}