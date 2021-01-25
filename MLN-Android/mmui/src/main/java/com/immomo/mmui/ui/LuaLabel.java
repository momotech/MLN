/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.MotionEvent;

import com.immomo.mls.fun.constants.TextAlign;
import com.immomo.mls.fun.weight.BorderRadiusTextView;
import com.immomo.mls.fun.weight.ILimitSizeView;
import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ud.UDLabel;

import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaLabel<U extends UDLabel> extends BorderRadiusTextView implements ILView<UDLabel>, ILimitSizeView {

    private UDLabel udLabel;
    private ILView.ViewLifeCycleCallback cycleCallback;

    public LuaLabel(Context context, U metaTable) {
        super(context);
        this.udLabel = metaTable;
        setViewLifeCycleCallback(udLabel);
        setGravity(TextAlign.LEFT);//默认竖直居中
        setSingleLine();
        setTextSize(14);
        setTextColor(Color.BLACK);
        setEllipsize(TextUtils.TruncateAt.END);
//        setIncludeFontPadding(false);
    }


    //<editor-fold desc="ILView">
    public UDLabel getUserdata() {
        return udLabel;
    }

   /* @Override
    public Class<UDLabel> getUserDataClass() {
        return UDLabel.class;
    }*/

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
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
    //</editor-fold>

    @Override
    protected void onDraw(Canvas canvas) {
        try {
            super.onDraw(canvas);
        } catch (final Throwable t) {
            LogUtil.e(t, "draw text error: " + getText());
        }
    }

    /**
     * 重写使view在线性布局中，从左上角开始布局
     *
     * @return
     */
    @Override
    public int getBaseline() {
        return -1;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return isEnabled() && super.dispatchTouchEvent(ev);
    }

    @Override
    public void setMinWidth(int minPixels) {
        super.setMinWidth(minPixels);
        setMinimumWidth(minPixels);
    }

    @Override
    public void setMinHeight(int minPixels) {
        super.setMinHeight(minPixels);
        setMinimumHeight(minPixels);
    }
}