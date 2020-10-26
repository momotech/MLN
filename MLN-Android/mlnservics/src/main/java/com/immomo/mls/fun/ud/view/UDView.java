/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.animation.Animator;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.Animation;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.MLSInstance;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.constants.RectCorner;
import com.immomo.mls.fun.lt.SICornerRadiusManager;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Rect;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.UDRect;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ud.anim.canvasanim.UDBaseAnimation;
import com.immomo.mls.fun.ui.LuaLinearLayout;
import com.immomo.mls.fun.ui.LuaOverlayContainer;
import com.immomo.mls.fun.weight.ILimitSizeView;
import com.immomo.mls.fun.weight.IPriorityObserver;
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.convert.ConvertUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static android.view.ViewGroup.*;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public abstract class UDView<V extends View> extends JavaUserdata<V> implements ILView.ViewLifeCycleCallback {
    public static final String LUA_CLASS_NAME = "__BaseView";
    public static final String[] methods = new String[]{
            "width",
            "height",
            "anchorPoint",
            "x",
            "y",
            "bottom",
            "right",
            "marginLeft",
            "marginTop",
            "marginRight",
            "marginBottom",
            "priority",
            "weight",
            "frame",
            "size",
            "point",
            "centerX",
            "centerY",
            "getCenterX",
            "getCenterY",
            "sizeToFit",
            "removeFromSuper",
            "superview",
            "layoutIfNeeded",
            "padding",
            "addBlurEffect",
            "removeBlurEffect",
            "setGravity",
            "requestLayout",
            "setWrapContent",
            "setMatchParent",
            "openRipple",
            "transform",
            "transformIdentity",
            "rotation",
            "translation",
            "scale",
            "setMaxWidth",
            "setMaxHeight",
            "setMinWidth",
            "setMinHeight",
            "bringSubviewToFront",
            "sendSubviewToBack",
            "canEndEditing",
            "alpha",
            "borderWidth",
            "borderColor",
            "hidden",
            "gone",
            "bgColor",
            "setNineImage",
            "cornerRadius",
            "refresh",
            "setCornerRadiusWithDirection",
            "addCornerMask",
            "clipToBounds",
            "setGradientColorWithDirection",
            "setGradientColor",
            "notClip",
            "enabled",
            "onTouch",
            "onClick",
            "onLongPress",
            "hasFocus",
            "canFocus",
            "requestFocus",
            "cancelFocus",
            "setPositionAdjustForKeyboard",
            "setPositionAdjustForKeyboardAndOffset",
            "convertRelativePointTo",
            "convertPointTo",
            "convertPointFrom",
            "touchBegin",
            "touchMove",
            "touchEnd",
            "touchCancel",
            "touchBeginExtension",
            "touchMoveExtension",
            "touchEndExtension",
            "touchCancelExtension",
            "snapshot",
            "startAnimation",
            "clearAnimation",
            "bgImage",
            "getCornerRadiusWithDirection",
            "addShadow",
            "setShadow",
            "removeAllAnimation",
            "onDraw",
            "onDetachedView",
            "clipToChildren",
            "overlay",
    };

    private List<Animator> animatorCacheList;

    private LuaFunction clickCallback;
    private LuaFunction longClickCallback;
    private LuaFunction touchCallback;
    private LuaFunction detachFunction;

    // 配合 IOS 添加
    private LuaFunction touchBeginCallback;
    private LuaFunction touchMoveCallback;
    private LuaFunction touchEndCallback;
    private LuaFunction touchCancelCallback;

    private LuaFunction touchBeginExtensionCallback;
    private LuaFunction touchMoveExtensionCallback;
    private LuaFunction touchEndExtensionCallback;
    private LuaFunction touchCancelExtensionCallback;

    protected LuaFunction onDrawCallback;
    protected UDCanvas udCanvasTemp;//缓存onDraw()的canvas，防止频繁创建

    private HashMap mTouchEventExtensionMap;

    public final @NonNull
    UDLayoutParams udLayoutParams = new UDLayoutParams();

    private float mInitTranslateX = -1;
    private float mInitTranslateY = -1;
    private float mInitScaleX = -1;
    private float mInitScaleY = -1;
    private float mInitRotation = -1;
    boolean canEndEditing;

    protected boolean hasNineImage = false;//是否添加点9图

    private int mPaddingLeft;
    private int mPaddingTop;
    private int mPaddingRight;
    private int mPaddingBottom;

    protected final @NonNull
    V view;

    protected UDView overView;//overLay方法，包裹view
    protected UDViewGroup overContainer;

    /**
     * 必须有传入long和LuaValue[]的构造方法，且不可混淆
     * 由native创建
     * <p>
     * 必须有此构造方法！！！！！！！！
     *
     * @param L 虚拟机地址
     * @param v lua脚本传入的构造参数
     */
    @LuaApiUsed
    protected UDView(long L, LuaValue[] v) {
        super(L, v);
        view = newView(v);
        checkView();
        initClipConfig();
        javaUserdata = view;
    }

    /**
     * 由Java层创建
     *
     * @param g   虚拟机
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDView(Globals g, @NonNull V jud) {
        super(g, jud);
        this.view = jud;
        checkView();
        initClipConfig();
        javaUserdata = jud;
    }

    /**
     * 由java层继承，并能创建默认参数的view
     *
     * @param g 虚拟机
     */
    protected UDView(Globals g) {
        super(g, null);
        this.view = newView(empty());
        checkView();
        initClipConfig();
        javaUserdata = view;
    }

    protected @NonNull
    abstract V newView(@NonNull LuaValue[] init);

    /**
     * 视图布局默认不切割子视图在padding区域
     *
     * @return 是否切割
     */
    protected boolean clipToPadding() {
        return MLSConfigs.defaultClipToPadding;
    }

    /**
     * 默认布局要切割子视图
     */
    protected boolean clipChildren() {
        return MLSConfigs.defaultClipChildren;
    }

    private void checkView() {
        if (view == null) {
            throw new NullPointerException("view is null!!!!");
        }
        if (view instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) view;
            vg.setClipToPadding(clipToPadding());
            vg.setClipChildren(clipChildren());
        }
    }

    /**
     * 初始化View的 辅助圆角切割开关。
     * 开关保存在globals，虚拟机全局生效。
     * 通过{@link SICornerRadiusManager}，在lua项目开始时设置。不能动态更改
     */
    private void initClipConfig() {
        if (view instanceof IClipRadius) {
            LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
            if (m == null) {
                return;
            }
            ((IClipRadius) view).initCornerManager(m.getDefaltCornerClip());
        }
    }

    public LuaViewManager getLuaViewManager() {
        return (LuaViewManager) globals.getJavaUserdata();
    }

    public Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    protected boolean canDoClick() {
        LuaViewManager m = getLuaViewManager();
        MLSInstance instance = m != null ? m.instance : null;
        if (instance != null) {
            return instance.getClickEventLimiter().canDoClick();
        }
        return true;
    }

    public V getView() {
        return view;
    }

    //<editor-fold desc="overlay API">

    public void measureOverLayout(int widthMeasureSpec, int heightMeasureSpec) {
        if (overContainer != null && overView != null) {
            View overContainerView = overContainer.getView();

            overContainerView.measure(getChildMeasureSpec(widthMeasureSpec,
                0, getView().getMeasuredWidth())
                , getChildMeasureSpec(heightMeasureSpec,
                    0, getView().getMeasuredHeight()));
        }
    }

    public void layoutOverLayout(int left, int top, int right, int bottom) {
        if (overContainer != null && overView != null) {
            View overContainerView = overContainer.getView();
            overContainerView.layout(0, 0, right - left, bottom - top);
        }
    }

    public void drawOverLayout(Canvas canvas) {
        if (overContainer != null && overView != null) {
            overContainer.getView().draw(canvas);
        }
    }
    //</editor-fold>

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    public LuaValue[] width(LuaValue[] varargs) {
        if (varargs.length == 1) {
            double src = varargs[0].toDouble();
            checkSize(src);
            int w = DimenUtil.dpiToPx(src);
            int cs = DimenUtil.check(w);
            setWidth(cs);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getWidth())));
    }

    protected void checkSize(double src) {
        if (src >= 0)
            return;
        if (src == MeasurementType.MATCH_PARENT || src == MeasurementType.WRAP_CONTENT)
            return;
        ErrorUtils.debugLuaError("size must be set with positive number, error number: " + src + ".", getGlobals());
    }

    protected void setWidth(float w) {
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params == null) {
            params = new ViewGroup.MarginLayoutParams((int) w, ViewGroup.LayoutParams.WRAP_CONTENT);
            view.setLayoutParams(params);
            return;
        }
        params.width = (int) w;
        view.setLayoutParams(params);
    }

    public int getWidth() {
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params != null) {
            return params.width >= 0 ? params.width : view.getWidth();
        }
        return view.getWidth();
    }

    @LuaApiUsed
    public LuaValue[] height(LuaValue[] varargs) {
        if (varargs.length == 1) {
            double src = varargs[0].toDouble();
            checkSize(src);
            int h = DimenUtil.dpiToPx(src);
            int cs = DimenUtil.check(h);
            setHeight(cs);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getHeight())));
    }

    protected void setHeight(float h) {
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params == null) {
            params = new ViewGroup.MarginLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, (int) h);
            view.setLayoutParams(params);
            return;
        }
        params.height = (int) h;
        view.setLayoutParams(params);
    }

    public int getHeight() {
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params != null) {
            return params.height >= 0 ? params.height : view.getHeight();
        }
        return view.getHeight();
    }

    @LuaApiUsed
    public LuaValue[] anchorPoint(LuaValue[] p) {
        float x = (float) p[0].toDouble();
        float y = (float) p[1].toDouble();

        int width = getWidth();
        int height = getHeight();

        ViewGroup.LayoutParams params = view.getLayoutParams();

        if (params != null && view.getParent() instanceof ViewGroup && ((ViewGroup) view.getParent()).getLayoutParams() != null) {

            if (width == 0 && params.width == ViewGroup.LayoutParams.MATCH_PARENT)
                width = ((ViewGroup) view.getParent()).getLayoutParams().width;

            if (height == 0 && params.height == ViewGroup.LayoutParams.MATCH_PARENT)
                height = ((ViewGroup) view.getParent()).getLayoutParams().height;
        }


        if (x >= 0 && x <= 1 && width != 0)
            view.setPivotX(width * x);

        if (y >= 0 && y <= 1 && height != 0)
            view.setPivotY(height * y);

        return null;
    }

    @LuaApiUsed
    public LuaValue[] x(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("x", globals);
            setX(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("x", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getX())));
    }

    public void setX(int x) {
        udLayoutParams.marginLeft = x;
        setMargins();
        view.setTranslationX(0);
    }

    public float getX() {
        if (!Float.isNaN(udLayoutParams.centerX)) {
            return udLayoutParams.centerX - (getWidth() >> 1);
        }
        ViewGroup.MarginLayoutParams p = getViewMarginLayoutParams();
        return p.leftMargin;
    }

    @LuaApiUsed
    public LuaValue[] y(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("y", globals);
            setY(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("y", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getY())));
    }

    public void setY(int y) {
        udLayoutParams.marginTop = y;
        setMargins();
        view.setTranslationY(0);
    }

    public float getY() {
        if (!Float.isNaN(udLayoutParams.centerY)) {
            return udLayoutParams.centerY - (getHeight() >> 1);
        }
        ViewGroup.MarginLayoutParams p = getViewMarginLayoutParams();
        return p.topMargin;
    }

    @LuaApiUsed
    public LuaValue[] bottom(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("bottom", globals);
            setBottom(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("bottom", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getBottom())));
    }

    public void setBottom(int b) {
        udLayoutParams.marginTop = b - getHeight();
        setMargins();
    }

    public float getBottom() {
        return udLayoutParams.marginBottom == 0 ? getY() + getHeight() : udLayoutParams.marginBottom;
    }

    @LuaApiUsed
    public LuaValue[] right(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("right", globals);
            setRight(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("right", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getRight())));
    }

    public void setRight(int r) {
        udLayoutParams.marginLeft = r - getWidth();
        setMargins();
    }

    public float getRight() {
        return udLayoutParams.marginRight == 0 ? getX() + getWidth() : udLayoutParams.marginRight;
    }


    @LuaApiUsed
    public LuaValue[] marginLeft(LuaValue[] var) {
        if (var.length == 1) {
            setMarginLeft(DimenUtil.dpiToPx(var[0]));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(udLayoutParams.realMarginLeft)));
    }

    protected void setMarginLeft(int px) {
        udLayoutParams.realMarginLeft = px;
        setRealMargins();
        view.setTranslationX(0);
    }

    @LuaApiUsed
    public LuaValue[] marginTop(LuaValue[] var) {
        if (var.length == 1) {
            setMarginTop(DimenUtil.dpiToPx(var[0]));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(udLayoutParams.realMarginTop)));
    }

    protected void setMarginTop(int px) {
        udLayoutParams.realMarginTop = px;
        setRealMargins();
        view.setTranslationY(0);
    }

    @LuaApiUsed
    public LuaValue[] marginRight(LuaValue[] var) {
        if (var.length == 1) {
            setMarginRight(DimenUtil.dpiToPx(var[0]));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(udLayoutParams.realMarginRight)));
    }

    protected void setMarginRight(int right) {
        udLayoutParams.realMarginRight = right;
        setRealMargins();
    }

    @LuaApiUsed
    public LuaValue[] marginBottom(LuaValue[] var) {
        if (var.length == 1) {
            udLayoutParams.realMarginBottom = DimenUtil.dpiToPx(var[0]);
            setRealMargins();
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(udLayoutParams.realMarginBottom)));
    }

    @LuaApiUsed
    public LuaValue[] priority(LuaValue[] var) {
        if (var.length == 1) {
            int p = var[0].toInt();
            ViewParent vp = view.getParent();
            if (vp instanceof IPriorityObserver) {
                ((IPriorityObserver) vp).onViewPriorityChanged(view, udLayoutParams.priority, p);
            }
            udLayoutParams.priority = p;
            setRealMargins();
            return null;
        }
        return varargsOf(LuaNumber.valueOf(udLayoutParams.priority));
    }

    @LuaApiUsed
    public LuaValue[] weight(LuaValue[] var) {
        if (var.length == 1) {
            int p = var[0].toInt();
            udLayoutParams.weight = p;
            setRealMargins();
            return null;
        }
        return rNumber(udLayoutParams.weight);
    }

    private void setRealMargins() {
        final View v = view;
        ViewGroup.LayoutParams p = v.getLayoutParams();
        if (v.getParent() instanceof ILViewGroup) {
            p = ((ILViewGroup) v.getParent()).applyLayoutParams(p, udLayoutParams);
            v.setLayoutParams(p);
            return;
        }
        if (p == null) {
            p = newWrapContent();
        }
        if (!(p instanceof ViewGroup.MarginLayoutParams)) {
            p = new ViewGroup.MarginLayoutParams(p);
        }
        ((ViewGroup.MarginLayoutParams) p).setMargins(udLayoutParams.realMarginLeft,
                udLayoutParams.realMarginTop, udLayoutParams.realMarginRight, udLayoutParams.realMarginBottom);
        v.setLayoutParams(p);
    }

    private boolean setMargins() {
        udLayoutParams.useRealMargin = false;
        final View v = view;
        ViewGroup.LayoutParams p = v.getLayoutParams();
        if (v.getParent() instanceof ILViewGroup) {
            p = ((ILViewGroup) v.getParent()).applyLayoutParams(p, udLayoutParams);
            v.setLayoutParams(p);
            return true;
        }
        if (p == null) {
            p = newWrapContent();
        }
        if (!(p instanceof ViewGroup.MarginLayoutParams)) {
            p = new ViewGroup.MarginLayoutParams(p);
        }
        ((ViewGroup.MarginLayoutParams) p).setMargins(udLayoutParams.marginLeft,
                udLayoutParams.marginTop, udLayoutParams.marginRight, udLayoutParams.marginBottom);
        v.setLayoutParams(p);
        return false;
    }

    private @NonNull
    ViewGroup.MarginLayoutParams getViewMarginLayoutParams() {
        ViewGroup.LayoutParams p = view.getLayoutParams();
        if (p == null) {
            p = newWrapContent();
            view.setLayoutParams(p);
        }
        if (!(p instanceof ViewGroup.MarginLayoutParams)) {
            p = new ViewGroup.MarginLayoutParams(p);
            view.setLayoutParams(p);
        }
        return (ViewGroup.MarginLayoutParams) p;
    }

    @LuaApiUsed
    public LuaValue[] frame(LuaValue[] varargs) {
        if (varargs.length == 1) {
            ErrorUtils.debugDeprecatedSetter("frame", globals);
            Rect rect = ((UDRect) varargs[0]).getRect();
            Point point = rect.getPoint();
            Size size = rect.getSize();
            setWidth(size.getWidthPx());
            setHeight(size.getHeightPx());
            setX((int) point.getXPx());
            setY((int) point.getYPx());
            varargs[0].destroy();
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("frame", globals);
        Rect rect = new Rect(DimenUtil.pxToDpi(getX()), DimenUtil.pxToDpi(getY()),
                (int) DimenUtil.pxToDpi(getWidth()), (int) DimenUtil.pxToDpi(getHeight()));
        return varargsOf(new UDRect(globals, rect));
    }

    @LuaApiUsed
    public LuaValue[] size(LuaValue[] varargs) {
        if (varargs.length == 1) {
            ErrorUtils.debugDeprecatedSetter("size", globals);
            Size size = ((UDSize) varargs[0]).getSize();
            setWidth(size.getWidthPx());
            setHeight(size.getHeightPx());
            varargs[0].destroy();
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("size", globals);
        Size size = new Size((int) DimenUtil.pxToDpi(getWidth()), (int) DimenUtil.pxToDpi(getHeight()));
        return varargsOf(new UDSize(globals, size));
    }

    @LuaApiUsed
    public LuaValue[] point(LuaValue[] varargs) {
        if (varargs.length == 1) {
            ErrorUtils.debugDeprecatedSetter("point", globals);
            Point point = ((UDPoint) varargs[0]).getPoint();
            setX((int) point.getXPx());
            setY((int) point.getYPx());
            varargs[0].destroy();
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("point", globals);
        Point point = new Point(DimenUtil.pxToDpi(getX()), DimenUtil.pxToDpi(getY()));
        return varargsOf(new UDPoint(globals, point));
    }

    @LuaApiUsed
    public LuaValue[] centerX(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("centerX", globals);
            setCenterX(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("centerX", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterX())));
    }

    public float getCenterX() {
        if (!Float.isNaN(udLayoutParams.centerX))
            return udLayoutParams.centerX;
        return (getView().getX() + getWidth() / 2.0f);
    }

    public void setCenterX(float x) {
        udLayoutParams.marginLeft = udLayoutParams.marginRight = 0;
        udLayoutParams.centerX = x;
        applyCenter();
    }

    @LuaApiUsed
    public LuaValue[] centerY(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("centerY", globals);
            setCenterY(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        ErrorUtils.debugDeprecatedGetter("centerY", globals);
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterY())));
    }

    public float getCenterY() {
        if (!Float.isNaN(udLayoutParams.centerY))
            return udLayoutParams.centerY;
        return getView().getY() + getHeight() / 2.0f;
    }

    public void setCenterY(float y) {
        udLayoutParams.marginTop = udLayoutParams.marginBottom = 0;
        udLayoutParams.centerY = y;
        applyCenter();
    }

    private void applyCenter() {
        udLayoutParams.useRealMargin = false;
        final View v = view;
        ViewGroup.LayoutParams p = v.getLayoutParams();
        if (v.getParent() instanceof ILViewGroup) {
            p = ((ILViewGroup) v.getParent()).applyChildCenter(p, udLayoutParams);
            v.setLayoutParams(p);
        }
    }
    //</editor-fold>

    //<editor-fold desc="Method">

    /**
     * use {@link #getCenterX()}
     *
     * @return
     */
    @Deprecated
    @LuaApiUsed
    public LuaValue[] getCenterX(LuaValue[] p) {
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterX())));
    }

    /**
     * use {@link #getCenterY()}
     *
     * @return
     */
    @Deprecated
    @LuaApiUsed
    public LuaValue[] getCenterY(LuaValue[] p) {
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterY())));
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] sizeToFit(LuaValue[] p) {
        udLayoutParams.useRealMargin = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeFromSuper(LuaValue[] var) {
        if (view.getParent() instanceof ViewGroup) {
            final ViewGroup parent = (ViewGroup) view.getParent();
            LuaViewUtil.removeView(parent, view);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] superview(LuaValue[] var) {
        if (view.getParent() instanceof ILView) {
            return varargsOf(((ILView) view.getParent()).getUserdata());
        }
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] layoutIfNeeded(LuaValue[] p) {
        ErrorUtils.debugUnsupportError("Method: layoutIfNeeded() is Deprecated");
        udLayoutParams.useRealMargin = false;
        view.requestLayout();
        return null;
    }

    /**
     * iOS只在文本控件中支持
     */
    @LuaApiUsed
    public LuaValue[] padding(LuaValue[] p) {
        mPaddingLeft = DimenUtil.dpiToPx((float) p[3].toDouble());
        mPaddingTop = DimenUtil.dpiToPx((float) p[0].toDouble());
        mPaddingRight = DimenUtil.dpiToPx((float) p[1].toDouble());
        mPaddingBottom = DimenUtil.dpiToPx((float) p[2].toDouble());

        if (overContainer != null) {
            overContainer.padding(p);
        }

        view.setPadding(
                mPaddingLeft,
                mPaddingTop,
                mPaddingRight,
                mPaddingBottom);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] addBlurEffect(LuaValue[] p) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeBlurEffect(LuaValue[] p) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setGravity(LuaValue[] var) {
        udLayoutParams.gravity = var[0].toInt();
        udLayoutParams.isSetGravity = true;
        setRealMargins();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] requestLayout(LuaValue[] p) {
        view.requestLayout();
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] setWrapContent(LuaValue[] pa) {
        if (pa[0].toBoolean()) {
            int settedSize = ViewGroup.LayoutParams.WRAP_CONTENT;
            ViewGroup.LayoutParams p = view.getLayoutParams();
            if (p != null) {
                p.width = settedSize;
                p.height = settedSize;
            } else {
                p = new ViewGroup.LayoutParams(settedSize, settedSize);
            }
            view.setLayoutParams(p);
        }
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] setMatchParent(LuaValue[] pa) {
        if (pa[0].toBoolean()) {
            int settedSize = ViewGroup.LayoutParams.MATCH_PARENT;
            ViewGroup.LayoutParams p = view.getLayoutParams();
            if (p != null) {
                p.width = settedSize;
                p.height = settedSize;
            } else {
                p = new ViewGroup.LayoutParams(settedSize, settedSize);
            }
            view.setLayoutParams(p);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] openRipple(LuaValue[] var) {
        if (view instanceof IRippleView) {
            ((IRippleView) view).setDrawRipple(var[0].toBoolean());
        }
        return null;
    }

    /**
     * angle
     * adding 是否相对当前视图角度进行追加
     * SDK>=1.0.4
     */
    @Deprecated
    @LuaApiUsed
    public LuaValue[] transform(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("Method: transform() is Deprecated,  use rotation instead");

        float angle = (float) var[0].toDouble();
        boolean adding = var[1].toBoolean();

        getInitValue();

        if (!adding) {
            view.setRotation(angle);
        } else {
            view.setRotation(view.getRotation() + angle);
        }
        return null;
    }

    // 重置所有变化到初始状态
    @LuaApiUsed
    public LuaValue[] transformIdentity(LuaValue[] var) {
        getInitValue();
        view.setRotation(mInitRotation);
        view.setScaleY(mInitScaleY);
        view.setScaleX(mInitScaleX);
        view.setTranslationX(mInitTranslateX);
        view.setTranslationY(mInitTranslateY);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] rotation(LuaValue[] var) {
        float angle = (float) var[0].toDouble();
        boolean notNeedAdding = var.length > 1 && var[1].toBoolean();

        getInitValue();

        if (notNeedAdding) {
            view.setRotation(angle);
        } else {
            view.setRotation(view.getRotation() + angle);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] translation(LuaValue[] var) {
        float xTranslate = (float) var[0].toDouble();
        float yTranslate = (float) var[1].toDouble();

        getInitValue();
        view.setTranslationX(view.getTranslationX() + DimenUtil.dpiToPx(xTranslate));
        view.setTranslationY(view.getTranslationY() + DimenUtil.dpiToPx(yTranslate));

        return null;
    }

    @LuaApiUsed
    public LuaValue[] scale(LuaValue[] var) {
        float xScale = Math.abs((float) var[0].toDouble());
        float yScale = Math.abs((float) var[1].toDouble());

        getInitValue();
        view.setScaleX(view.getScaleX() * xScale);
        view.setScaleY(view.getScaleY() * yScale);

        return null;
    }


    /**
     * iOS没有，测试用
     */
    @LuaApiUsed
    public LuaValue[] setMaxWidth(LuaValue[] pa) {
        if (view instanceof ILimitSizeView) {
            ((ILimitSizeView) view).setMaxWidth(DimenUtil.dpiToPx((float) pa[0].toDouble()));
        }
        return null;
    }

    /**
     * iOS没有，测试用
     */
    @LuaApiUsed
    public LuaValue[] setMaxHeight(LuaValue[] pa) {
        if (view instanceof ILimitSizeView) {
            ((ILimitSizeView) view).setMaxHeight(DimenUtil.dpiToPx((float) pa[0].toDouble()));
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setMinWidth(LuaValue[] p) {
        view.setMinimumWidth(DimenUtil.dpiToPx((float) p[0].toDouble()));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setMinHeight(LuaValue[] p) {
        view.setMinimumHeight(DimenUtil.dpiToPx((float) p[0].toDouble()));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] bringSubviewToFront(LuaValue[] var) {
        if (view instanceof ILViewGroup && var[0] instanceof UDView) {
            ((ILViewGroup) view).bringSubviewToFront((UDView) var[0]);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] sendSubviewToBack(LuaValue[] var) {
        if (view instanceof ILViewGroup && var[0] instanceof UDView) {
            ((ILViewGroup) view).sendSubviewToBack((UDView) var[0]);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] canEndEditing(LuaValue[] p) {
        if (p != null && p.length > 0 && p[0].isBoolean()) {
            canEndEditing = p[0].toBoolean();
            if (canEndEditing) {
                view.setOnClickListener(clickListener);
            }
        }
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Render">
    @LuaApiUsed
    public LuaValue[] alpha(LuaValue[] p) {
        if (p.length == 1) {
            view.setAlpha((float) p[0].toDouble());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(view.getAlpha()));
    }

    @LuaApiUsed
    public LuaValue[] borderWidth(LuaValue[] p) {
        if (p.length == 1) {
            setBorderWidth(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getBorderWidth())));
    }

    @LuaApiUsed
    public LuaValue[] borderColor(LuaValue[] p) {
        if (p.length == 1) {
            setBorderColor(((UDColor) p[0]).getColor());
            p[0].destroy();
            return null;
        }
        return varargsOf(new UDColor(globals, getBorderColor()));
    }

    @LuaApiUsed
    public LuaValue[] hidden(LuaValue[] var) {
        if (var.length == 1 && var[0].isBoolean()) {
            view.setVisibility(var[0].toBoolean() ? View.INVISIBLE : View.VISIBLE);
            return null;
        }
        return view.getVisibility() != View.VISIBLE ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] gone(LuaValue[] var) {
        if (var.length == 1 && var[0].isBoolean()) {
            view.setVisibility(var[0].toBoolean() ? View.GONE : View.VISIBLE);
            return null;
        }
        return view.getVisibility() == View.GONE ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] bgColor(LuaValue[] var) {
        if (var.length == 1 && AssertUtils.assertUserData(var[0], UDColor.class, "bgColor", getGlobals())) {
            setBgColor(((UDColor) var[0]).getColor());
            var[0].destroy();
            return null;
        }

        UDColor ret = new UDColor(getGlobals(), getBgColor());
        return varargsOf(ret);
    }

    @LuaApiUsed
    public LuaValue[] setNineImage(LuaValue[] var) {
        if (var.length == 1 && var[0].isString()) {
            hasNineImage = true;
            setBgDrawable(var[0].toJavaString());
            return null;
        }
        return rNil();
    }

    @LuaApiUsed
    public LuaValue[] cornerRadius(LuaValue[] var) {
        if (var.length == 1) {
            setCornerRadius(DimenUtil.dpiToPx(var[0]));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCornerRadiusWithDirections(RectCorner.TOP_LEFT))));
    }

    @LuaApiUsed
    public LuaValue[] getCornerRadiusWithDirection(LuaValue[] var) {
        int direction = RectCorner.TOP_LEFT;
        if (var.length == 1) {
            direction = var[0].toInt();
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCornerRadiusWithDirections(direction))));
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] addShadow(LuaValue[] var) {

        UDColor color = (UDColor) var[0];
        final UDSize offset = (UDSize) var[1];
        final float radius = DimenUtil.dpiToPx(var[2].toFloat());
        final float alpha = var[3].toFloat();
        final boolean isOval = var.length > 4 && var[4].toBoolean();

        IBorderRadiusView iBorderRadiusView = getIBorderRadiusView();
        if (iBorderRadiusView == null)
            return null;
        iBorderRadiusView.setAddShadow(color.getColor(), offset.getSize(), radius, alpha);

        ErrorUtils.debugDeprecateMethod("addShadow", "setShadow", getGlobals());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setShadow(LuaValue[] var) {

        final UDSize offset = (UDSize) var[0];
        final float radius = DimenUtil.dpiToPx(var[1].toFloat());
        final float alpha = var[2].toFloat();

        IBorderRadiusView iBorderRadiusView = getIBorderRadiusView();
        if (iBorderRadiusView == null)
            return null;
        iBorderRadiusView.setAddShadow(0, offset.getSize(), radius, alpha);

        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] refresh(LuaValue[] p) {
        ErrorUtils.debugUnsupportError("Method: refresh() is Deprecated");
        view.invalidate();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCornerRadiusWithDirection(LuaValue[] var) {
        int direction = RectCorner.ALL_CORNERS;
        if (var.length == 2) {
            direction = var[1].toInt();
        }
        setCornerRadiusWithDirection(DimenUtil.dpiToPx(var[0]), direction);
        return null;
    }

    protected void setCornerRadiusWithDirection(float radius, int direcion) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view == null)
            return;
        //控制圆角半径小于view最小长度
        float minLength = (getWidth() <= getHeight()) ? getWidth() : getHeight();
        if (minLength > 0 && radius > minLength / 2) {
            radius = minLength / 2;
        }
        view.setRadius(direcion, radius);

    }

    @LuaApiUsed
    public LuaValue[] addCornerMask(LuaValue[] var) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view == null)
            return null;
        int direction = RectCorner.ALL_CORNERS;
        if (var.length == 3) {
            direction = var[2].toInt();
        }
        view.setRadiusColor(((UDColor) var[1]).getColor());
        var[1].destroy();
        //控制圆角半径小于view最小长度
        float minLength = (getWidth() <= getHeight()) ? getWidth() : getHeight();
        float radius = var[0].toFloat();
        radius = radius <= 0 ? 0 : DimenUtil.dpiToPx(var[0]);
        if (minLength > 0 && radius > minLength / 2) {
            radius = minLength / 2;
        }
        view.setMaskRadius(direction, radius);
        return null;
    }

    /**
     * 建议使用{@link UDView#clipToChildren(LuaValue[])}，两端实现一致
     *
     * @param p
     * @return
     */
    @LuaApiUsed
    public LuaValue[] clipToBounds(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        ViewParent vp = view.getParent();
        if (view instanceof ViewGroup) {
            ((ViewGroup) view).setClipToPadding(clip);
            ((ViewGroup) view).setClipChildren(clip);
        }
        if (vp instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) vp;
            vg.setClipChildren(clip);
        }
        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP : LEVEL_FORCE_NOTCLIP);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] clipToChildren(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        if (view instanceof ViewGroup) {
            ((ViewGroup) view).setClipChildren(clip);
        }
//        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
//            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP : LEVEL_FORCE_NOTCLIP);
//        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] overlay(LuaValue[] p) {
        overView = p.length > 0 && !p[0].isNil() ? (UDView) p[0] : null;

        if (overContainer == null) {
            overContainer = new UDViewGroup(globals) {
                @Override
                protected ViewGroup newView(LuaValue[] init) {
                    return new LuaOverlayContainer(getContext(), this);
                }
            };

        }
        overContainer.padding(LuaValue.varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(mPaddingTop))
            , LuaNumber.valueOf(DimenUtil.pxToDpi(mPaddingRight))
            , LuaNumber.valueOf(DimenUtil.pxToDpi(mPaddingBottom))
            , LuaNumber.valueOf(DimenUtil.pxToDpi(mPaddingLeft))
        ));

        if (overView != null) {
            View view = overView.getView();
            if (view instanceof TextView) {//overContainer没有addView，导致label计算有问题，原因是Center时受下面的属性影响，文字宽度为VERY_WIDE = 1024 * 1024。
                ((TextView) view).setHorizontallyScrolling(false);
            }
        }
        overContainer.removeAllSubviews(null);
        overContainer.insertView(overView, -1);
        return null;
    }


    /**
     * call when getView is not null!
     *
     * @return
     */
    protected @Nullable
    IBorderRadiusView getIBorderRadiusView() {
        if (view instanceof IBorderRadiusView)
            return (IBorderRadiusView) view;
        return null;
    }

    public void setBorderWidth(final float borderWidth) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setStrokeWidth(borderWidth);
        }
    }

    public float getBorderWidth() {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            return view.getStrokeWidth();
        }
        return 0;
    }

    public void setBorderColor(int color) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setStrokeColor(color);
        }
    }

    public int getBorderColor() {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            return view.getStrokeColor();
        }
        return 0;
    }

    public void setBgColor(int color) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setBgColor(color);
        }
    }

    public void setBgDrawable(String src) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view == null || TextUtils.isEmpty(src)) {
            return;
        }
        ImageProvider provider = MLSAdapterContainer.getImageProvider();
        if (provider != null) {
            Drawable bgDrawable = provider.loadProjectImage(getContext(), src);
            view.setBgDrawable(bgDrawable);
            getView().invalidate();
        }
    }

    public int getBgColor() {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            return view.getBgColor();
        }
        return 0;
    }

    public void setCornerRadius(float r) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setCornerRadius(r);
        }
    }

    public float getCornerRadiusWithDirections(int direction) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            return view.getCornerRadiusWithDirection(direction);
        }
        return 0;
    }

    @LuaApiUsed
    public LuaValue[] setGradientColorWithDirection(LuaValue[] var) {
        int s = ((UDColor) var[0]).getColor();
        int e = ((UDColor) var[1]).getColor();
        var[0].destroy();
        var[1].destroy();
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setGradientColor(s, e, var[2].toInt());
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setGradientColor(LuaValue[] var) {
        int s = ((UDColor) var[0]).getColor();
        int e = ((UDColor) var[1]).getColor();
        var[0].destroy();
        var[1].destroy();
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setGradientColor(s, e, var[2].toBoolean() ? GradientType.TOP_TO_BOTTOM : GradientType.LEFT_TO_RIGHT);
        }
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] notClip(LuaValue[] p) {
        IBorderRadiusView view = getIBorderRadiusView();
        if (view != null) {
            view.setDrawRadiusBackground(p[0].toBoolean());
        }
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Interaction">
    @LuaApiUsed
    public LuaValue[] enabled(LuaValue[] var) {
        if (var.length == 1 && var[0].isBoolean()) {
            boolean enable = var[0].toBoolean();
            view.setEnabled(enable);
            return null;
        }
        return view.isEnabled() ? rTrue() : rFalse();
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] onTouch(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("Method: onTouch() is Deprecated");
        touchCallback = var[0].isFunction() ? var[0].toLuaFunction() : null;
        setTouch(touchCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] onClick(LuaValue[] var) {
        if (clickCallback != null) {
            clickCallback.destroy();
        }
        clickCallback = var[0].isFunction() ? var[0].toLuaFunction() : null;
        if (clickCallback != null) {
            view.setOnClickListener(clickListener);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] onLongPress(LuaValue[] var) {
        longClickCallback = var[0].isFunction() ? var[0].toLuaFunction() : null;
        if (longClickCallback != null) {
            view.setOnLongClickListener(longClickListener);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] hasFocus(LuaValue[] p) {
        return view.isFocused() ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] canFocus(LuaValue[] p) {
        return view.isFocusable() ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] requestFocus(LuaValue[] p) {
        view.requestFocus();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] cancelFocus(LuaValue[] p) {
        view.clearFocus();
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Animation">
    @LuaApiUsed
    public LuaValue[] startAnimation(LuaValue[] v) {
        final UDBaseAnimation anim = (UDBaseAnimation) v[0].toUserdata().getJavaUserdata();
        int delay = anim.getDelay();
        if (delay > 0) {
            final View view = getView();
            view.postDelayed(new Runnable() {
                @Override
                public void run() {
                    view.startAnimation(anim.getAnimation());
                }
            }, delay);
        }
        getView().startAnimation(anim.getAnimation());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] clearAnimation(LuaValue[] v) {
        getView().clearAnimation();
        return null;
    }

    // 设置背景图片，只支持本地资源  不能同bgColor 同时设置，否则会被后设置的覆盖
    @LuaApiUsed
    public LuaValue[] bgImage(LuaValue[] var) {
        if (var.length == 1) {
            String url = var[0].toJavaString();

            final ImageProvider provider = MLSAdapterContainer.getImageProvider();
            Drawable d = provider.loadProjectImage(getContext(), url);

            if (d != null) {
                getView().setBackground(d);
                return null;
            }

            // 陌陌主工程中本地图片路径，getAbsoluteUrl( file://avatar/large/2/2ur6wxA-4.jpg_ )  = /storage/emulated/0/immomo/avatar/large/2/2ur6wxA-4.jpg_
            if (RelativePathUtils.isLocalUrl(url)) {
                url = RelativePathUtils.getAbsoluteUrl(url);
                provider.preload(getContext(), url, null, initLoadCallback());
                return null;
            }

            String localUrl = getLuaViewManager().baseFilePath;
            if (!TextUtils.isEmpty(localUrl)) {
                File imgFile = new File(localUrl, url);
                if (imgFile.exists()) {
                    url = imgFile.getAbsolutePath();
                    provider.preload(getContext(), url, null, initLoadCallback());
                }
            }
        }
        return null;
    }

    //</editor-fold>
    //</editor-fold>

    @LuaApiUsed
    public LuaValue[] setPositionAdjustForKeyboard(LuaValue[] p) {
        deprecatedMethodPrint(UDView.class.getSimpleName(), "setPositionAdjustForKeyboard()");
        //do nothing
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setPositionAdjustForKeyboardAndOffset(LuaValue[] p) {
        deprecatedMethodPrint(UDView.class.getSimpleName(), "setPositionAdjustForKeyboardAndOffset()");
        //do nothing
        return null;
    }

    public void deprecatedMethodPrint(String className, String methodName) {
        if (!MLSEngine.DEBUG)
            return;
        String waringMsg = "Deprecated Method = " + className + "  " + methodName;

        if (getLuaViewManager().STDOUT != null) {
            getLuaViewManager().STDOUT.print(waringMsg);
            getLuaViewManager().STDOUT.println();
        }

        MLSAdapterContainer.getToastAdapter().toast(waringMsg);
    }

    private View.OnTouchListener touchListener = new View.OnTouchListener() {
        @Override
        public boolean onTouch(View v, MotionEvent event) {

            float xdp = DimenUtil.pxToDpi(event.getX());
            float ydp = DimenUtil.pxToDpi(event.getY());

            if (touchCallback != null) {
                touchCallback.fastInvoke(xdp, ydp);
            }

            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    if (touchBeginCallback != null)
                        touchBeginCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchBeginExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_MOVE:
                    if (touchMoveCallback != null)
                        touchMoveCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchMoveExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_UP:

                    if (touchEndCallback != null)
                        touchEndCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchEndExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_CANCEL:

                    if (touchCancelCallback != null)
                        touchCancelCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchCancelExtensionCallback, v, event);

                    break;
            }

            //View的ACTION_DOWN如果不消费，ACTION_UP就不会回调。且ACTION_DOWN会在松开手指时回调。
            //如果onTouch消费了事件，会拦截onClick事件。
            //因此：lua如果用了onClick，就返回false，让click去消费事件。不影响ACTION_DOWN和ACTION_UP
            if (clickCallback != null) {
                return false;
            }
            return true;
        }

        private void touchExtension2Lua(LuaFunction function, View v, MotionEvent event) {
            if (function != null) {

                if (mTouchEventExtensionMap == null)
                    mTouchEventExtensionMap = new HashMap();

                mTouchEventExtensionMap.clear();

                mTouchEventExtensionMap.put("pageX", DimenUtil.pxToDpi(event.getX()));
                mTouchEventExtensionMap.put("pageY", DimenUtil.pxToDpi(event.getY()));
                mTouchEventExtensionMap.put("screenX", DimenUtil.pxToDpi(event.getRawX()));
                mTouchEventExtensionMap.put("screenY", DimenUtil.pxToDpi(event.getRawY()));
                mTouchEventExtensionMap.put("target", v);
                mTouchEventExtensionMap.put("timeStamp", System.currentTimeMillis());

                function.invoke(varargsOf(ConvertUtils.toLuaValue(getGlobals(), mTouchEventExtensionMap)));
            }
        }

    };

    private View.OnClickListener clickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
//            if (!canDoClick())//IOS没有防抖动，Android也去掉
//                return;
            if (clickCallback != null) {
                clickCallback.fastInvoke();
            }
            if (canEndEditing) {
                InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
                View curFocusView = view.findFocus();
                if (curFocusView != null && im != null) {
                    im.hideSoftInputFromWindow(curFocusView.getWindowToken(),
                            InputMethodManager.HIDE_NOT_ALWAYS);
                }

            }
        }
    };

    private View.OnLongClickListener longClickListener = new View.OnLongClickListener() {
        @Override
        public boolean onLongClick(View v) {
            if (longClickCallback != null) {
                longClickCallback.fastInvoke();
                return true;
            }
            return false;
        }
    };

    protected ViewGroup.MarginLayoutParams newWrapContent() {
        return new ViewGroup.MarginLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    @LuaApiUsed
    public LuaValue[] convertRelativePointTo(LuaValue[] p) {
        return convertPointTo(p);
    }

    @LuaApiUsed
    public LuaValue[] convertPointTo(LuaValue[] p) {
        if (p.length != 2)
            return null;

        UDView toView = null;
        if (AssertUtils.assertUserData(p[0], UDView.class, "convertPointTo", getGlobals())) {
            toView = (UDView) p[0];
        }

        Point point = null;
        if (AssertUtils.assertUserData(p[1], UDPoint.class, "convertPointTo", getGlobals())) {
            point = ((UDPoint) p[1]).getPoint();
        }

        p[1].destroy();
        if (toView == null || point == null) {
            return null;
        }
        int[] curLocation = new int[2];
        view.getLocationInWindow(curLocation);
        int[] toLocation = new int[2];
        toView.view.getLocationInWindow(toLocation);
        Point result = new Point();
        result.setX(DimenUtil.pxToDpi(curLocation[0]) + point.getX() - DimenUtil.pxToDpi(toLocation[0]));
        result.setY(DimenUtil.pxToDpi(curLocation[1]) + point.getY() - DimenUtil.pxToDpi(toLocation[1]));
        return varargsOf(new UDPoint(getGlobals(), result));
    }

    @LuaApiUsed
    public LuaValue[] removeAllAnimation(LuaValue[] p) {
        stopAnimation();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] convertPointFrom(LuaValue[] p) {
        if (p.length != 2)
            return null;

        UDView fromView = null;
        if (AssertUtils.assertUserData(p[0], UDView.class, "convertPointFrom", getGlobals())) {
            fromView = (UDView) p[0];
        }

        Point point = ((UDPoint) p[1]).getPoint();
        p[1].destroy();
        if (fromView == null || point == null) {
            return null;
        }
        int[] fromViewLocation = new int[2];
        fromView.view.getLocationInWindow(fromViewLocation);
        int[] curLocation = new int[2];
        view.getLocationInWindow(curLocation);
        Point result = new Point();
        result.setX(DimenUtil.pxToDpi(fromViewLocation[0]) + point.getX() - DimenUtil.pxToDpi(curLocation[0]));
        result.setY(DimenUtil.pxToDpi(fromViewLocation[1]) + point.getY() - DimenUtil.pxToDpi(curLocation[1]));
        return varargsOf(new UDPoint(getGlobals(), result));
    }

    private int[] getMarginLeftTop(View view) {
        int[] curLocation = new int[0];
        if (view.getLayoutParams() instanceof ViewGroup.MarginLayoutParams) {
            curLocation[0] += ((ViewGroup.MarginLayoutParams) view.getLayoutParams()).leftMargin;
            curLocation[1] += ((ViewGroup.MarginLayoutParams) view.getLayoutParams()).topMargin;
        }
        if (view.getParent() != null && view.getParent() instanceof View) {
            int[] parentLocation = getMarginLeftTop((View) view.getParent());
            curLocation[0] += parentLocation[0];
            curLocation[1] += parentLocation[1];
        }
        return curLocation;
    }

    public void addFrameAnimation(Animator animator) {
        if (this.animatorCacheList == null) {
            this.animatorCacheList = new ArrayList<>();
        }
        this.animatorCacheList.add(animator);
    }

    public void stopAnimation() {
        if (animatorCacheList != null) {
            final ArrayList<Animator> temp = new ArrayList<>(animatorCacheList);
            animatorCacheList.clear();
            for (Animator animator : temp) {
                animator.cancel();
            }
        }
    }

    public void removeFrameAnimation(Animator anim) {
        if (animatorCacheList != null) {
            animatorCacheList.remove(anim);
        }
    }

    @Override
    public void onDetached() {
        if (detachFunction != null)
            detachFunction.fastInvoke();
        stopAnimation();
    }

    @LuaApiUsed
    public LuaValue[] onDetachedView(LuaValue[] p) {
        if (detachFunction != null)
            detachFunction.destroy();
        detachFunction = p[0].toLuaFunction();
        return null;
    }

    @Override
    public void onAttached() {

    }

    @LuaApiUsed
    public LuaValue[] touchBegin(LuaValue[] p) {
        if (touchBeginCallback != null)
            touchBeginCallback.destroy();
        touchBeginCallback = p[0].toLuaFunction();
        setTouch(touchBeginCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchMove(LuaValue[] p) {
        if (touchMoveCallback != null)
            touchMoveCallback.destroy();
        touchMoveCallback = p[0].toLuaFunction();
        setTouch(touchMoveCallback);
        return null;
    }


    @LuaApiUsed
    public LuaValue[] touchEnd(LuaValue[] p) {
        if (touchEndCallback != null)
            touchEndCallback.destroy();
        touchEndCallback = p[0].toLuaFunction();
        setTouch(touchEndCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchCancel(LuaValue[] p) {
        if (touchCancelCallback != null)
            touchCancelCallback.destroy();
        touchCancelCallback = p[0].toLuaFunction();
        setTouch(touchCancelCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchBeginExtension(LuaValue[] p) {
        if (touchBeginExtensionCallback != null)
            touchBeginExtensionCallback.destroy();
        touchBeginExtensionCallback = p[0].toLuaFunction();
        setTouch(touchBeginExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchMoveExtension(LuaValue[] p) {
        if (touchMoveExtensionCallback != null)
            touchMoveExtensionCallback.destroy();
        touchMoveExtensionCallback = p[0].toLuaFunction();
        setTouch(touchMoveExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchEndExtension(LuaValue[] p) {
        if (touchEndExtensionCallback != null)
            touchEndExtensionCallback.destroy();
        touchEndExtensionCallback = p[0].toLuaFunction();
        setTouch(touchEndExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchCancelExtension(LuaValue[] p) {
        if (touchCancelExtensionCallback != null)
            touchCancelExtensionCallback.destroy();
        touchCancelExtensionCallback = p[0].toLuaFunction();
        setTouch(touchCancelExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] snapshot(LuaValue[] p) {
        String path = captureScreenforRecord(p[0].toJavaString());
        return path != null ? rString(path) : rNil();
    }

    @LuaApiUsed
    public LuaValue[] onDraw(LuaValue[] values) {
        if (onDrawCallback != null) {
            onDrawCallback.destroy();
        }
        onDrawCallback = values.length > 0 && values[0].isFunction() ? values[0].toLuaFunction() : null;
        return null;
    }

    //<editor-fold desc="LayoutParams">

    /**
     * View 默认2K
     */
    @Override
    protected long memoryCast() {
        return 2 << 10;
    }


    @Override
    public void onDrawCallback(Canvas canvas) {
        if (onDrawCallback != null) {
            if (udCanvasTemp == null) {
                udCanvasTemp = new UDCanvas(getGlobals(), canvas);
            }
            udCanvasTemp.resetCanvas(canvas);
            onDrawCallback.invoke(varargsOf(udCanvasTemp));
        }
    }

    private void setTouch(LuaFunction fun) {
        if (fun != null) {
            view.setOnTouchListener(touchListener);
        }
    }

    public int getPaddingLeft() {
        return mPaddingLeft;
    }

    public int getPaddingTop() {
        return mPaddingTop;
    }

    public int getPaddingRight() {
        return mPaddingRight;
    }

    public int getPaddingBottom() {
        return mPaddingBottom;
    }

    /**
     * 对view截图
     */
    private String captureScreenforRecord(String fileName) {
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();

        Bitmap bm = Bitmap.createBitmap(view.getWidth(),
                view.getHeight(), Bitmap.Config.ARGB_8888);

        Canvas bigcanvas = new Canvas(bm);
        Paint paint = new Paint();
        int iHeight = bm.getHeight();
        bigcanvas.drawBitmap(bm, 0, iHeight, paint);
        view.draw(bigcanvas);

        String filePath = null;
        try {
            filePath = saveBitmap(bm, fileName);
        } catch (IOException e) {
            LogUtil.e(e);
        }

        return filePath;
    }

    private String saveBitmap(Bitmap bitmap, String fileName) throws IOException {
        File dir = FileUtil.getImageDir();
        if (!dir.exists()) {
            dir.mkdir();
        }

        File file = new File(FileUtil.getImageDir(), fileName);
        if (file.exists()) {
            file.delete();
        }

        FileOutputStream out;
        out = new FileOutputStream(file);

        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
        out.flush();
        out.close();

        return file.getPath();
    }

    public static class UDLayoutParams {
        /**
         * 这四个margin属性是给 普通容器使用的
         *
         * @see UDViewGroup
         */
        public int marginLeft;
        public int marginTop;
        public int marginRight;
        public int marginBottom;
        /**
         * 给普通容器使用
         *
         * @see UDViewGroup#insertView(UDView, int)
         */
        public float centerX = Float.NaN, centerY = Float.NaN;
        /**
         * 这四个margin属性是给线性布局使用
         *
         * @see UDLinearLayout
         * @see #setRealMargins
         */
        public int realMarginLeft;
        public int realMarginTop;
        public int realMarginRight;
        public int realMarginBottom;
        /**
         * 重力给线性布局使用
         *
         * @see UDLinearLayout#insertView(UDView, int)
         * @see #setRealMargins
         */
        public int gravity = Gravity.LEFT | Gravity.TOP;

        /**
         * 记录是否设置过gravity，因为gravity默认值不是-1，不好判断Left/Top
         */
        public boolean isSetGravity;

        /**
         * 普通容器判断是否使用gravity和realmargin
         *
         * @see UDViewGroup#insertView(UDView, int)
         */
        public boolean useRealMargin = true;
        /**
         * 优先级
         *
         * @see #priority(LuaValue[])
         * @see UDLinearLayout
         * @see LuaLinearLayout
         */
        public int priority = 0;
        /**
         * 权重
         *
         * @see #weight(LuaValue[])
         * @see UDLinearLayout
         * @see LuaLinearLayout
         */
        public int weight = 0;
    }
    //</editor-fold>

    private void getInitValue() {
        if (mInitTranslateX == -1)
            mInitTranslateX = view.getTranslationX();

        if (mInitTranslateY == -1)
            mInitTranslateY = view.getTranslationY();

        if (mInitScaleX == -1)
            mInitScaleX = view.getScaleX();

        if (mInitScaleY == -1)
            mInitScaleY = view.getScaleY();

        if (mInitRotation == -1)
            mInitRotation = view.getRotation();
    }

    @Override
    public String toString() {
        return view.getClass().getSimpleName() + "#" + view.hashCode();
    }

    DrawableLoadCallback drawableLoadCallback;

    private DrawableLoadCallback initLoadCallback() {

        if (drawableLoadCallback != null)
            return drawableLoadCallback;

        drawableLoadCallback = new DrawableLoadCallback() {
            @Override
            public void onLoadResult(final Drawable drawable, String errMsg) {
                if (drawable != null)
                    getView().setBackground(drawable);
            }
        };
        return drawableLoadCallback;
    }
}