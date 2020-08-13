/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.MotionEvent;
import android.widget.EditText;

import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.IBorderRadiusView;
import com.immomo.mls.fun.ud.view.IClipRadius;
import com.immomo.mls.fun.ud.view.IShowKeyboard;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.ViewClipHelper;
import com.immomo.mls.utils.ViewShadowHelper;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@SuppressLint("AppCompatCustomView")
public class BorderRadiusEditText extends EditText implements IBorderRadiusView, IClipRadius, ViewClipHelper.SuperDrawAction, IShowKeyboard {
    private final  @NonNull
    BorderBackgroundEditTextDrawable backgroundDrawable;
    private final @NonNull
    ViewClipHelper viewClipHelper;
    private final @NonNull
    ViewShadowHelper viewShadowHelper;

    public BorderRadiusEditText(Context context) {
        super(context);
        backgroundDrawable = new BorderBackgroundEditTextDrawable();
        viewClipHelper = new ViewClipHelper(this);
        viewShadowHelper = new ViewShadowHelper();
    }

    //<editor-fold desc="IBorderRadiusView">
    @Override
    public void setBgColor(int color) {
        backgroundDrawable.setBgColor(color);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public void setBgDrawable(Drawable drawable) {
        backgroundDrawable.setBgDrawable(drawable);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public int getBgColor() {
        return backgroundDrawable.getBgColor();
    }

    @Override
    public void setGradientColor(int start, int end, int type) {
        backgroundDrawable.setGradientColor(start, end, type);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public void setRadiusColor(int color) {
        viewClipHelper.setRadiusColor(color);
    }

    @Override
    public void setAddShadow(int color, Size offset, float shadowRadius, float alpha) {
        if (Build.VERSION.SDK_INT >= 21) {
            // 这个是加外边框，通过 setRoundRect 添加
            viewShadowHelper.setShadowData(color, offset, shadowRadius, alpha);
            viewShadowHelper.setOutlineProvider(this);
        }
    }

    @Override
    public void setDrawRadiusBackground(boolean draw) {
        viewClipHelper.setDrawRadiusBackground(draw);
//        backgroundDrawable.setDrawRadiusBackground(draw);
    }

    @Override
    public void setStrokeWidth(float width) {
        backgroundDrawable.setStrokeWidth(width);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public void setStrokeColor(int color) {
        backgroundDrawable.setStrokeColor(color);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public void setCornerRadius(float radius) {
        backgroundDrawable.setCornerRadius(radius);
        LuaViewUtil.setBackground(this, backgroundDrawable);
        viewClipHelper.setRadius(radius);
        viewShadowHelper.setRadius(radius);
        viewShadowHelper.setError(false);
        viewClipHelper.setCornerType(TYPE_CORNER_RADIUS);
    }

    @Override
    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        backgroundDrawable.setRadius(topLeft, topRight, bottomLeft, bottomRight);
        LuaViewUtil.setBackground(this, backgroundDrawable);
        viewClipHelper.setRadius(topLeft, topRight, bottomLeft, bottomRight);
        viewClipHelper.setCornerType(TYPE_CORNER_RADIUS);
    }

    @Override
    public void setRadius(int direction, float radius) {
        backgroundDrawable.setRadius(direction, radius);
        LuaViewUtil.setBackground(this, backgroundDrawable);
        viewClipHelper.setRadius(backgroundDrawable);
        viewClipHelper.setCornerType(TYPE_CORNER_DIRECTION);
        viewShadowHelper.setError(true);//阴影禁止和setCornerRadiusWithDirection()连用
    }

    @Override
    public void setMaskRadius(int direction, float radius) {
        backgroundDrawable.setMaskRadius(direction, radius);
        LuaViewUtil.setBackground(this, backgroundDrawable);
        viewClipHelper.setRadius(backgroundDrawable);
        viewShadowHelper.setError(false);//阴影可以和addCornerMask()连用
    }

    @Override
    public void initCornerManager(boolean open) {
        viewClipHelper.openDefaultClip(open);
    }

    @Override
    public void forceClipLevel(int clipLevel) {
        viewClipHelper.setForceClipLevel(clipLevel);
    }

    @Override
    public float getStrokeWidth() {
        return backgroundDrawable.getStrokeWidth();
    }

    @Override
    public int getStrokeColor() {
        return backgroundDrawable.getStrokeColor();
    }

    @Override
    public float getCornerRadiusWithDirection(int direction) {
        return backgroundDrawable.getCornerRadiusWithDirection(direction);
    }

    @Override
    public float getRadius(int direction) {
        return backgroundDrawable.getRadius(direction);
    }

    @Override
    public float[] getRadii() {
        return backgroundDrawable.getRadii();
    }

    @Override
    public void drawBorder(Canvas canvas) {
        backgroundDrawable.drawBorder(canvas);
    }
//</editor-fold>

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        viewClipHelper.updatePath(w, h, backgroundDrawable.getStrokeWidth());
    }

    @Override
    public void draw(Canvas canvas) {
        if (viewClipHelper.needClicp()) {
            viewClipHelper.clip(canvas, this, false);
        } else {
            super.draw(canvas);
        }
        drawBorder(canvas);
    }

    @Override
    public void innerDraw(Canvas canvas) {
        super.draw(canvas);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (isEnabled())
            backgroundDrawable.onRippleTouchEvent(event);
        return super.onTouchEvent(event);
    }

    @Override
    public void setDrawRipple(boolean drawRipple) {
        if (drawRipple)
            setClickable(true);
        backgroundDrawable.setDrawRipple(drawRipple);
        LuaViewUtil.setBackground(this, backgroundDrawable);
    }

    @Override
    public boolean showKeyboard() {
        return true;
    }
}