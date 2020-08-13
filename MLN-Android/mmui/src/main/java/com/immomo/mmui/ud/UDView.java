/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

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
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.constants.RectCorner;
import com.immomo.mls.fun.lt.SICornerRadiusManager;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ud.anim.canvasanim.UDBaseAnimation;
import com.immomo.mls.fun.ud.view.IBorderRadiusView;
import com.immomo.mls.fun.ud.view.IClipRadius;
import com.immomo.mls.fun.ud.view.IRippleView;
import com.immomo.mls.fun.ui.LuaLinearLayout;
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
import com.immomo.mmui.ILView;
import com.immomo.mmui.TouchableView;
import com.immomo.mmui.weight.layout.IVirtualLayout;
import com.node.INode;

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

import static android.view.ViewGroup.LayoutParams;
import static android.view.ViewGroup.MarginLayoutParams;
import static android.view.ViewGroup.OnClickListener;
import static android.view.ViewGroup.OnLongClickListener;
import static android.view.ViewGroup.OnTouchListener;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public abstract class UDView<V extends View, N extends INode> extends JavaUserdata<V> implements ILView.ViewLifeCycleCallback, TouchableView {
    public static final String LUA_CLASS_NAME = "__BaseView";
    public static final String[] methods = new String[]{
        "anchorPoint",
        "removeFromSuper",
        "superview",
        "addBlurEffect",
        "removeBlurEffect",
        "openRipple",
        "transformIdentity",
        "rotation",
        "translation",
        "scale",
        "canEndEditing",
        "alpha",
        "borderWidth",
        "borderColor",
        "bgColor",
        "setNineImage",
        "cornerRadius",
        "setCornerRadiusWithDirection",
        "addCornerMask",
        "clipToBounds",
        "setGradientColorWithDirection",
        "setGradientColor",
        "notClip",
        "enabled",
        "hidden",
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
        "setShadow",
        "removeAllAnimation",
        "onDraw",
        "onDetachedView",
        "clipToChildren",
        "setGravity",
        "keyboardDismiss",
        "centerX",
        "centerY",
        "layoutComplete",
        "viewWidth",
        "viewHeight",
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
    private LuaFunction layoutComplete;

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
    private boolean canEndEditing, keyboardDismiss;

    private final static short FLAG_ONCLICK_SET = 1;//onclick
    private final static short FLAG_CANENDEDITING_SET = 1 << 1;//canEndEditing
    private final static short FLAG_KEYBOARDDISMISS_SET = 1 << 2;//keyboardDismiss
    private short propersFlags;//属性标记

    protected boolean hasNineImage = false;//是否添加点9图

    protected int mPaddingLeft    ;
    protected int mPaddingTop     ;
    protected int mPaddingRight   ;
    protected int mPaddingBottom;

    private boolean allowVirtual = true;//是否允许使用虚拟布局，不代表是虚拟布局

    protected final @NonNull
    V view;

    protected @NonNull
    N mNode;

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
        this.mNode = initNode();
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
        this.mNode = initNode();
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
        this.mNode = initNode();
        checkView();
        initClipConfig();
        javaUserdata = view;
    }

    protected @NonNull
    abstract V newView(@NonNull LuaValue[] init);

    protected @NonNull
    abstract N initNode();
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

    public V getView() {
        return view;
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    protected void checkSize(double src) {
        if (src >= 0)
            return;
        if (src == MeasurementType.MATCH_PARENT || src == MeasurementType.WRAP_CONTENT)
            return;
        if (Float.isNaN((float) src))
            return;
        ErrorUtils.debugLuaError("size must be set with positive number, error number: " + src + ".", getGlobals());
    }

    protected abstract void setWidth(float w);

    public abstract int getWidth();

    protected abstract void setHeight(float h);

    public abstract int getHeight();

    @LuaApiUsed
    public LuaValue[] anchorPoint(LuaValue[] p) {
        //TODO YOGA
        float x = (float) p[0].toDouble();
        float y = (float) p[1].toDouble();

        int width = getWidth();
        int height = getHeight();

        LayoutParams params = view.getLayoutParams();

        if (params != null && view.getParent() instanceof ViewGroup && ((ViewGroup) view.getParent()).getLayoutParams() != null) {

            if (width == 0 && params.width == LayoutParams.MATCH_PARENT)
                width = ((ViewGroup) view.getParent()).getLayoutParams().width;

            if (height == 0 && params.height == LayoutParams.MATCH_PARENT)
                height = ((ViewGroup) view.getParent()).getLayoutParams().height;
        }


        if (x >= 0 && x <= 1 && width != 0)
            view.setPivotX(width * x);

        if (y >= 0 && y <= 1 && height != 0)
            view.setPivotY(height * y);
        allowVirtual = false;
        return null;
    }

    //</editor-fold>

    //<editor-fold desc="Method">
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
        return LuaValue.rNil();
    }


    @LuaApiUsed
    public LuaValue[] addBlurEffect(LuaValue[] p) {
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeBlurEffect(LuaValue[] p) {
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] openRipple(LuaValue[] var) {
        if (view instanceof IRippleView) {
            ((IRippleView) view).setDrawRipple(var[0].toBoolean());
        }
        allowVirtual = false;
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
        allowVirtual = false;
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
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] translation(LuaValue[] var) {
        float xTranslate = (float) var[0].toDouble();
        float yTranslate = (float) var[1].toDouble();
        boolean notNeedAdding = var.length > 2 && var[2].toBoolean();

        getInitValue();

        if (notNeedAdding) {
            view.setTranslationX(DimenUtil.dpiToPx(xTranslate));
            view.setTranslationY(DimenUtil.dpiToPx(yTranslate));
        } else {
            view.setTranslationX(view.getTranslationX() + DimenUtil.dpiToPx(xTranslate));
            view.setTranslationY(view.getTranslationY() + DimenUtil.dpiToPx(yTranslate));
        }
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] scale(LuaValue[] var) {
        float xScale = Math.abs((float) var[0].toDouble());
        float yScale = Math.abs((float) var[1].toDouble());
        boolean notNeedAdding = var.length > 2 && var[2].toBoolean();

        getInitValue();

        if (notNeedAdding) {
            view.setScaleX(xScale);
            view.setScaleY(yScale);
        } else {
            view.setScaleX(view.getScaleX() * xScale);
            view.setScaleY(view.getScaleY() * yScale);
        }
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] canEndEditing(LuaValue[] p) {
        if (p != null && p.length > 0 && p[0].isBoolean()) {
            canEndEditing = p[0].toBoolean();
            if (canEndEditing) {
                propersFlags |= FLAG_CANENDEDITING_SET;
                view.setOnClickListener(clickListener);
            }
        }
        allowVirtual = false;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] keyboardDismiss(LuaValue[] p) {
        if (p != null && p.length > 0 && p[0].isBoolean()) {
            keyboardDismiss = p[0].toBoolean();
            if (keyboardDismiss) {
                propersFlags |= FLAG_KEYBOARDDISMISS_SET;
                view.setOnClickListener(clickListener);
            } else if (!hasCanEndEditing() && !hasClick() && hasKeyboardDismiss()){
                propersFlags &= FLAG_KEYBOARDDISMISS_SET;
                view.setOnClickListener(null);
            }
        }
        allowVirtual = false;
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Render">
    @LuaApiUsed
    public LuaValue[] alpha(LuaValue[] p) {
        allowVirtual = false;
        if (p.length == 1) {
            view.setAlpha((float) p[0].toDouble());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(view.getAlpha()));
    }

    @LuaApiUsed
    public LuaValue[] borderWidth(LuaValue[] p) {
        allowVirtual = false;
        if (p.length == 1) {
            setBorderWidth(DimenUtil.dpiToPx((float) p[0].toDouble()));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getBorderWidth())));
    }

    @LuaApiUsed
    public LuaValue[] borderColor(LuaValue[] p) {
        allowVirtual = false;
        if (p.length == 1) {
            setBorderColor(((UDColor) p[0]).getColor());
            p[0].destroy();
            return null;
        }
        return varargsOf(new UDColor(globals, getBorderColor()));
    }

    @LuaApiUsed
    public LuaValue[] bgColor(LuaValue[] var) {
        allowVirtual = false;
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
        allowVirtual = false;
        if (var.length == 1 && var[0].isString()) {
            hasNineImage = true;
            setBgDrawable(var[0].toJavaString());
            return null;
        }
        return rNil();
    }

    @LuaApiUsed
    public LuaValue[] cornerRadius(LuaValue[] var) {
        allowVirtual = false;
        if (var.length == 1) {
            setCornerRadius(DimenUtil.dpiToPx(var[0]));
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCornerRadiusWithDirections(RectCorner.TOP_LEFT))));
    }

    @LuaApiUsed
    public LuaValue[] getCornerRadiusWithDirection(LuaValue[] var) {
        allowVirtual = false;
        int direction = RectCorner.TOP_LEFT;
        if (var.length == 1) {
            direction = var[0].toInt();
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCornerRadiusWithDirections(direction))));
    }

    @LuaApiUsed
    public LuaValue[] setShadow(LuaValue[] var) {
        allowVirtual = false;
        final UDSize offset = (UDSize) var[0];
        final float radius = DimenUtil.dpiToPx(var[1].toFloat());
        final float alpha = var[2].toFloat();

        IBorderRadiusView iBorderRadiusView = getIBorderRadiusView();
        if (iBorderRadiusView == null)
            return null;
        iBorderRadiusView.setAddShadow(0, offset.getSize(), radius, alpha);

        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCornerRadiusWithDirection(LuaValue[] var) {
        allowVirtual = false;
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
        allowVirtual = false;
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
        allowVirtual = false;
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
        allowVirtual = false;
        boolean clip = p[0].toBoolean();
        if (view instanceof ViewGroup) {
            ((ViewGroup) view).setClipChildren(clip);
        }
//        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
//            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP : LEVEL_FORCE_NOTCLIP);
//        }
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] setGravity(LuaValue[] p) {
        return null;
    }


    @LuaApiUsed
    public LuaValue[] centerX(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("centerX", globals);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterX())));
    }

    public float getCenterX() {
        if (!Float.isNaN(udLayoutParams.centerX))
            return udLayoutParams.centerX;
        return (getView().getX() + getWidth() / 2.0f);
    }

    @LuaApiUsed
    public LuaValue[] layoutComplete(LuaValue[] values) {
        if (layoutComplete != null)
            layoutComplete.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            layoutComplete = value.toLuaFunction();
            setLayoutComplete();
        }
        return null;
    }

    private void setLayoutComplete() {
        view.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                layoutComplete.invoke(varargsOf(LuaValue.rNil()));
                view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
        });
    }

    @LuaApiUsed
    public LuaValue[] centerY(LuaValue[] p) {
        if (p.length == 1) {
            ErrorUtils.debugDeprecatedSetter("centerY", globals);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getCenterY())));
    }

    public float getCenterY() {
        if (!Float.isNaN(udLayoutParams.centerY))
            return udLayoutParams.centerY;
        return getView().getY() + getHeight() / 2.0f;
    }

    //隐藏方法，给新动画使用
    @LuaApiUsed
    public LuaValue[] viewWidth(LuaValue[] p) {
        if (p.length > 0) {
            getView().setRight(getView().getLeft() + DimenUtil.dpiToPx(p[0].toInt()));
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] viewHeight(LuaValue[] p) {
        if (p.length > 0) {
            getView().setBottom(getView().getTop() + DimenUtil.dpiToPx(p[0].toInt()));
        }
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
        allowVirtual = false;
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
        allowVirtual = false;
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
        allowVirtual = false;
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
        allowVirtual = false;
        if (var.length == 1 && var[0].isBoolean()) {
            boolean enable = var[0].toBoolean();
            view.setEnabled(enable);
            return null;
        }
        return view.isEnabled() ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] hidden(LuaValue[] var) {
        allowVirtual = false;
        if (var.length == 1 && var[0].isBoolean()) {
            view.setVisibility(var[0].toBoolean() ? View.INVISIBLE : View.VISIBLE);
            return null;
        }
        return view.getVisibility() != View.VISIBLE ? rTrue() : rFalse();
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] onTouch(LuaValue[] var) {
        allowVirtual = false;
        ErrorUtils.debugUnsupportError("Method: onTouch() is Deprecated");
        touchCallback = var[0].isFunction() ? var[0].toLuaFunction() : null;
        setTouch(touchCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] onClick(LuaValue[] var) {
        allowVirtual = false;
        if (clickCallback != null) {
            clickCallback.destroy();
        }
        clickCallback = var[0].isFunction() ? var[0].toLuaFunction() : null;
        if (clickCallback != null) {
            propersFlags |= FLAG_ONCLICK_SET;
            view.setOnClickListener(clickListener);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] onLongPress(LuaValue[] var) {
        allowVirtual = false;
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
        allowVirtual = false;
        view.requestFocus();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] cancelFocus(LuaValue[] p) {
        allowVirtual = false;
        view.clearFocus();
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Animation">
    @LuaApiUsed
    public LuaValue[] startAnimation(LuaValue[] v) {
        allowVirtual = false;
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
        allowVirtual = false;
        getView().clearAnimation();
        return null;
    }

    // 设置背景图片，只支持本地资源  不能同bgColor 同时设置，否则会被后设置的覆盖
    @LuaApiUsed
    public LuaValue[] bgImage(LuaValue[] var) {
        allowVirtual = false;
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
        allowVirtual = false;
        deprecatedMethodPrint(UDView.class.getSimpleName(), "setPositionAdjustForKeyboard()");
        //do nothing
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setPositionAdjustForKeyboardAndOffset(LuaValue[] p) {
        allowVirtual = false;
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

    private List<OnTouchListener> touchListeners;
    private OnTouchListener touchListener = new OnTouchListener() {
        private boolean notifyTouchListeners(View v, MotionEvent event) {
            if (touchListeners != null) {
                for (OnTouchListener l : touchListeners) {
                    if (l.onTouch(v, event))
                        return true;
                }
            }
            return false;
        }
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            if (notifyTouchListeners(v, event))
                return true;

            float xdp = DimenUtil.pxToDpi(event.getX());
            float ydp = DimenUtil.pxToDpi(event.getY());

            if (touchCallback != null) {
                touchCallback.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(ydp)));
            }

            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    if (touchBeginCallback != null)
                        touchBeginCallback.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(DimenUtil.pxToDpi(event.getY()))));

                    touchExtension2Lua(touchBeginExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_MOVE:
                    if (touchMoveCallback != null)
                        touchMoveCallback.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(ydp)));

                    touchExtension2Lua(touchMoveExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_UP:

                    if (touchEndCallback != null)
                        touchEndCallback.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(ydp)));

                    touchExtension2Lua(touchEndExtensionCallback, v, event);

                    break;

                case MotionEvent.ACTION_CANCEL:

                    if (touchCancelCallback != null)
                        touchCancelCallback.invoke(varargsOf(LuaNumber.valueOf(xdp), LuaNumber.valueOf(ydp)));

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

    private OnClickListener clickListener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            if (clickCallback != null) {
                clickCallback.invoke(null);
            }
            if (canEndEditing) {
                InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
                View curFocusView = view.findFocus();
                if (curFocusView != null && im != null) {
                    im.hideSoftInputFromWindow(curFocusView.getWindowToken(),
                        InputMethodManager.HIDE_NOT_ALWAYS);
                }

            }

            if (keyboardDismiss) {// 区别于canEndEditing, 任意view都可以收起键盘
                InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
                if (im != null) {
                    im.hideSoftInputFromWindow(view.getWindowToken(),
                        InputMethodManager.HIDE_NOT_ALWAYS);
                }
            }
        }
    };

    private OnLongClickListener longClickListener = new OnLongClickListener() {
        @Override
        public boolean onLongClick(View v) {
            if (longClickCallback != null) {
                longClickCallback.invoke(null);
                return true;
            }
            return false;
        }
    };

    protected MarginLayoutParams newWrapContent() {
        return new MarginLayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    }

    @LuaApiUsed
    public LuaValue[] convertRelativePointTo(LuaValue[] p) {
        allowVirtual = false;
        return convertPointTo(p);
    }

    @LuaApiUsed
    public LuaValue[] convertPointTo(LuaValue[] p) {
        allowVirtual = false;
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
        allowVirtual = false;
        stopAnimation();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] convertPointFrom(LuaValue[] p) {
        allowVirtual = false;
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
        if (view.getLayoutParams() instanceof MarginLayoutParams) {
            curLocation[0] += ((MarginLayoutParams) view.getLayoutParams()).leftMargin;
            curLocation[1] += ((MarginLayoutParams) view.getLayoutParams()).topMargin;
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
            detachFunction.invoke(null);
        stopAnimation();
    }

    @LuaApiUsed
    public LuaValue[] onDetachedView(LuaValue[] p) {
        allowVirtual = false;
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
        allowVirtual = false;
        if (touchBeginCallback != null)
            touchBeginCallback.destroy();
        touchBeginCallback = p[0].toLuaFunction();
        setTouch(touchBeginCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchMove(LuaValue[] p) {
        allowVirtual = false;
        if (touchMoveCallback != null)
            touchMoveCallback.destroy();
        touchMoveCallback = p[0].toLuaFunction();
        setTouch(touchMoveCallback);
        return null;
    }


    @LuaApiUsed
    public LuaValue[] touchEnd(LuaValue[] p) {
        allowVirtual = false;
        if (touchEndCallback != null)
            touchEndCallback.destroy();
        touchEndCallback = p[0].toLuaFunction();
        setTouch(touchEndCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchCancel(LuaValue[] p) {
        allowVirtual = false;
        if (touchCancelCallback != null)
            touchCancelCallback.destroy();
        touchCancelCallback = p[0].toLuaFunction();
        setTouch(touchCancelCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchBeginExtension(LuaValue[] p) {
        allowVirtual = false;
        if (touchBeginExtensionCallback != null)
            touchBeginExtensionCallback.destroy();
        touchBeginExtensionCallback = p[0].toLuaFunction();
        setTouch(touchBeginExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchMoveExtension(LuaValue[] p) {
        allowVirtual = false;
        if (touchMoveExtensionCallback != null)
            touchMoveExtensionCallback.destroy();
        touchMoveExtensionCallback = p[0].toLuaFunction();
        setTouch(touchMoveExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchEndExtension(LuaValue[] p) {
        allowVirtual = false;
        if (touchEndExtensionCallback != null)
            touchEndExtensionCallback.destroy();
        touchEndExtensionCallback = p[0].toLuaFunction();
        setTouch(touchEndExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchCancelExtension(LuaValue[] p) {
        allowVirtual = false;
        if (touchCancelExtensionCallback != null)
            touchCancelExtensionCallback.destroy();
        touchCancelExtensionCallback = p[0].toLuaFunction();
        setTouch(touchCancelExtensionCallback);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] snapshot(LuaValue[] p) {
        allowVirtual = false;
        String path = captureScreenforRecord(p[0].toJavaString());
        return path != null ? rString(path) : rNil();
    }

    @LuaApiUsed
    public LuaValue[] onDraw(LuaValue[] values) {
        allowVirtual = false;
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

    public void addOnTouchListener(View.OnTouchListener l) {
        if (touchListeners == null)
            touchListeners = new ArrayList<>(1);
        if (!touchListeners.contains(l))
            touchListeners.add(l);
        view.setOnTouchListener(touchListener);
    }

    public void removeOnTouchListener(View.OnTouchListener l) {
        if (touchListeners != null)
            touchListeners.remove(l);
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
     * 需要转换为虚拟layout
     * @return 默认不允许，需要子类重写此方法
     */
    public boolean needConvertVirtual() {
        return false;
    }

    //是否允许使用虚拟布局，不代表是虚拟布局
    public boolean isAllowVirtual() {
        return allowVirtual;
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

    //调用了onclick
    public boolean hasClick() {
        return (propersFlags & FLAG_ONCLICK_SET) == FLAG_ONCLICK_SET;
    }

    //调用了onclick
    public boolean hasCanEndEditing() {
        return (propersFlags & FLAG_CANENDEDITING_SET) == FLAG_CANENDEDITING_SET;
    }

    //调用了onclick
    public boolean hasKeyboardDismiss() {
        return (propersFlags & FLAG_KEYBOARDDISMISS_SET) == FLAG_KEYBOARDDISMISS_SET;
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
         */
        public int realMarginLeft;
        public int realMarginTop;
        public int realMarginRight;
        public int realMarginBottom;
        /**
         * 重力给线性布局使用
         *
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
         * @see LuaLinearLayout
         */
        public int priority = 0;
        /**
         * 权重
         *
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
            public void onLoadResult(Drawable drawable, String errMsg) {
                if (drawable != null)
                    getView().setBackground(drawable);
            }
        };
        return drawableLoadCallback;
    }
}