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
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.yoga.FlexNode;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaDisplay;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.YogaJustify;
import com.facebook.yoga.YogaNodeFactory;
import com.facebook.yoga.YogaPositionType;
import com.facebook.yoga.YogaUnit;
import com.facebook.yoga.YogaValue;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
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
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILView;
import com.immomo.mmui.TouchableView;
import com.immomo.mmui.gesture.ICompose;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IYogaGroup;
import com.immomo.mmui.weight.layout.NodeLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static android.view.ViewGroup.LayoutParams;
import static android.view.ViewGroup.MarginLayoutParams;
import static android.view.ViewGroup.OnTouchListener;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;

/**
 * Created by XiongFangyu on 2018/7/31.
 * java -jar mlncgen.jar -module mmui -class com.immomo.mmui.ud.UDView -jni bridge -name mmview.c
 */
@LuaApiUsed
public abstract class UDView<V extends View & ILView> extends JavaUserdata<V> implements ILView.ViewLifeCycleCallback, TouchableView, IFlexLayout{
    public static final String LUA_CLASS_NAME = "__BaseView";
    public static final String[] methods = new String[]{
        "minWidth",
        "maxWidth",
        "minWidthPercent",
        "maxWidthPercent",

        "minHeight",
        "maxHeight",
        "minHeightPercent",
        "maxHeightPercent",

        "anchorPoint",
        "removeFromSuper",
        "superview",
        "addBlurEffect",
        "removeBlurEffect",
        "openRipple",
        "transformIdentity",
        "canEndEditing",
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
        "enabled",
        "hidden",
        "hasFocus",
        "canFocus",
        "requestFocus",
        "cancelFocus",
        "convertRelativePointTo",
        "convertPointTo",
        "convertPointFrom",
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
        "keyboardDismiss",
        "layoutComplete",
        "notDispatch",
    };

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    //normal props
    private static final int MIN_WIDTH = 7;
    private static final int MAX_WIDTH = 8;
    private static final int MIN_WIDTH_PERCENT = 9;
    private static final int MAX_WIDTH_PERCENT = 10;

    private static final int MIN_HEIGHT = 13;
    private static final int MAX_HEIGHT = 14;
    private static final int MIN_HEIGHT_PERCENT = 15;
    private static final int MAX_HEIGHT_PERCENT = 16;

    private List<Animator> animatorCacheList;

    private LuaFunction clickCallback;
    private LuaFunction longClickCallback;
    private LuaFunction detachFunction;

    // 配合 IOS 添加
    private TouchLuaFunction touchBeginCallback, touchMoveCallback, touchEndCallback, touchCancelCallback,
            touchBeginExtensionCallback, touchMoveExtensionCallback, touchEndExtensionCallback, touchCancelExtensionCallback;

    private TouchLuaFunction scaleBeginCallback, scalingCallback, scaleEndCallback;

    private LuaFunction layoutComplete;

    protected LuaFunction onDrawCallback;
    protected UDCanvas udCanvasTemp;//缓存onDraw()的canvas，防止频繁创建

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
    private Boolean isNotDispatch = null;//设置事件是否向子view传递
    private boolean isTouchChange = false;//设置是否改变事件流
    private boolean childFirstHandlePointers = false; //设置是否子View需要强制处理多指操作
    private boolean needHandlePointers = false;//设置是否需要处理多指
    private GestureDetector gestureDetector;
    private boolean click;
    private ScaleGestureDetector scaleGestureDetector;
    private Matrix scaleMatrix;

    protected final @NonNull
    V view;

    protected @NonNull
    FlexNode mNode;

    //<editor-fold desc="constructor">
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
    //</editor-fold>

    protected @NonNull
    abstract V newView(@NonNull LuaValue[] init);

    //<editor-fold desc="view default setting">
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
    //</editor-fold>

    //<editor-fold desc="public">

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
    //</editor-fold>

    //<editor-fold desc="NODE">
    protected FlexNode initNode() {
        FlexNode node;
        if (getView() instanceof IFlexLayout) {
            node = ((IFlexLayout) getView()).getFlexNode();
        } else {
            node = YogaNodeFactory.create();
            node.setMeasureFunction(new NodeLayout.ViewMeasureFunction());
        }
        //初始化默认属性
        node.setJustifyContent(YogaJustify.FLEX_START);
        node.setAlignItems(YogaAlign.FLEX_START);
        node.setAlignContent(YogaAlign.FLEX_START);
        return node;
    }

    public FlexNode getFlexNode() {
        return mNode;
    }
    //</editor-fold>

    //<editor-fold desc="view node width height">

    protected void setWidth(float w) {
        mNode.setWidth(w);
    }

    public int getWidth() {
        YogaValue yogaValue = mNode.getWidth();
        if (yogaValue.unit == YogaUnit.POINT && yogaValue.value > 0) {
            return (int) yogaValue.value;
        }

        int w = (int) mNode.getLayoutWidth();
        if (w > 0) {
            return w;
        }

        return view.getWidth();
    }

    protected void setHeight(float h) {
        mNode.setHeight(h);
    }

    public int getHeight() {
        YogaValue yogaValue = mNode.getHeight();
        if (yogaValue.unit == YogaUnit.POINT && yogaValue.value > 0) {
            return (int) yogaValue.value;
        }

        int w = (int) mNode.getLayoutHeight();
        if (w > 0) {
            return w;
        }

        return view.getHeight();
    }
    //</editor-fold>

    //<editor-fold desc="API">
    //<editor-fold desc="width height">
    //处理width、height 及其percent、max、min方法
    private LuaValue[] handlerNormalProps(int methodType, LuaValue[] var) {
        if (var.length > 0) {
            switch (methodType) {
                case MIN_WIDTH:
                    mNode.setMinWidth(DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case MAX_WIDTH:
                    mNode.setMaxWidth(DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case MIN_WIDTH_PERCENT:
                    mNode.setMinWidthPercent(var[0].toFloat());
                    break;
                case MAX_WIDTH_PERCENT:
                    mNode.setMaxWidthPercent(var[0].toFloat());
                    break;
                case MIN_HEIGHT:
                    mNode.setMinHeight(DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case MAX_HEIGHT:
                    mNode.setMaxHeight(DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case MIN_HEIGHT_PERCENT:
                    mNode.setMinHeightPercent(var[0].toFloat());
                    break;
                case MAX_HEIGHT_PERCENT:
                    mNode.setMaxHeightPercent(var[0].toFloat());
                    break;
            }
            view.requestLayout();
            return null;
        }

        YogaValue yogaValue;
        YogaUnit methodUnit;
        switch (methodType) {
            case MIN_WIDTH:
                yogaValue = mNode.getMinWidth();
                methodUnit = YogaUnit.POINT;
                break;
            case MAX_WIDTH:
                yogaValue = mNode.getMaxWidth();
                methodUnit = YogaUnit.POINT;
                break;
            case MIN_WIDTH_PERCENT:
                yogaValue = mNode.getMinWidth();
                methodUnit = YogaUnit.PERCENT;
                break;
            case MAX_WIDTH_PERCENT:
                yogaValue = mNode.getMaxWidth();
                methodUnit = YogaUnit.PERCENT;
                break;
            case MIN_HEIGHT:
                yogaValue = mNode.getMinHeight();
                methodUnit = YogaUnit.POINT;
                break;
            case MAX_HEIGHT:
                yogaValue = mNode.getMaxHeight();
                methodUnit = YogaUnit.POINT;
                break;
            case MIN_HEIGHT_PERCENT:
                yogaValue = mNode.getMinHeight();
                methodUnit = YogaUnit.PERCENT;
                break;
            case MAX_HEIGHT_PERCENT:
                yogaValue = mNode.getMaxHeight();
                methodUnit = YogaUnit.PERCENT;
                break;
            default:
                return null;
        }
        return LuaNumber.rNumber(yogaValue(yogaValue, methodUnit));
    }

    @LuaApiUsed
    public LuaValue[] minWidth(LuaValue[] varargs) {
        return handlerNormalProps(MIN_WIDTH, varargs);
    }

    @LuaApiUsed
    public LuaValue[] minWidthPercent(LuaValue[] varargs) {
        return handlerNormalProps(MIN_WIDTH_PERCENT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] maxWidth(LuaValue[] varargs) {
        return handlerNormalProps(MAX_WIDTH, varargs);
    }

    @LuaApiUsed
    public LuaValue[] maxWidthPercent(LuaValue[] varargs) {
        return handlerNormalProps(MAX_WIDTH_PERCENT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] minHeight(LuaValue[] varargs) {
        return handlerNormalProps(MIN_HEIGHT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] minHeightPercent(LuaValue[] varargs) {
        return handlerNormalProps(MIN_HEIGHT_PERCENT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] maxHeight(LuaValue[] varargs) {
        return handlerNormalProps(MAX_HEIGHT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] maxHeightPercent(LuaValue[] varargs) {
        return handlerNormalProps(MAX_HEIGHT_PERCENT, varargs);
    }
    //</editor-fold>

    protected void checkSize(double src) {
        if (src >= 0)
            return;
        if (src == MeasurementType.MATCH_PARENT || src == MeasurementType.WRAP_CONTENT)
            return;
        if (Float.isNaN((float) src))
            return;
        ErrorUtils.debugLuaError("size must be set with positive number, error number: " + src + ".", getGlobals());
    }

    //<editor-fold desc="native">

    //叶子节点（原生组件如：Label、ImageView），需要设置view的padding
    protected void setLeanPadding() {
        view.setPadding(
                mPaddingLeft,
                mPaddingTop,
                mPaddingRight,
                mPaddingBottom);
    }

    private float yogaValue(YogaValue yv, YogaUnit unit) {
        float ret = 0;
        if (yv != null && yv.unit == unit) {
            ret = yv.value;
        }
        if (unit == YogaUnit.POINT)
            ret = DimenUtil.pxToDpi(ret);
        return ret;
    }

    //<editor-fold desc="width height">
    @LuaApiUsed
    public double getX() {
        return DimenUtil.pxToDpi(view.getX());
    }

    @LuaApiUsed
    public double getY() {
        return DimenUtil.pxToDpi(view.getY());
    }

    @LuaApiUsed
    public void nSetWidth(double d) {
        checkSize(d);
        setWidth(DimenUtil.dpiToPx(d));
    }

    @LuaApiUsed
    public double nGetWidth() {
        return DimenUtil.pxToDpi(getWidth());
    }

    @LuaApiUsed
    public void setWidthPercent(float p) {
        mNode.setWidthPercent(p);
    }

    @LuaApiUsed
    public float getWidthPercent() {
        return yogaValue(mNode.getWidth(), YogaUnit.PERCENT);
    }

    @LuaApiUsed
    public void widthAuto() {
        mNode.setWidthAuto();
        view.requestLayout();
    }

    @LuaApiUsed
    public void nSetHeight(double d) {
        checkSize(d);
        setHeight(DimenUtil.dpiToPx(d));
    }

    @LuaApiUsed
    public double nGetHeight() {
        return DimenUtil.pxToDpi(getHeight());
    }

    @LuaApiUsed
    public void setHeightPercent(float p) {
        mNode.setHeightPercent(p);
    }

    @LuaApiUsed
    public float getHeightPercent() {
        return yogaValue(mNode.getHeight(), YogaUnit.PERCENT);
    }

    @LuaApiUsed
    public void heightAuto() {
        mNode.setHeightAuto();
        view.requestLayout();
    }
    //</editor-fold>

    //<editor-fold desc="margin">

    @LuaApiUsed
    public double getMarginLeft() {
        return yogaValue(mNode.getMargin(YogaEdge.LEFT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMarginLeft(double marginLeft) {
        mNode.setMargin(YogaEdge.LEFT, DimenUtil.dpiToPx(marginLeft));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getMarginTop() {
        return yogaValue(mNode.getMargin(YogaEdge.TOP), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMarginTop(double marginTop) {
        mNode.setMargin(YogaEdge.TOP, DimenUtil.dpiToPx(marginTop));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getMarginRight() {
        return yogaValue(mNode.getMargin(YogaEdge.RIGHT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMarginRight(double marginRight) {
        mNode.setMargin(YogaEdge.RIGHT, DimenUtil.dpiToPx(marginRight));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getMarginBottom() {
        return yogaValue(mNode.getMargin(YogaEdge.BOTTOM), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMarginBottom(double marginBottom) {
        mNode.setMargin(YogaEdge.BOTTOM, DimenUtil.dpiToPx(marginBottom));
        view.requestLayout();
    }

    @LuaApiUsed
    public void margin(double t, double r, double b, double l) {
        mNode.setMargin(YogaEdge.TOP, DimenUtil.dpiToPx(t));
        mNode.setMargin(YogaEdge.RIGHT, DimenUtil.dpiToPx(r));
        mNode.setMargin(YogaEdge.BOTTOM, DimenUtil.dpiToPx(b));
        mNode.setMargin(YogaEdge.LEFT, DimenUtil.dpiToPx(l));
        view.requestLayout();
    }
    //</editor-fold>

    //<editor-fold desc="padding">

    @LuaApiUsed
    public double nGetPaddingLeft() {
        return yogaValue(mNode.getPadding(YogaEdge.LEFT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void nSetPaddingLeft(double paddingLeft) {
        mPaddingLeft = DimenUtil.dpiToPx(paddingLeft);
        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        mNode.setPadding(YogaEdge.LEFT, DimenUtil.dpiToPx(paddingLeft));
        view.requestLayout();
    }

    @LuaApiUsed
    public double nGetPaddingTop() {
        return yogaValue(mNode.getPadding(YogaEdge.TOP), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void nSetPaddingTop(double paddingTop) {
        mPaddingTop = DimenUtil.dpiToPx(paddingTop);
        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        mNode.setPadding(YogaEdge.TOP, DimenUtil.dpiToPx(paddingTop));
        view.requestLayout();
    }

    @LuaApiUsed
    public double nGetPaddingRight() {
        return yogaValue(mNode.getPadding(YogaEdge.RIGHT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void nSetPaddingRight(double paddingRight) {
        mPaddingRight = DimenUtil.dpiToPx(paddingRight);
        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        mNode.setPadding(YogaEdge.RIGHT, DimenUtil.dpiToPx(paddingRight));
        view.requestLayout();
    }

    @LuaApiUsed
    public double nGetPaddingBottom() {
        return yogaValue(mNode.getPadding(YogaEdge.BOTTOM), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void nSetPaddingBottom(double paddingBottom) {
        mPaddingBottom = DimenUtil.dpiToPx(paddingBottom);
        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        mNode.setPadding(YogaEdge.BOTTOM, DimenUtil.dpiToPx(paddingBottom));
        view.requestLayout();
    }

    @LuaApiUsed
    public void padding(double t, double r, double b, double l) {
        mPaddingTop = DimenUtil.dpiToPx(t);
        mPaddingRight = DimenUtil.dpiToPx(r);
        mPaddingBottom = DimenUtil.dpiToPx(b);
        mPaddingLeft = DimenUtil.dpiToPx(l);

        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        //为了识别NaN，不能使用int
        mNode.setPadding(YogaEdge.TOP,  mPaddingTop);
        mNode.setPadding(YogaEdge.RIGHT,mPaddingRight);
        mNode.setPadding(YogaEdge.BOTTOM, mPaddingBottom);
        mNode.setPadding(YogaEdge.LEFT, mPaddingLeft);
        view.requestLayout();
    }
    //</editor-fold>

    //<editor-fold desc="layout">

    @LuaApiUsed
    public int getCrossSelf() {
        return mNode.getAlignSelf().intValue();
    }

    @LuaApiUsed
    public void setCrossSelf(int crossSelf) {
        mNode.setAlignSelf(YogaAlign.fromInt(crossSelf));
        view.requestLayout();
    }

    @LuaApiUsed
    public float getBasis() {
        return mNode.getFlex();
    }

    @LuaApiUsed
    public void setBasis(float basis) {
        mNode.setFlex(basis);
        view.requestLayout();
    }

    @LuaApiUsed
    public float getGrow() {
        return mNode.getFlexGrow();
    }

    @LuaApiUsed
    public void setGrow(float grow) {
        mNode.setFlexGrow(grow);
        view.requestLayout();
    }

    @LuaApiUsed
    public float getShrink() {
        return mNode.getFlexShrink();
    }

    @LuaApiUsed
    public void setShrink(float shrink) {
        mNode.setFlexShrink(shrink);
        view.requestLayout();
    }

    @LuaApiUsed
    public boolean isDisplay() {
        return mNode.getDisplay() == YogaDisplay.FLEX;
    }

    @LuaApiUsed
    public void setDisplay(boolean display) {
        mNode.setDisplay(display ? YogaDisplay.FLEX : YogaDisplay.NONE);
        view.requestLayout();
    }
    //</editor-fold>

    //<editor-fold desc="position">

    @LuaApiUsed
    public int getPositionType() {
        return mNode.getPositionType().intValue();
    }

    @LuaApiUsed
    public void setPositionType(int positionType) {
        mNode.setPositionType(YogaPositionType.fromInt(positionType));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getPositionLeft() {
        return yogaValue(mNode.getPosition(YogaEdge.LEFT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setPositionLeft(double positionLeft) {
        mNode.setPosition(YogaEdge.LEFT, DimenUtil.dpiToPx(positionLeft));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getPositionTop() {
        return yogaValue(mNode.getPosition(YogaEdge.TOP), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setPositionTop(double positionTop) {
        mNode.setPosition(YogaEdge.TOP, DimenUtil.dpiToPx(positionTop));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getPositionRight() {
        return yogaValue(mNode.getPosition(YogaEdge.RIGHT), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setPositionRight(double positionRight) {
        mNode.setPosition(YogaEdge.RIGHT, DimenUtil.dpiToPx(positionRight));
        view.requestLayout();
    }

    @LuaApiUsed
    public double getPositionBottom() {
        return yogaValue(mNode.getPosition(YogaEdge.BOTTOM), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setPositionBottom(double positionBottom) {
        mNode.setPosition(YogaEdge.BOTTOM, DimenUtil.dpiToPx(positionBottom));
        view.requestLayout();
    }
    //</editor-fold>

    //<editor-fold desc="anim">

    @LuaApiUsed
    public void rotation(float angle, boolean add) {
        getInitValue();

        if (!add) {
            view.setRotation(angle);
        } else {
            view.setRotation(view.getRotation() + angle);
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void translation(double x, double y, boolean add) {
        getInitValue();

        if (!add) {
            view.setTranslationX(DimenUtil.dpiToPx(x));
            view.setTranslationY(DimenUtil.dpiToPx(y));
        } else {
            view.setTranslationX(view.getTranslationX() + DimenUtil.dpiToPx(x));
            view.setTranslationY(view.getTranslationY() + DimenUtil.dpiToPx(y));
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void scale(float x, float y, boolean add) {
        getInitValue();

        if (!add) {
            view.setScaleX(x);
            view.setScaleY(y);
        } else {
            view.setScaleX(view.getScaleX() * x);
            view.setScaleY(view.getScaleY() * y);
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void setAlpha(float a) {
        allowVirtual = false;
        view.setAlpha(a);
    }

    @LuaApiUsed
    public float getAlpha() {
        return view.getAlpha();
    }

    @LuaApiUsed
    public void viewWidth(double w) {
        view.setRight(view.getLeft() + DimenUtil.dpiToPx(w));
    }

    @LuaApiUsed
    public void viewHeight(double h) {
        view.setBottom(view.getTop() + DimenUtil.dpiToPx(h));
    }
    //</editor-fold>

    //<editor-fold desc="click">
    @LuaApiUsed
    public void onClick(LuaFunction fun) {
        allowVirtual = false;
        if (clickCallback != null) {
            clickCallback.destroy();
        }
        clickCallback = fun;
        if (clickCallback != null) {
            propersFlags |= FLAG_ONCLICK_SET;
            setClick(true);
        }
    }

    @LuaApiUsed
    public void onLongPress(LuaFunction fun) {
        allowVirtual = false;
        longClickCallback = fun;
        setGesture(longClickCallback);
    }
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="Property">

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
    public LuaValue[] canEndEditing(LuaValue[] p) {
        if (p != null && p.length > 0 && p[0].isBoolean()) {
            canEndEditing = p[0].toBoolean();
            if (canEndEditing) {
                propersFlags |= FLAG_CANENDEDITING_SET;
                setClick(true);
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
                setClick(true);
            } else if (!hasCanEndEditing() && !hasClick() && hasKeyboardDismiss()){
                propersFlags &= FLAG_KEYBOARDDISMISS_SET;
                setClick(false);
            }
        }
        allowVirtual = false;
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Render">

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
        if (var.length == 1 && var[0].isString()) {
            setNineImage(var[0].toJavaString());
        }
        return rNil();
    }

    protected void setNineImage(String image) {
        allowVirtual = false;
        hasNineImage = true;
        setBgDrawable(image);
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

    @LuaApiUsed
    public LuaValue[] notDispatch(LuaValue[] var) {
        allowVirtual = false;
        if (var.length == 1 && var[0].isBoolean()) {
            boolean b = var[0].toBoolean();
            if (isNotDispatch != null && isNotDispatch == b) {
                return null;
            }
            isNotDispatch = b;
            isTouchChange = true; // 事件流需要发生改变
            return null;
        }
        if (isNotDispatch == null) {
            return rNil();
        } else {
            return isNotDispatch ? rTrue() : rFalse();
        }
    }

    public Boolean isNotDispatch(){
        return isNotDispatch;
    }

    public boolean isTouchChange() {
        return isTouchChange;
    }

    public void setTouchChange(boolean touchChange) {
        isTouchChange = touchChange;
    }

    private void setLayoutComplete() {
        view.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                layoutComplete.fastInvoke();
                view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
        });
    }

    @LuaApiUsed
    public void childFirstHandlePointers(boolean force){
        childFirstHandlePointers = force;
    }

    public boolean isChildFirstHandlePointers() {
        return childFirstHandlePointers;
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

    @LuaApiUsed
    public LuaValue[] removeAllAnimation(LuaValue[] p) {
        allowVirtual = false;
        stopAnimation();
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="convert point">

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
    //</editor-fold>

    //<editor-fold desc="touch event">

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchBegin(long f) {
        allowVirtual = false;
        if (touchBeginCallback != null)
            touchBeginCallback.destroy();
        if (f == 0) {
            touchBeginCallback = null;
        } else {
            touchBeginCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchBeginCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchMove(long f) {
        allowVirtual = false;
        if (touchMoveCallback != null)
            touchMoveCallback.destroy();
        if (f == 0) {
            touchMoveCallback = null;
        } else {
            touchMoveCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchMoveCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchEnd(long f) {
        allowVirtual = false;
        if (touchEndCallback != null)
            touchEndCallback.destroy();
        if (f == 0) {
            touchEndCallback = null;
        } else {
            touchEndCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchEndCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchCancel(long f) {
        allowVirtual = false;
        if (touchCancelCallback != null)
            touchCancelCallback.destroy();
        if (f == 0) {
            touchCancelCallback = null;
        } else {
            touchCancelCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchCancelCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchBeginExtension(long f) {
        allowVirtual = false;
        if (touchBeginExtensionCallback != null)
            touchBeginExtensionCallback.destroy();
        if (f == 0) {
            touchBeginExtensionCallback = null;
        } else {
            touchBeginExtensionCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchBeginExtensionCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchMoveExtension(long f) {
        allowVirtual = false;
        if (touchMoveExtensionCallback != null)
            touchMoveExtensionCallback.destroy();
        if (f == 0) {
            touchMoveExtensionCallback = null;
        } else {
            touchMoveExtensionCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchMoveExtensionCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchEndExtension(long f) {
        allowVirtual = false;
        if (touchEndExtensionCallback != null)
            touchEndExtensionCallback.destroy();
        if (f == 0) {
            touchEndExtensionCallback = null;
        } else {
            touchEndExtensionCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchEndExtensionCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchCancelExtension(long f) {
        allowVirtual = false;
        if (touchCancelExtensionCallback != null)
            touchCancelExtensionCallback.destroy();
        if (f == 0) {
            touchCancelExtensionCallback = null;
        } else {
            touchCancelExtensionCallback = new TouchLuaFunction(globals, f);
        }
        setTouch(touchCancelExtensionCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void scaleBegin(long f) {
        allowVirtual = false;
        needHandlePointers = true;
        if (scaleBeginCallback != null)
            scaleBeginCallback.destroy();
        if (f == 0) {
            scaleBeginCallback = null;
        } else {
            scaleBeginCallback = new TouchLuaFunction(globals, f);
        }
        setScaleGesture(scaleBeginCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void scaling(long f) {
        allowVirtual = false;
        needHandlePointers = true;
        if (scalingCallback != null)
            scalingCallback.destroy();
        if (f == 0) {
            scalingCallback = null;
        } else {
            scalingCallback = new TouchLuaFunction(globals, f);
        }
        setScaleGesture(scalingCallback);
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void scaleEnd(long f) {
        allowVirtual = false;
        needHandlePointers = true;
        if (scaleEndCallback != null)
            scaleEndCallback.destroy();
        if (f == 0) {
            scaleEndCallback = null;
        } else {
            scaleEndCallback = new TouchLuaFunction(globals, f);
        }
        setScaleGesture(scaleEndCallback);
    }

    //</editor-fold>

    //<editor-fold desc="other">

    @LuaApiUsed
    public LuaValue[] onDetachedView(LuaValue[] p) {
        allowVirtual = false;
        if (detachFunction != null)
            detachFunction.destroy();
        detachFunction = p[0].toLuaFunction();
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
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="listeners">

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
            if (event.getAction() == MotionEvent.ACTION_CANCEL
                    && event.getX() == 0
                    && event.getY() == 0) {
//                if (scaleGestureDetector != null && scaleGestureDetector.onTouchEvent(event)) {
//                    return true;
//                }
//                if (gestureDetector != null && gestureDetector.onTouchEvent(event)) {
//                    return true;
//                }
                return false;
            }
            if (scaleMatrix == null) {
                scaleMatrix = new Matrix();
            }
            scaleMatrix.setScale(v.getScaleX(), v.getScaleY());
            event.transform(scaleMatrix);
            if (gestureDetector != null) {
                gestureDetector.onTouchEvent(event);
            }
            if (scaleGestureDetector != null) {
                scaleGestureDetector.onTouchEvent(event);
            }
            if (notifyTouchListeners(v, event))
                return true;

            float xdp = DimenUtil.pxToDpi(event.getX());
            float ydp = DimenUtil.pxToDpi(event.getY());

            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    if (touchBeginCallback != null)
                        touchBeginCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchBeginExtensionCallback, event);

                    break;

                case MotionEvent.ACTION_MOVE:
                    if (touchMoveCallback != null)
                        touchMoveCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchMoveExtensionCallback, event);

                    break;

                case MotionEvent.ACTION_POINTER_DOWN:
                    if (needHandlePointers) {
                        v.getParent().requestDisallowInterceptTouchEvent(true);
                    }
                    break;

                case MotionEvent.ACTION_UP:

                    if (touchEndCallback != null)
                        touchEndCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchEndExtensionCallback, event);

                    break;

                case MotionEvent.ACTION_CANCEL:

                    if (touchCancelCallback != null)
                        touchCancelCallback.fastInvoke(xdp, ydp);

                    touchExtension2Lua(touchCancelExtensionCallback, event);

                    break;
            }

            // View的手势通过Gesture手势识别器去处理，手动调用view的onTouchEvent，让控件出去处理自己特定的手势。
            // 此处只是进行手势识别和控制是否消费事件。系统默认没有OnTouchListener时，自动走onTouchEvent，所以默认调用onTouchEvent，单不依据onTouchEvent进行控件消费判断。
            v.onTouchEvent(event);
            return true;
        }

        private void touchExtension2Lua(TouchLuaFunction function, MotionEvent event) {
            if (function != null) {
                float pageX = DimenUtil.pxToDpi(event.getX());
                float pageY = DimenUtil.pxToDpi(event.getY());
                float screenX = DimenUtil.pxToDpi(event.getRawX());
                float screenY = DimenUtil.pxToDpi(event.getRawY());
                long timeStamp = System.currentTimeMillis();
                function.fastInvoke(pageX, pageY, screenX, screenY, UDView.this, timeStamp);
            }
        }

    };

    private ScaleGestureDetector.OnScaleGestureListener scaleListener = new ScaleGestureDetector.SimpleOnScaleGestureListener(){

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            if (scalingCallback != null)
            scale2Lua(scalingCallback, detector);
            return true;
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            if (scaleBeginCallback != null)
            scale2Lua(scaleBeginCallback, detector);
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector detector) {
            if (scaleEndCallback != null)
            scale2Lua(scaleEndCallback, detector);
        }

        private void scale2Lua(TouchLuaFunction function, ScaleGestureDetector detector) {
            if (function != null) {
                float focusX = DimenUtil.pxToDpi(detector.getFocusX());
                float focusY = DimenUtil.pxToDpi(detector.getFocusY());
                float span = DimenUtil.pxToDpi(detector.getCurrentSpan());
                float spanX = DimenUtil.pxToDpi(detector.getCurrentSpanX());
                float spanY = DimenUtil.pxToDpi(detector.getCurrentSpanY());
                float factor = detector.getScaleFactor();
                function.fastInvoke(focusX, focusY, span, spanX, spanY, factor);
            }
        }
    };

    private GestureDetector.OnGestureListener gestureListener = new GestureDetector.SimpleOnGestureListener() {

        /**
         * 轻触(手指松开)
         */
        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            return super.onSingleTapUp(e);
        }

        /**
         * 长按(手指尚未松开也没有达到scroll条件)
         */
        @Override
        public void onLongPress(MotionEvent e) {
            if (longClickCallback != null) {
                longClickCallback.fastInvoke();
            }
            super.onLongPress(e);
        }

        /**
         * 滑动(一次完整的事件可能会多次触发该函数)。返回值表示事件是否处理
         */
        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            return super.onScroll(e1, e2, distanceX, distanceY);
        }

        /**
         * 滑屏(用户按下触摸屏、快速滑动后松开，返回值表示事件是否处理)
         */
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
            return super.onFling(e1, e2, velocityX, velocityY);
        }

        /**
         * 短按(手指尚未松开也没有达到scroll条件)
         */
        @Override
        public void onShowPress(MotionEvent e) {
            super.onShowPress(e);
        }

        /**
         * 按下。返回值表示事件是否处理
         */
        @Override
        public boolean onDown(MotionEvent e) {
            return super.onDown(e);
        }

        /**
         * 双击事件
         */
        @Override
        public boolean onDoubleTap(MotionEvent e) {
            return super.onDoubleTap(e);
        }

        /**
         * 双击事件产生之后手指还没有抬起的时候的后续事件
         */
        @Override
        public boolean onDoubleTapEvent(MotionEvent e) {
            return super.onDoubleTapEvent(e);
        }

        /**
         * 单击事件(onSingleTapConfirmed，onDoubleTap是两个互斥的函数)
         */
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            if (!click) {
                return super.onSingleTapConfirmed(e);
            }
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

            if (keyboardDismiss) {// 区别于canEndEditing, 任意view都可以收起键盘
                InputMethodManager im = ((InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE));
                if (im != null) {
                    im.hideSoftInputFromWindow(view.getWindowToken(),
                            InputMethodManager.HIDE_NOT_ALWAYS);
                }
            }
            return super.onSingleTapConfirmed(e);
        }
    };

    //</editor-fold>

    protected MarginLayoutParams newWrapContent() {
        return new MarginLayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
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

    @Override
    public void onDetached() {
        if (detachFunction != null)
            detachFunction.fastInvoke();
        stopAnimation();
    }

    @Override
    public void onAttached() {

    }

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

    private void setScaleGesture(LuaFunction fun){
        if (fun != null) {
            if (scaleGestureDetector == null) {
                scaleGestureDetector = new ScaleGestureDetector(getContext(), scaleListener);
            }
            setTouch(fun);
        }
    }

    private void setClick(boolean click) {
        this.click = click;
        if (click) {
            setGesture(clickCallback);
        }
    }

    private void setGesture(LuaFunction fun) {
        if (fun != null) {
            if (gestureDetector == null) {
                gestureDetector = new GestureDetector(getContext(), gestureListener);
            }
        }
        setTouch(fun);
    }

    private void setTouch(LuaFunction fun) {
        if (fun != null) {
            if (view instanceof ICompose) {
                ((ICompose) view).getTouchLink().setTouchListener(touchListener);
            } else {
                view.setOnTouchListener(touchListener);
            }
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