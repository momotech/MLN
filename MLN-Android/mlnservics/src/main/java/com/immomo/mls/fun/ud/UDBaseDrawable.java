/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;

import static com.immomo.mls.fun.ud.MeasureMode.*;

/**
 * Created by Xiong.Fangyu on 2019-12-31
 * Android Test Only
 * 配合NativeLuaView使用的绘制类
 * 继承后实现{@link #draw(Canvas)}方法即可
 */
@LuaClass(abstractClass = true)
public abstract class UDBaseDrawable {
    public static final String LUA_CLASS_NAME = "__BaseDrawable";

    protected final @NonNull
    Globals globals;
    protected final @NonNull
    Paint paint;

    /**
     * 真实宽
     */
    protected int width;
    /**
     * 真实高
     */
    protected int height;
    /**
     * 计算出的宽
     *
     * @see #setMeasureResult(int, int)
     */
    protected int measuredWidth;
    /**
     * 计算出的高
     *
     * @see #setMeasureResult(int, int)
     */
    protected int measuredHeight;
    /**
     * padding值
     */
    protected int paddingLeft;
    protected int paddingTop;
    protected int paddingRight;
    protected int paddingBottom;

    private IVoidCallback refreshFunction;
    private IVoidCallback layoutFunction;
    private LuaValue selfParams;

    public UDBaseDrawable(@NonNull Globals g) {
        this.globals = g;
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    }

    /**
     * Lua GC时调用
     */
    @CallSuper
    public void __onLuaGc() {
        if (refreshFunction != null)
            refreshFunction.destroy();
        if (layoutFunction != null)
            layoutFunction.destroy();
        if (selfParams != null)
            selfParams.destroy();
        refreshFunction = null;
        layoutFunction = null;
        selfParams = null;
    }

    /**
     * 获取上下文，一般情况，此上下文为Activity
     */
    protected Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    /**
     * 通知刷新
     */
    public void invalidate() {
        if (selfParams != null
                && !selfParams.isDestroyed()
                && refreshFunction != null
                && !refreshFunction.isDestroy()) {
            refreshFunction.callback(selfParams);
        }
    }

    /**
     * 通知布局，必须通过此方法进行布局
     * 因为布局在Lua层
     */
    public void requestLayout() {
        if (selfParams != null
                && !selfParams.isDestroyed()
                && refreshFunction != null
                && !refreshFunction.isDestroy()) {
            layoutFunction.callback(selfParams);
        }
    }

    //<editor-fold desc="Bridge API">

    /**
     * 此'View'被加到Lua的View树时调用
     * 若继承，必须调用super
     *
     * @param selfParams NativeLuaView Lua对象
     */
    @CallSuper
    @LuaBridge
    public void onAddedToViewTree(LuaValue selfParams) {
        if (this.selfParams != null)
            this.selfParams.destroy();
        this.selfParams = selfParams;
    }

    /**
     * 此'View'被Lua的View树移除后调用
     * 若继承，必须调用super
     */
    @CallSuper
    @LuaBridge
    public void onRemovedFromViewTree() {
        if (selfParams != null)
            selfParams.destroy();
        selfParams = null;
    }

    /**
     * 设置刷新回调，子类不可重写
     */
    @LuaBridge
    final void setRefreshFunction(IVoidCallback fun) {
        refreshFunction = fun;
    }

    /**
     * 设置layout回调，子类不可重写
     */
    @LuaBridge
    final void setLayoutFunction(IVoidCallback fun) {
        layoutFunction = fun;
    }

    /**
     * Lua的View树重新layout时会调用，子类不可重写
     * 若需要自定义宽高，重写{@link #onMeasureInner(int, double, int, double)}
     * 并在最后，调用{@link #setMeasureResult(int, int)}
     *
     * @param wm 宽模式
     * @param ws 宽大小，dp
     * @param hm 高模式
     * @param hs 高大小，dp
     * @return 返回宽和高
     */
    @LuaBridge
    final LuaValue[] onMeasure(@SizeMode int wm, double ws, @SizeMode int hm, double hs) {
        onMeasureInner(wm, ws, hm, hs);
        return LuaValue.varargsOf(
                LuaNumber.valueOf(DimenUtil.pxToDpi(measuredWidth)),
                LuaNumber.valueOf(DimenUtil.pxToDpi(measuredHeight)));
    }

    /**
     * Lua的View树设置此'View'的绝对位置时调用
     * 子类若重写，必须调用super
     *
     * @param changed 和之前的位置是否有改变
     * @param l       left, dp
     * @param t       top, dp
     * @param r       right, dp
     * @param b       bottom, dp
     */
    @CallSuper
    @LuaBridge
    protected void onLayout(boolean changed, double l, double t, double r, double b) {
        width = DimenUtil.dpiToPx(r - l);
        height = DimenUtil.dpiToPx(b - t);
    }

    /**
     * NativeLuaView的padding修改时调用
     * 子类若重写，必须调用super
     *
     * @param l left, dp
     * @param t top, dp
     * @param r right, dp
     * @param b bottom, dp
     */
    @CallSuper
    @LuaBridge
    protected void onPadding(double l, double t, double r, double b) {
        paddingLeft = DimenUtil.dpiToPx(l);
        paddingTop = DimenUtil.dpiToPx(t);
        paddingRight = DimenUtil.dpiToPx(r);
        paddingBottom = DimenUtil.dpiToPx(b);
    }

    /**
     * 子类重写此方法，自定义绘制效果
     *
     * @param canvas 画布
     */
    @LuaBridge
    public abstract void draw(Canvas canvas);
    //</editor-fold>

    /**
     * 计算自身宽高
     * 若子类要重写，计算完成后，必须调用{@link #setMeasureResult(int, int)}方法
     *
     * @param wm 宽模式
     * @param ws 宽大小，dp
     * @param hm 高模式
     * @param hs 高大小，dp
     * @see #onMeasure(int, double, int, double)
     * @see #setMeasureResult(int, int)
     */
    protected void onMeasureInner(@SizeMode int wm, double ws, @SizeMode int hm, double hs) {
        int width, height;
        if (wm == EXACTLY) {
            width = DimenUtil.dpiToPx(ws);
        } else {
            width = paddingLeft + paddingRight;
            if (wm == AT_MOST) {
                width = Math.min(width, DimenUtil.dpiToPx(ws));
            }
        }

        if (hm == EXACTLY) {
            height = DimenUtil.dpiToPx(hs);
        } else {
            height = paddingTop + paddingBottom;
            if (hm == AT_MOST) {
                height = Math.min(height, DimenUtil.dpiToPx(hs));
            }
        }
        setMeasureResult(width, height);
    }

    /**
     * 设置当前'View'计算出的宽高
     *
     * @param w px
     * @param h px
     * @see #onMeasureInner(int, double, int, double)
     * @see #measuredWidth
     * @see #measuredHeight
     */
    protected void setMeasureResult(int w, int h) {
        measuredWidth = w;
        measuredHeight = h;
    }
}
