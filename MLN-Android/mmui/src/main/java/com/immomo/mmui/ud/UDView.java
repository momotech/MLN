/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

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
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ILView;
import com.immomo.mmui.TouchableView;
import com.immomo.mmui.gesture.ArgoTouchUtil;
import com.immomo.mmui.gesture.DispatchDelay;
import com.immomo.mmui.gesture.ICompose;
import com.immomo.mmui.ui.LuaNodeLayout;
import com.immomo.mmui.weight.IBackground;
import com.immomo.mmui.weight.IBorderView;
import com.immomo.mmui.weight.IClippableView;
import com.immomo.mmui.weight.ICornerMaskView;
import com.immomo.mmui.weight.IShadowView;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IYogaGroup;
import com.immomo.mmui.weight.layout.NodeLayout;
import com.immomo.mmui.weight.layout.VirtualLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static android.view.ViewGroup.LayoutParams;
import static android.view.ViewGroup.OnTouchListener;

/**
 * Created by XiongFangyu on 2018/7/31.
 * java -jar mlncgen.jar -module mmui -class com.immomo.mmui.ud.UDView -jni bridge -name mmview.c
 *
 * view圆角设计：
 * 1、绘制纯色圆角，性能最高，局限性最大（不能有透明度，必须和底色颜色一致）
 * @see #addCornerMask(float, UDColor)
 * @see #addCornerMask(float, UDColor, int)
 * 2、只切割背景，不切割子控件，默认模式
 * 3、直接切割View，性能最差
 * 2、3通过{@link SICornerRadiusManager} 设置和 {@link #clipToBounds(boolean)} {@link #clipToChildren(boolean)}判断
 * @see #setCornerRadius(float)
 * @see #setCornerRadiusWithDirection(float, int)
 *
 */
@LuaApiUsed
public abstract class UDView<V extends View & ILView> extends JavaUserdata<V>
        implements ILView.ViewLifeCycleCallback, TouchableView, IFlexLayout {
    public static final String LUA_CLASS_NAME = "__BaseView";

    private final static short FLAG_ONCLICK_SET = 1;//onclick
    private final static short FLAG_CANENDEDITING_SET = 1 << 1;//canEndEditing
    private final static short FLAG_KEYBOARDDISMISS_SET = 1 << 2;//keyboardDismiss

    //<editor-fold desc="native init method">

    /**
     * 初始化方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    //<editor-fold desc="回调">

    //<editor-fold desc="点击、长按">
    private LuaFunction clickCallback;
    private LuaFunction longClickCallback;
    //</editor-fold>

    //<editor-fold desc="触摸事件回调">
    private TouchLuaFunction
            /// 普通触摸事件回调
            touchBeginCallback,
            touchMoveCallback,
            touchEndCallback,
            touchCancelCallback;
    /// 手势事件回调
    private TouchLuaFunction
            scaleBeginCallback,
            scalingCallback,
            scaleEndCallback;
    //</editor-fold>

    //<editor-fold desc="View事件回调">
    private LuaFunction detachFunction;
    private LuaFunction layoutComplete;
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="view初始动画属性">
    private float mInitTranslateX = -1;
    private float mInitTranslateY = -1;
    private float mInitScaleX = -1;
    private float mInitScaleY = -1;
    private float mInitRotation = -1;
    //</editor-fold>

    //<editor-fold desc="padding 属性">
    protected int mPaddingLeft;
    protected int mPaddingTop;
    protected int mPaddingRight;
    protected int mPaddingBottom;
    //</editor-fold>

    //<editor-fold desc="手势冲突">
    private Boolean isNotDispatch = null;//设置事件是否向子view传递
    private boolean isTouchChange = false;//设置是否改变事件流
    private int dispatchDelay = DispatchDelay.Default; // 设置手势延迟执行因子
    private boolean needHandlePointers = false;//设置是否需要处理多指
    //</editor-fold>

    //<editor-fold desc="手势相关">
    private GestureDetector gestureDetector;
    private boolean click;
    private ScaleGestureDetector scaleGestureDetector;
    private Matrix scaleMatrix;
    //</editor-fold>

    //<editor-fold desc="圆角相关">
    protected boolean forceClip;
    //</editor-fold>

    //<editor-fold desc="other">
    private boolean canEndEditing, keyboardDismiss;
    private short propersFlags;//属性标记
    private boolean allowVirtual = true;//是否允许使用虚拟布局，不代表是虚拟布局
    /**
     * View，构造函数中必须初始化
     */
    protected final @NonNull
    V view;
    /**
     * flex node，构造函数中必须初始化
     */
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
    //</editor-fold>

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
    protected void initClipConfig() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        if (m == null) {
            return;
        }
        forceClip = m.getDefaltCornerClip();
        IClippableView view = checkClippableVieW();
        if (view != null)
            view.openClip(forceClip);
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

    protected void checkSize(double src) {
        if (src >= 0)
            return;
        if (src == MeasurementType.MATCH_PARENT || src == MeasurementType.WRAP_CONTENT)
            return;
        if (Float.isNaN((float) src))
            return;
        ErrorUtils.debugLuaError("size must be set with positive number, error number: " + src + ".", getGlobals());
    }

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

    //<editor-fold desc="min max width height">
    //<editor-fold desc="min width">
    @LuaApiUsed
    public void setMinWidth(float w) {
        mNode.setMinWidth(DimenUtil.dpiToPxWithNaN(w));
    }

    @LuaApiUsed
    public float getMinWidth() {
        return yogaValue(mNode.getMinWidth(), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMinWidthPercent(float p) {
        mNode.setMinWidthPercent(p);
    }

    @LuaApiUsed
    public float getMinWidthPercent() {
        return yogaValue(mNode.getMinWidth(), YogaUnit.PERCENT);
    }
    //</editor-fold>

    //<editor-fold desc="max width">
    @LuaApiUsed
    public void setMaxWidth(float w) {
        mNode.setMaxWidth(DimenUtil.dpiToPxWithNaN(w));
    }

    @LuaApiUsed
    public float getMaxWidth() {
        return yogaValue(mNode.getMaxWidth(), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMaxWidthPercent(float p) {
        mNode.setMaxWidthPercent(p);
    }

    @LuaApiUsed
    public float getMaxWidthPercent() {
        return yogaValue(mNode.getMaxWidth(), YogaUnit.PERCENT);
    }
    //</editor-fold>

    //<editor-fold desc="min height">
    @LuaApiUsed
    public void setMinHeight(float w) {
        mNode.setMinHeight(DimenUtil.dpiToPxWithNaN(w));
    }

    @LuaApiUsed
    public float getMinHeight() {
        return yogaValue(mNode.getMinHeight(), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMinHeightPercent(float p) {
        mNode.setMinHeightPercent(p);
    }

    @LuaApiUsed
    public float getMinHeightPercent() {
        return yogaValue(mNode.getMinHeight(), YogaUnit.PERCENT);
    }
    //</editor-fold>

    //<editor-fold desc="max height">
    @LuaApiUsed
    public void setMaxHeight(float w) {
        mNode.setMaxHeight(DimenUtil.dpiToPxWithNaN(w));
    }

    @LuaApiUsed
    public float getMaxHeight() {
        return yogaValue(mNode.getMaxHeight(), YogaUnit.POINT);
    }

    @LuaApiUsed
    public void setMaxHeightPercent(float p) {
        mNode.setMaxHeightPercent(p);
    }

    @LuaApiUsed
    public float getMaxHeightPercent() {
        return yogaValue(mNode.getMaxHeight(), YogaUnit.PERCENT);
    }
    //</editor-fold>
    //</editor-fold>

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
        mNode.setPadding(YogaEdge.TOP, mPaddingTop);
        mNode.setPadding(YogaEdge.RIGHT, mPaddingRight);
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
        return getFlexBasis();
    }

    public float getFlexBasis() {
        YogaValue yogaValue = mNode.getFlexBasis();
        if (yogaValue.unit == YogaUnit.POINT && !Float.isNaN(yogaValue.value)) {
            return  DimenUtil.pxToDpi(yogaValue.value);
        }

        return 0f;
    }

    @LuaApiUsed
    public void setBasis(float basis) {
        mNode.setFlexBasis(DimenUtil.dpiToPx(basis));
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

    // 重置所有变化到初始状态
    @LuaApiUsed
    public void transformIdentity() {
        getInitValue();
        view.setRotation(mInitRotation);
        view.setScaleY(mInitScaleY);
        view.setScaleX(mInitScaleX);
        view.setTranslationX(mInitTranslateX);
        view.setTranslationY(mInitTranslateY);
        allowVirtual = false;
    }

    @LuaApiUsed
    public void rotation(float angle) {
        rotation(angle, false);
    }

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
    public void translation(double x, double y) {
        translation(x, y, false);
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
    public void scale(float x, float y) {
        scale(x, y, false);
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

    //<editor-fold desc="background">
    protected IBackground checkBackgroundView() {
        return this.view instanceof IBackground ? (IBackground) this.view : null;
    }

    // 设置背景图片，只支持本地资源  不能同bgColor 同时设置，否则会被后设置的覆盖
    @LuaApiUsed
    public void bgImage(String url) {
        allowVirtual = false;
        IBackground view = checkBackgroundView();
        if (view == null)
            return;
        if (TextUtils.isEmpty(url)) {
            view.setBGDrawable(null);
            return;
        }
        final ImageProvider provider = MLSAdapterContainer.getImageProvider();
        Drawable d = provider.loadProjectImage(getContext(), url);
        if (d != null) {
            view.setBGDrawable(d);
            return;
        }

        if (RelativePathUtils.isAssetUrl(url)) {
            url = RelativePathUtils.getAbsoluteAssetUrl(url);
            d = provider.loadProjectImage(getContext(), url);
            if (d != null)
                view.setBGDrawable(d);
            return;
        }

        // 相对路径
        if (RelativePathUtils.isLocalUrl(url)) {
            url = RelativePathUtils.getAbsoluteUrl(url);
            provider.preload(getContext(), url, null, initLoadCallback());
            return;
        }

        // 相对lua包路径
        String localUrl = getLuaViewManager().baseFilePath;
        if (!TextUtils.isEmpty(localUrl)) {
            File imgFile = new File(localUrl, url);
            if (imgFile.exists()) {
                url = imgFile.getAbsolutePath();
                provider.preload(getContext(), url, null, initLoadCallback());
            }
        }
    }

    @LuaApiUsed
    public void setBgColor(UDColor color) {
        allowVirtual = false;
        IBackground view = checkBackgroundView();
        if (view != null) {
            view.setBackgroundColor(color.getColor());
        }
    }

    @LuaApiUsed
    public UDColor getBgColor() {
        IBackground view = checkBackgroundView();
        int c = 0;
        if (view != null) {
            c = view.getBackgroundColor();
        }
        return new UDColor(globals, c);
    }

    @LuaApiUsed
    public void setGradientColorWithDirection(UDColor c1, UDColor c2, int d) {
        allowVirtual = false;
        int s = c1.getColor();
        int e = c2.getColor();
        c1.destroy();
        c2.destroy();
        IBackground view = checkBackgroundView();
        if (view != null) {
            view.setGradientColor(s, e, d);
        }
    }

    @LuaApiUsed
    public void setGradientColor(UDColor c1, UDColor c2, boolean vertical) {
        allowVirtual = false;
        int s = c1.getColor();
        int e = c2.getColor();
        c1.destroy();
        c2.destroy();
        IBackground view = checkBackgroundView();
        if (view != null) {
            view.setGradientColor(s, e, vertical ? GradientType.TOP_TO_BOTTOM : GradientType.LEFT_TO_RIGHT);
        }
    }
    //</editor-fold>

    //<editor-fold desc="Border">
    protected IBorderView checkBorderView() {
        if (view instanceof IBorderView)
            return (IBorderView) view;
        return null;
    }

    protected IClippableView checkClippableVieW() {
        return view instanceof IClippableView ? (IClippableView) view : null;
    }

    @LuaApiUsed
    public void setBorderWidth(final float borderWidth) {
        allowVirtual = false;
        IBorderView view = checkBorderView();
        if (view != null) {
            view.setStrokeWidth(DimenUtil.dpiToPx(borderWidth));
        }
    }

    @LuaApiUsed
    public float getBorderWidth() {
        IBorderView view = checkBorderView();
        if (view != null) {
            return DimenUtil.pxToDpi(view.getStrokeWidth());
        }
        return 0;
    }

    @LuaApiUsed
    public void setBorderColor(UDColor color) {
        allowVirtual = false;
        IBorderView view = checkBorderView();
        if (view != null) {
            view.setStrokeColor(color.getColor());
        }
    }

    @LuaApiUsed
    public UDColor getBorderColor() {
        IBorderView view = checkBorderView();
        if (view != null) {
            return new UDColor(globals, view.getStrokeColor());
        }
        return new UDColor(globals, 0);
    }
    //</editor-fold>

    //<editor-fold desc="Corner">
    @LuaApiUsed
    public void setCornerRadius(float r) {
        allowVirtual = false;
        r = DimenUtil.dpiToPx(r);
        IClippableView cv = checkClippableVieW();
        if (cv != null)
            cv.setClipRadius(r);
        IBorderView bv = checkBorderView();
        if (bv != null) {
            bv.setCornerRadius(r);
        }
        IBackground bview = checkBackgroundView();
        if (bview != null) {
            bview.setBackgroundRadius(r);
        }
    }

    @LuaApiUsed
    public float getCornerRadius() {
        return getCornerRadiusWithDirection(RectCorner.TOP_LEFT);
    }

    @LuaApiUsed
    public void setCornerRadiusWithDirection(float radius, int direcion) {
        allowVirtual = false;
        radius = DimenUtil.dpiToPx(radius);
        //控制圆角半径小于view最小长度
        float minLength = (getWidth() <= getHeight()) ? getWidth() : getHeight();
        if (minLength > 0 && radius > minLength / 2) {
            radius = minLength / 2;
        }
        if (forceClip) {
            IClippableView view = checkClippableVieW();
            if (view != null)
                view.setClipRadius(direcion, radius);
        } else {
            IBorderView view = checkBorderView();
            if (view == null)
                return;
            view.setRadius(direcion, radius);
            IBackground bview = checkBackgroundView();
            if (bview != null) {
                bview.setBackgroundRadius(direcion, radius);
            }
        }
    }

    @LuaApiUsed
    public float getCornerRadiusWithDirection(int direction) {
        IBorderView view = checkBorderView();
        if (view != null) {
            return DimenUtil.pxToDpi(view.getRadius(direction));
        }
        return 0;
    }

    protected void onClipChanged() {
        IBorderView borderView = checkBorderView();
        IClippableView clippableView = checkClippableVieW();
        IBackground background = checkBackgroundView();
        if (borderView == null || clippableView == null || background != null)
            return;
        clippableView.openClip(forceClip);
        /// 从非强制切割切换到强制切割
        if (forceClip) {
            clippableView.setClipRadius(
                    borderView.getRadius(RectCorner.TOP_LEFT),
                    borderView.getRadius(RectCorner.TOP_RIGHT),
                    borderView.getRadius(RectCorner.BOTTOM_LEFT),
                    borderView.getRadius(RectCorner.BOTTOM_RIGHT));
        } else {
            float tl = clippableView.getClipRadius(RectCorner.TOP_LEFT);
            float tr = clippableView.getClipRadius(RectCorner.TOP_RIGHT);
            float bl = clippableView.getClipRadius(RectCorner.BOTTOM_LEFT);
            float br = clippableView.getClipRadius(RectCorner.BOTTOM_RIGHT);
            borderView.setRadius(tl, tr, bl, br);
            background.setBackgroundRadius(tl, tr, bl, br);
        }
    }
    //</editor-fold>

    //<editor-fold desc="shadow">
    @LuaApiUsed
    public void setShadow(float w, float h) {
        setShadow(w, h, 3, 1);
    }

    @LuaApiUsed
    public void setShadow(float w, float h, float ra) {
        setShadow(w, h, ra, 1);
    }

    @LuaApiUsed
    public void setShadow(float w, float h, float radius, float alpha) {
        allowVirtual = false;
        IShadowView view = this.view instanceof IShadowView ? (IShadowView) this.view : null;
        if (view == null)
            return;
        radius = DimenUtil.dpiToPx(radius);
        view.setShadow(0,
                DimenUtil.dpiToPx(w),
                DimenUtil.dpiToPx(h),
                radius,
                alpha);
    }
    //</editor-fold>

    //<editor-fold desc="Mask corner">
    @LuaApiUsed
    public void addCornerMask(float radius, UDColor color) {
        addCornerMask(radius, color, RectCorner.ALL_CORNERS);
    }

    @LuaApiUsed
    public void addCornerMask(float radius, UDColor color, int direction) {
        allowVirtual = false;
        ICornerMaskView view = this.view instanceof ICornerMaskView ? (ICornerMaskView) this.view : null;
        if (view == null)
            return;

        int colorInt = color.getColor();
        color.destroy();
        view.setMaskColor(colorInt);
        //控制圆角半径小于view最小长度
        float minLength = (getWidth() <= getHeight()) ? getWidth() : getHeight();
        radius = radius <= 0 ? 0 : DimenUtil.dpiToPx(radius);
        if (minLength > 0 && radius > minLength / 2) {
            radius = minLength / 2;
        }
        view.setMaskRadius(direction, radius);

        IBorderView bView = checkBorderView();
        if (bView != null) {
            bView.setRadius(direction, radius);
        }
    }
    //</editor-fold>

    //<editor-fold desc="clip">

    @LuaApiUsed
    public void clipToBounds(boolean clip) {
        allowVirtual = false;
        ViewParent vp = view.getParent();
        if (view instanceof ViewGroup) {
            ((ViewGroup) view).setClipToPadding(clip);
            ((ViewGroup) view).setClipChildren(clip);
        }
        if (vp instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) vp;
            vg.setClipChildren(clip);
        }
        if (forceClip != clip) {
            forceClip = clip;
            onClipChanged();
        }
    }

    @LuaApiUsed
    public void clipToChildren(boolean clip) {
        allowVirtual = false;
        if (view instanceof ViewGroup) {
            ((ViewGroup) view).setClipChildren(clip);
        }
        if (forceClip != clip) {
            forceClip = clip;
            onClipChanged();
        }
    }
    //</editor-fold>

    //<editor-fold desc="convert point">

    @LuaApiUsed
    public UDPoint convertPointTo(UDView toView, UDPoint p) {
        if (toView == null || p == null) {
            return null;
        }
        Point point = p.getJavaUserdata();
        p.destroy();
        int[] curLocation = new int[2];
        view.getLocationInWindow(curLocation);
        int[] toLocation = new int[2];
        toView.view.getLocationInWindow(toLocation);
        Point result = new Point();
        result.setX(DimenUtil.pxToDpi(curLocation[0]) + point.getX() - DimenUtil.pxToDpi(toLocation[0]));
        result.setY(DimenUtil.pxToDpi(curLocation[1]) + point.getY() - DimenUtil.pxToDpi(toLocation[1]));
        return new UDPoint(getGlobals(), result);
    }

    @LuaApiUsed
    public UDPoint convertPointFrom(UDView fromView, UDPoint p) {
        if (fromView == null || p == null) {
            return null;
        }
        Point point = p.getJavaUserdata();
        p.destroy();
        int[] fromViewLocation = new int[2];
        fromView.view.getLocationInWindow(fromViewLocation);
        int[] curLocation = new int[2];
        view.getLocationInWindow(curLocation);
        Point result = new Point();
        result.setX(DimenUtil.pxToDpi(fromViewLocation[0]) + point.getX() - DimenUtil.pxToDpi(curLocation[0]));
        result.setY(DimenUtil.pxToDpi(fromViewLocation[1]) + point.getY() - DimenUtil.pxToDpi(curLocation[1]));
        return new UDPoint(getGlobals(), result);
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

    //<editor-fold desc="手势冲突">
    @LuaApiUsed
    public void nSetNotDispatch(boolean b) {
        allowVirtual = false;
        isNotDispatch = b;
        dispatchDelay = DispatchDelay.Default; // 默认立即改变事件流
        isTouchChange = true; // 事件流需要发生改变
    }

    @LuaApiUsed
    public boolean nIsNotDispatch() {
        return isNotDispatch != null && isNotDispatch;
    }

    public Boolean isNotDispatch() {
        return isNotDispatch;
    }

    public boolean isTouchChange() {
        return isTouchChange;
    }

    public void setTouchChange(boolean touchChange) {
        isTouchChange = touchChange;
    }

    @LuaApiUsed
    public void resetTouchTarget(int delay) {
        dispatchDelay = delay;
        isTouchChange = true; // 事件流需要发生改变
    }

    public int getDispatchDelay() {
        return dispatchDelay;
    }

    public void setDispatchDelay(int delay) {
        this.dispatchDelay = delay;
    }
    //</editor-fold>

    //<editor-fold desc="other">

    @LuaApiUsed
    public void anchorPoint(float x, float y) {
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
    }

    @LuaApiUsed
    public void removeFromSuper() {
        if (view.getParent() instanceof ViewGroup) {
            final ViewGroup parent = (ViewGroup) view.getParent();
            LuaViewUtil.removeView(parent, view);
        }
    }

    @LuaApiUsed
    public UDView superview() {
        if (view.getParent() instanceof ILView) {
            return ((ILView) view.getParent()).getUserdata();
        }
        return null;
    }

    @LuaApiUsed
    public void addBlurEffect() {
        allowVirtual = false;
    }

    @LuaApiUsed
    public void removeBlurEffect() {
        allowVirtual = false;
    }

    @LuaApiUsed
    public void openRipple(boolean open) {
        if (view instanceof IBackground) {
            ((IBackground) view).setDrawRipple(open);
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void canEndEditing(boolean can) {
        canEndEditing = can;
        if (can) {
            propersFlags |= FLAG_CANENDEDITING_SET;
            setClick(true);
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void keyboardDismiss(boolean b) {
        keyboardDismiss = b;
        if (keyboardDismiss) {
            propersFlags |= FLAG_KEYBOARDDISMISS_SET;
            setClick(true);
        } else if (!hasCanEndEditing() && !hasClick() && hasKeyboardDismiss()) {
            propersFlags &= FLAG_KEYBOARDDISMISS_SET;
            setClick(false);
        }
        allowVirtual = false;
    }

    @LuaApiUsed
    public void layoutComplete(LuaFunction f) {
        if (layoutComplete != null)
            layoutComplete.destroy();
        layoutComplete = f;
        view.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                if (layoutComplete != null)
                    layoutComplete.fastInvoke();
                view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
        });
    }

    @LuaApiUsed
    public void setEnabled(boolean e) {
        allowVirtual = false;
        view.setEnabled(e);
    }

    @LuaApiUsed
    public boolean isEnabled() {
        return view.isEnabled();
    }

    @LuaApiUsed
    public void setHidden(boolean b) {
        allowVirtual = false;
        view.setVisibility(b ? View.INVISIBLE : View.VISIBLE);
    }

    @LuaApiUsed
    public boolean isHidden() {
        return view.getVisibility() != View.VISIBLE;
    }

    @LuaApiUsed
    public boolean hasFocus() {
        return view.isFocused();
    }

    @LuaApiUsed
    public boolean canFocus() {
        return view.isFocusable();
    }

    @LuaApiUsed
    public void requestFocus() {
        allowVirtual = false;
        view.requestFocus();
    }

    @LuaApiUsed
    public void cancelFocus() {
        allowVirtual = false;
        view.clearFocus();
    }

    @LuaApiUsed
    public void onDetachedView(LuaFunction f) {
        allowVirtual = false;
        if (detachFunction != null)
            detachFunction.destroy();
        detachFunction = f;
    }

    @LuaApiUsed
    public String snapshot(String src) {
        allowVirtual = false;
        return captureScreenforRecord(src);
    }
    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="touch gesture listeners">

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
                // 目前逻辑下发的多指事件，两个点的坐标均为上次事件的focusX和focusY，会影响scaleGestureDetector内部逻辑判断，先屏蔽掉
                if (!ArgoTouchUtil.isCustomCreate(event)) {
                    scaleGestureDetector.onTouchEvent(event);
                }
            }
            if (notifyTouchListeners(v, event))
                return true;

            final float xdp = DimenUtil.pxToDpi(event.getX());
            final float ydp = DimenUtil.pxToDpi(event.getY());
            final float screenX = DimenUtil.pxToDpi(event.getRawX());
            final float screenY = DimenUtil.pxToDpi(event.getRawY());
            final long timeStamp = System.currentTimeMillis();
            final LuaUserdata ud = UDView.this;

            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    if (touchBeginCallback != null)
                        touchBeginCallback.fastInvoke(xdp,
                                ydp,
                                screenX,
                                screenY,
                                ud,
                                timeStamp);
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (touchMoveCallback != null)
                        touchMoveCallback.fastInvoke(xdp,
                                ydp,
                                screenX,
                                screenY,
                                ud,
                                timeStamp);
                    break;
                case MotionEvent.ACTION_POINTER_DOWN:
                    if (needHandlePointers) {
                        v.getParent().requestDisallowInterceptTouchEvent(true);
                    }
                    break;
                case MotionEvent.ACTION_UP:
                    if (touchEndCallback != null)
                        touchEndCallback.fastInvoke(xdp,
                                ydp,
                                screenX,
                                screenY,
                                ud,
                                timeStamp);
                    break;
                case MotionEvent.ACTION_CANCEL:
                    if (touchCancelCallback != null)
                        touchCancelCallback.fastInvoke(xdp,
                                ydp,
                                screenX,
                                screenY,
                                ud,
                                timeStamp);
                    break;
            }
            // View的手势通过Gesture手势识别器去处理，手动调用view的onTouchEvent，让控件出去处理自己特定的手势。
            // 此处只是进行手势识别和控制是否消费事件。系统默认没有OnTouchListener时，自动走onTouchEvent，所以默认调用onTouchEvent，单不依据onTouchEvent进行控件消费判断。
            v.onTouchEvent(event);
            return true;
        }
    };

    private ScaleGestureDetector.OnScaleGestureListener scaleListener = new ScaleGestureDetector.SimpleOnScaleGestureListener() {

        private float lastScaleX = -1;
        private float lastScaleY = -1;

        private void initScale() {
            if (lastScaleX == -1)
                lastScaleX = view.getScaleX();

            if (lastScaleY == -1)
                lastScaleY = view.getScaleY();
        }

        private boolean isChangeScale() {
            boolean isChange = lastScaleX != view.getScaleX() && lastScaleY != view.getScaleY();
            if (isChange) {
                lastScaleX = view.getScaleX();
                lastScaleY = view.getScaleY();
            }
            return isChange;
        }

        private void resetScale() {
            lastScaleX = -1;
            lastScaleY = -1;
        }

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            if (scalingCallback != null)
                scale2Lua(scalingCallback, detector);
            // 当控件执行了缩放方法，需要返回true，消费掉此次事件，让缩放因子从1开始，否则后面View的实际缩放将会成指数增长；
            // 若没有进行缩放，则需要返回false，让缩放因子连续变化，否则缩放因子每次都将从1开始，缩放因子将一直在1附近变化
            return isChangeScale();
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            initScale();
            if (scaleBeginCallback != null)
                scale2Lua(scaleBeginCallback, detector);
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector detector) {
            resetScale();
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

    //<editor-fold desc="override method">

    @Override
    public String toString() {
        return view.getClass().getSimpleName() + "#" + view.hashCode();
    }

    @Override
    public void onDetached() {
        if (detachFunction != null)
            detachFunction.fastInvoke();
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
    //</editor-fold>

    //<editor-fold desc="TouchableView">
    @Override
    public void addOnTouchListener(View.OnTouchListener l) {
        if (touchListeners == null)
            touchListeners = new ArrayList<>(1);
        if (!touchListeners.contains(l))
            touchListeners.add(l);
        view.setOnTouchListener(touchListener);
    }

    @Override
    public void removeOnTouchListener(View.OnTouchListener l) {
        if (touchListeners != null)
            touchListeners.remove(l);
    }
    //</editor-fold>

    //<editor-fold desc="private 设置手势等">

    //调用了onclick
    private boolean hasClick() {
        return (propersFlags & FLAG_ONCLICK_SET) == FLAG_ONCLICK_SET;
    }

    //调用了onclick
    private boolean hasCanEndEditing() {
        return (propersFlags & FLAG_CANENDEDITING_SET) == FLAG_CANENDEDITING_SET;
    }

    //调用了onclick
    private boolean hasKeyboardDismiss() {
        return (propersFlags & FLAG_KEYBOARDDISMISS_SET) == FLAG_KEYBOARDDISMISS_SET;
    }

    private void setScaleGesture(LuaFunction fun) {
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
    //</editor-fold>

    //<editor-fold desc="public method">
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
     *
     * @return 默认不允许，需要子类重写此方法
     */
    public boolean needConvertVirtual() {
        return false;
    }

    //是否允许使用虚拟布局，不代表是虚拟布局
    public boolean isAllowVirtual() {
        return allowVirtual;
    }
    //</editor-fold>

    //<editor-fold desc="private 截屏">
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
    //</editor-fold>

    //<editor-fold desc="anim init value">
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
    //</editor-fold>

    //<editor-fold desc="background drawable callback">
    DrawableLoadCallback drawableLoadCallback;

    private DrawableLoadCallback initLoadCallback() {
        if (drawableLoadCallback != null)
            return drawableLoadCallback;
        drawableLoadCallback = new DrawableLoadCallback() {
            @Override
            public void onLoadResult(final Drawable drawable) {
                if (drawable != null) {
                    IBackground view = checkBackgroundView();
                    if (view != null)
                        view.setBGDrawable(drawable);
                }
            }
        };
        return drawableLoadCallback;
    }
    //</editor-fold>
}