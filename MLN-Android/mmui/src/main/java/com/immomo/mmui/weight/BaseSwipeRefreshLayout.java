package com.immomo.mmui.weight;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.view.MotionEvent;

import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.immomo.mls.fun.constants.RectCorner;
import com.immomo.mls.utils.RadiusDrawer;
import com.immomo.mmui.weight.impl.BackgroundDrawable;
import com.immomo.mmui.weight.impl.BorderDrawable;
import com.immomo.mmui.weight.impl.ClipHelper;
import com.immomo.mmui.weight.impl.ShadowHelper;

/**
 * Created by Xiong.Fangyu on 2020/11/12
 */
public class BaseSwipeRefreshLayout extends SwipeRefreshLayout
        implements IBorderView, IBackground, IShadowView, ICornerMaskView, IClippableView {
    /**
     * 绘制颜色背景、渐变色背景、图片背景
     * 支持圆角背景
     * 在背景中使用圆角，不影响view切割性质
     */
    private IBackgroundDrawable backgroundDrawable;
    /**
     * 绘制边框
     * 支持圆角，不影响view切割
     */
    private IBorder borderDrawable;
    /**
     * 绘制阴影
     * 支持圆角
     * 设置阴影不能使用切割功能
     */
    private IShadowHelper shadowImpl;
    /**
     * 绘制纯色圆角
     * 性能高
     * 局限性: 1、圆角只能为纯色，且需要和低层颜色一致
     *        2、圆角不能有透明度，低层颜色也不能有透明度
     * 不影响view切割
     */
    private RadiusDrawer radiusDrawer;
    /**
     * 是否使用绘制圆角的方式实现圆角
     */
    private boolean useRadiusDrawer;
    /**
     * 切割圆角
     * 无局限性
     * 性能比绘制圆角低
     * view将强制切割
     */
    private IClipHelper clipHelper;

    public BaseSwipeRefreshLayout(Context context) {
        super(context);
        useRadiusDrawer = false;
    }

    //<editor-fold desc="Border">
    @Override
    public void setStrokeWidth(float width) {
        if (borderDrawable == null)
            borderDrawable = new BorderDrawable();
        borderDrawable.setStrokeWidth(width);
    }

    @Override
    public float getStrokeWidth() {
        if (borderDrawable != null)
            return borderDrawable.getStrokeWidth();
        return 0;
    }

    @Override
    public void setStrokeColor(int color) {
        if (borderDrawable == null)
            borderDrawable = new BorderDrawable();
        borderDrawable.setStrokeColor(color);
    }

    @Override
    public int getStrokeColor() {
        if (borderDrawable != null)
            return borderDrawable.getStrokeColor();
        return 0;
    }

    @Override
    public void setCornerRadius(float radius) {
        if (borderDrawable == null)
            borderDrawable = new BorderDrawable();
        borderDrawable.setCornerRadius(radius);
    }

    @Override
    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        if (borderDrawable == null)
            borderDrawable = new BorderDrawable();
        borderDrawable.setRadius(topLeft, topRight, bottomLeft, bottomRight);
    }

    @Override
    public void setRadius(@RectCorner.Direction int direction, float radius) {
        if (borderDrawable == null)
            borderDrawable = new BorderDrawable();
        borderDrawable.setRadius(direction, radius);
    }

    @Override
    public float getRadius(@RectCorner.Direction int direction) {
        if (borderDrawable != null)
            return borderDrawable.getRadius(direction);
        return 0;
    }

    @Override
    public float[] getRadii() {
        if (borderDrawable != null)
            return borderDrawable.getRadii();
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="IMask">

    @Override
    public void setMaskRadius(int direction, float radius) {
        if (radiusDrawer == null)
            radiusDrawer = new RadiusDrawer();
        useRadiusDrawer = true;
        if (clipHelper != null) {
            clipHelper.revert(this);
        }
        radiusDrawer.updateOne(direction, radius);
    }

    @Override
    public void setMaskColor(int color) {
        if (radiusDrawer == null)
            radiusDrawer = new RadiusDrawer();
        useRadiusDrawer = true;
        if (clipHelper != null) {
            clipHelper.revert(this);
        }
        radiusDrawer.setRadiusColor(color);
    }
    //</editor-fold>

    //<editor-fold desc="clippable">
    @Override
    public void setClipRadius(float r) {
        if (clipHelper == null)
            clipHelper = new ClipHelper();
        useRadiusDrawer = false;
        clipHelper.applyClip(this);
        clipHelper.setClipRadius(r);
    }

    @Override
    public void setClipRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        if (clipHelper == null)
            clipHelper = new ClipHelper();
        useRadiusDrawer = false;
        clipHelper.applyClip(this);
        clipHelper.setClipRadius(topLeft, topRight, bottomLeft, bottomRight);
    }

    @Override
    public void setClipRadius(int direction, float radius) {
        if (clipHelper == null)
            clipHelper = new ClipHelper();
        useRadiusDrawer = false;
        clipHelper.applyClip(this);
        clipHelper.setClipRadius(direction, radius);
    }

    @Override
    public float getClipRadius(int direction) {
        if (clipHelper != null)
            return clipHelper.getClipRadius(direction);
        return 0;
    }

    @Override
    public float[] getClipRadii() {
        if (clipHelper != null)
            return clipHelper.getClipRadii();
        return null;
    }

    @Override
    public void openClip(boolean open) {
        if (open) {
            if (clipHelper == null)
                clipHelper = new ClipHelper();
            useRadiusDrawer = false;
            clipHelper.applyClip(this);
        } else {
            if (clipHelper != null)
                clipHelper.revert(this);
            useRadiusDrawer = radiusDrawer != null;
        }
    }
    //</editor-fold>

    //<editor-fold desc="background">
    @Override
    public void setBackgroundRadius(float r) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setBackgroundRadius(r);
    }

    @Override
    public void setBackgroundRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setBackgroundRadius(topLeft, topRight, bottomLeft, bottomRight);
    }

    @Override
    public void setBackgroundRadius(int direction, float radius) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setBackgroundRadius(direction, radius);
    }

    @Override
    public float getBackgroundRadius(int direction) {
        if (backgroundDrawable != null)
            return backgroundDrawable.getBackgroundRadius(direction);
        return 0;
    }

    @Override
    public void setBackgroundColor(int color) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setBackgroundColor(color);
    }

    @Override
    public int getBackgroundColor() {
        if (backgroundDrawable != null)
            return backgroundDrawable.getBackgroundColor();
        return 0;
    }

    @Override
    public void setBGDrawable(Drawable d) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setBGDrawable(d);
    }

    @Override
    public void setGradientColor(int start, int end, int type) {
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setGradientColor(start, end, type);
    }

    @Override
    public void setDrawRipple(boolean drawRipple) {
        if (!drawRipple) {
            if (backgroundDrawable != null)
                backgroundDrawable.setDrawRipple(false);
            return;
        }
        if (backgroundDrawable == null)
            backgroundDrawable = new BackgroundDrawable();
        setBackground((Drawable) backgroundDrawable);
        backgroundDrawable.setDrawRipple(drawRipple);
    }
    //</editor-fold>

    //<editor-fold desc="Shadow">
    @Override
    public void setShadow(int color, int w, int h, float shadowRadius, float alpha) {
        if (w == 0 && h == 0) {
            if (shadowImpl != null) {
                shadowImpl.revert(this);
            }
            return;
        }
        if (shadowImpl == null) {
            shadowImpl = new ShadowHelper();
            shadowImpl.applyShadow(this);
        }
        shadowImpl.setShadow(color, w, h, shadowRadius, alpha);
    }

    @Override
    public void setRoundRadiusForShadow(float roundRadius) {
        if (shadowImpl != null)
            shadowImpl.setRoundRadiusForShadow(roundRadius);
    }
    //</editor-fold>

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (clipHelper != null) {
            clipHelper.onSizeChanged(getMeasuredWidth(), getMeasuredHeight());
        }
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        boolean clip = clipHelper != null && clipHelper.needClipCanvas();
        if (clip) {
            canvas.save();
            clipHelper.clip(canvas);
        }
        super.dispatchDraw(canvas);
        if (borderDrawable != null) {
            final Drawable d = (Drawable) borderDrawable;
            d.setBounds(0, 0, getWidth(), getHeight());
            d.draw(canvas);
        }
        if (useRadiusDrawer && radiusDrawer != null) {
            radiusDrawer.clip(canvas);
        }
        if (clip)
            canvas.restore();
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (isEnabled() && backgroundDrawable != null)
            backgroundDrawable.onRippleTouchEvent(ev);
        return super.dispatchTouchEvent(ev);
    }
}
