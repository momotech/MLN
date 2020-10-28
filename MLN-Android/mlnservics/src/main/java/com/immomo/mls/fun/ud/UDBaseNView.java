/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;

import static com.immomo.mls.fun.ud.MeasureMode.*;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.AssertUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * Android Test Only
 * 配合NativeLuaView使用的绘制类
 * 继承后实现{@link #newView(Context, LuaValue[])}即可
 * 若要单独绘制
 *
 * @see UDBaseDrawable
 */
@LuaApiUsed
public abstract class UDBaseNView<V extends View> extends LuaUserdata<V> {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "__BaseNView";

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
    private LuaFunction refreshFunction;
    private LuaFunction layoutFunction;
    private LuaValue selfParams;
    private ViewGroup parent;

    //<editor-fold desc="Constructors">

    @LuaApiUsed
    protected UDBaseNView(long L, @NonNull LuaValue[] v) {
        super(L, v);
        javaUserdata = newView(getContext(), v);
        AssertUtils.assertNullForce(javaUserdata);
    }

    @LuaApiUsed
    public UDBaseNView(@NonNull Globals g, V o) {
        super(g, o);
    }
    //</editor-fold>

    /**
     * 子类实现，创建此对象包裹的View
     *
     * @param context    上下文
     * @param initParams Lua传入的初始化参数，不为空，但长度可能为0
     */
    protected @NonNull
    abstract V newView(Context context, @NonNull LuaValue[] initParams);

    /**
     * 通知刷新，也可以调用{@link View#invalidate()}
     */
    public void invalidate() {
        if (selfParams != null
                && !selfParams.isDestroyed()
                && refreshFunction != null
                && !refreshFunction.isDestroyed()) {
            refreshFunction.invoke(varargsOf(selfParams));
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
                && !refreshFunction.isDestroyed()) {
            layoutFunction.invoke(varargsOf(selfParams));
        }
    }

    /**
     * 获取上下文，一般为Activity
     */
    protected Context getContext() {
        LuaViewManager m = (LuaViewManager) getGlobals().getJavaUserdata();
        return m != null ? m.context : null;
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
    protected void onLayout(boolean changed, double l, double t, double r, double b) {
        width = DimenUtil.dpiToPx(r - l);
        height = DimenUtil.dpiToPx(b - t);
        int ml = DimenUtil.dpiToPx(l);
        int mt = DimenUtil.dpiToPx(t);
        javaUserdata.setX(ml);
        javaUserdata.setY(mt);
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
    protected void onPadding(double l, double t, double r, double b) {
        int paddingLeft = DimenUtil.dpiToPx(l);
        int paddingTop = DimenUtil.dpiToPx(t);
        int paddingRight = DimenUtil.dpiToPx(r);
        int paddingBottom = DimenUtil.dpiToPx(b);
        getJavaUserdata().setPadding(paddingLeft, paddingTop, paddingRight, paddingBottom);
    }

    /**
     * 计算自身宽高
     * 若子类要重写，计算完成后，必须调用{@link #setMeasureResult(int, int)}方法
     *
     * @param wm 宽模式
     * @param ws 宽大小，dp
     * @param hm 高模式
     * @param hs 高大小，dp
     * @see #onMeasure
     * @see #setMeasureResult(int, int)
     */
    @CallSuper
    protected void onMeasureInner(@SizeMode int wm, double ws, @SizeMode int hm, double hs) {
        int w = getMeasureSpecMode(wm, ws);
        int h = getMeasureSpecMode(hm, hs);
        View v = getJavaUserdata();
        v.measure(w, h);
        setMeasureResult(v.getMeasuredWidth(), v.getMeasuredHeight());
        ViewGroup.LayoutParams lp = v.getLayoutParams();
        if (lp.width != measuredWidth || lp.height != measuredHeight) {
            lp.width = measuredWidth;
            lp.height = measuredHeight;
            v.requestLayout();
        }
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
    @CallSuper
    protected void setMeasureResult(int w, int h) {
        measuredWidth = w;
        measuredHeight = h;
    }

    //<editor-fold desc="Bridge API">

    /**
     * 此'View'被加到Lua的View树时调用
     * 若继承，必须调用super
     */
    @CallSuper
    @LuaApiUsed
    protected LuaValue[] onAddedToViewTree(LuaValue[] params) {
        if (this.selfParams != null)
            this.selfParams.destroy();
        this.selfParams = params[0];
        parent = (ViewGroup) params[1].toUserdata().getJavaUserdata();
        parent.addView(javaUserdata);
        return null;
    }

    /**
     * 此'View'被Lua的View树移除后调用
     * 若继承，必须调用super
     */
    @CallSuper
    @LuaApiUsed
    protected LuaValue[] onRemovedFromViewTree(LuaValue[] p) {
        if (selfParams != null)
            selfParams.destroy();
        selfParams = null;
        parent.removeView(javaUserdata);
        parent = null;
        return null;
    }

    /**
     * 设置刷新回调，子类不可重写
     */
    @LuaApiUsed
    private LuaValue[] setRefreshFunction(LuaValue[] fun) {
        refreshFunction = fun[0].toLuaFunction();
        return null;
    }

    /**
     * 设置layout回调，子类不可重写
     */
    @LuaApiUsed
    private LuaValue[] setLayoutFunction(LuaValue[] fun) {
        layoutFunction = fun[0].toLuaFunction();
        return null;
    }

    /**
     * Lua的View树重新layout时会调用，子类不可重写
     * 若需要自定义宽高，重写{@link #onMeasureInner(int, double, int, double)}
     * 并在最后，调用{@link #setMeasureResult(int, int)}
     *
     * @return 返回宽和高
     */
    @LuaApiUsed
    private LuaValue[] onMeasure(LuaValue[] params) {
        int wm = params[0].toInt();
        double ws = params[1].toDouble();
        int hm = params[2].toInt();
        double hs = params[3].toDouble();
        onMeasureInner(wm, ws, hm, hs);
        return LuaValue.varargsOf(
                LuaNumber.valueOf(DimenUtil.pxToDpi(measuredWidth)),
                LuaNumber.valueOf(DimenUtil.pxToDpi(measuredHeight)));
    }

    /**
     * Lua的View树设置此'View'的绝对位置时调用
     *
     * @see #onLayout(boolean, double, double, double, double)
     */
    @LuaApiUsed
    private LuaValue[] onLayout(LuaValue[] params) {
        onLayout(params[0].toBoolean(), params[1].toDouble(), params[2].toDouble(), params[3].toDouble(), params[4].toDouble());
        return null;
    }

    /**
     * NativeLuaView的padding修改时调用
     *
     * @see #onPadding(double, double, double, double)
     */
    @LuaApiUsed
    private LuaValue[] onPadding(LuaValue[] params) {
        onPadding(params[0].toDouble(), params[1].toDouble(), params[2].toDouble(), params[3].toDouble());
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Other">

    /**
     * 此对象被Lua GC时调用，可不实现
     * 可做相关释放操作
     */
    @CallSuper
    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
    }
    //</editor-fold>
}
