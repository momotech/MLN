/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;


import android.view.View;

import com.facebook.yoga.YogaConstants;
import com.facebook.yoga.YogaDisplay;
import com.facebook.yoga.YogaJustify;
import com.immomo.mls.util.DimenUtil;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.FlexNode;
import com.facebook.yoga.YogaNodeFactory;
import com.facebook.yoga.YogaPositionType;
import com.facebook.yoga.YogaUnit;
import com.facebook.yoga.YogaValue;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IYogaGroup;
import com.immomo.mmui.weight.layout.NodeLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.NonNull;

/**
 * Node布局，桥接类
 */
@LuaApiUsed
public abstract class UDNodeView<V extends View> extends UDView<V, FlexNode> implements IFlexLayout {
    public static final String LUA_CLASS_NAME = "__FlexView";
    public static final String[] methods = new String[]{
        "width",
        "widthAuto",
        "widthPercent",
        "minWidth",
        "maxWidth",
        "minWidthPercent",
        "maxWidthPercent",

        "height",
        "heightAuto",
        "heightPercent",
        "minHeight",
        "maxHeight",
        "minHeightPercent",
        "maxHeightPercent",

        "marginLeft",
        "marginTop",
        "marginRight",
        "marginBottom",

        "margin",

        "paddingLeft",
        "paddingTop",
        "paddingRight",
        "paddingBottom",
        "padding",

        "crossSelf",
        "basis",
        "grow",
        "shrink",
        "display",

        "positionType",

        "positionLeft",
        "positionTop",
        "positionRight",
        "positionBottom",
    };

    //edge props
    private static final int MARGIN = 1;
    private static final int POSITION = 3;

    //normal props
    private static final int WIDTH = 5;
    private static final int WIDTH_PERCENT = 6;
    private static final int MIN_WIDTH = 7;
    private static final int MAX_WIDTH = 8;
    private static final int MIN_WIDTH_PERCENT = 9;
    private static final int MAX_WIDTH_PERCENT = 10;

    private static final int HEIGHT = 11;
    private static final int HEIGHT_PERCENT = 12;
    private static final int MIN_HEIGHT = 13;
    private static final int MAX_HEIGHT = 14;
    private static final int MIN_HEIGHT_PERCENT = 15;
    private static final int MAX_HEIGHT_PERCENT = 16;

    private static final int PADDING = 17;

    private static final int WIDTH_AUTO = 18;
    private static final int HEIGHT_AUTO = 19;


    @LuaApiUsed
    protected UDNodeView(long L, LuaValue[] v) {
        super(L, v);
    }

    public UDNodeView(Globals g, @NonNull V jud) {
        super(g, jud);
    }

    protected UDNodeView(Globals g) {
        super(g);
    }

    @Override
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

    @Override
    public FlexNode getFlexNode() {
        return mNode;
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    public LuaValue[] width(LuaValue[] varargs) {
        return handlerNormalProps(WIDTH, varargs);
    }

    @LuaApiUsed
    public LuaValue[] widthAuto(LuaValue[] varargs) {
        return handlerNormalProps(WIDTH_AUTO, varargs);
    }

    @LuaApiUsed
    public LuaValue[] widthPercent(LuaValue[] varargs) {
        return handlerNormalProps(WIDTH_PERCENT, varargs);
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

    /**
     * height
     **/
    @LuaApiUsed
    public LuaValue[] height(LuaValue[] varargs) {
        return handlerNormalProps(HEIGHT, varargs);
    }

    @LuaApiUsed
    public LuaValue[] heightAuto(LuaValue[] varargs) {
        return handlerNormalProps(HEIGHT_AUTO, varargs);
    }

    @LuaApiUsed
    public LuaValue[] heightPercent(LuaValue[] varargs) {
        return handlerNormalProps(HEIGHT_PERCENT, varargs);
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

    /* margin */
    @LuaApiUsed
    public LuaValue[] marginLeft(LuaValue[] var) {
        return handlerEdgeProps(MARGIN, YogaEdge.LEFT, var);
    }

    @LuaApiUsed
    public LuaValue[] marginTop(LuaValue[] var) {
        return handlerEdgeProps(MARGIN, YogaEdge.TOP, var);
    }

    @LuaApiUsed
    public LuaValue[] marginRight(LuaValue[] var) {
        return handlerEdgeProps(MARGIN, YogaEdge.RIGHT, var);
    }

    @LuaApiUsed
    public LuaValue[] marginBottom(LuaValue[] var) {
        return handlerEdgeProps(MARGIN, YogaEdge.BOTTOM, var);
    }

    @LuaApiUsed
    public LuaValue[] margin(LuaValue[] var) {
        mNode.setMargin(YogaEdge.TOP, DimenUtil.dpiToPxWithNaN(var[0]));
        mNode.setMargin(YogaEdge.RIGHT, DimenUtil.dpiToPxWithNaN(var[1]));
        mNode.setMargin(YogaEdge.BOTTOM, DimenUtil.dpiToPxWithNaN(var[2]));
        mNode.setMargin(YogaEdge.LEFT, DimenUtil.dpiToPxWithNaN(var[3]));
        view.requestLayout();
        return null;
    }

    /*padding */
    @LuaApiUsed
    public LuaValue[] paddingLeft(LuaValue[] var) {
        if (var.length > 0) {
            mPaddingLeft = DimenUtil.dpiToPx((float) var[0].toDouble());
        }
        return handlerEdgeProps(PADDING, YogaEdge.LEFT, var);
    }


    @LuaApiUsed
    public LuaValue[] paddingTop(LuaValue[] var) {
        if (var.length > 0) {
            mPaddingTop = DimenUtil.dpiToPx((float) var[0].toDouble());
        }
        return handlerEdgeProps(PADDING, YogaEdge.TOP, var);
    }

    @LuaApiUsed
    public LuaValue[] paddingRight(LuaValue[] var) {
        if (var.length > 0) {
            mPaddingRight = DimenUtil.dpiToPx((float) var[0].toDouble());
        }
        return handlerEdgeProps(PADDING, YogaEdge.RIGHT, var);
    }

    @LuaApiUsed
    public LuaValue[] paddingBottom(LuaValue[] var) {
        if (var.length > 0) {
            mPaddingBottom = DimenUtil.dpiToPx((float) var[0].toDouble());
        }
        return handlerEdgeProps(PADDING, YogaEdge.BOTTOM, var);
    }

    @LuaApiUsed
    public LuaValue[] padding(LuaValue[] var) {
        mPaddingTop = DimenUtil.dpiToPx((float) var[0].toDouble());
        mPaddingRight = DimenUtil.dpiToPx((float) var[1].toDouble());
        mPaddingBottom = DimenUtil.dpiToPx((float) var[2].toDouble());
        mPaddingLeft = DimenUtil.dpiToPx((float) var[3].toDouble());

        if (!(this instanceof IYogaGroup)) {
            setLeanPadding();//叶子节点，需要设置view的padding
        }
        //为了识别NaN，不能使用int
        mNode.setPadding(YogaEdge.LEFT, DimenUtil.dpiToPxWithNaN(var[0]));
        mNode.setPadding(YogaEdge.TOP, DimenUtil.dpiToPxWithNaN(var[1]));
        mNode.setPadding(YogaEdge.RIGHT, DimenUtil.dpiToPxWithNaN(var[2]));
        mNode.setPadding(YogaEdge.BOTTOM, DimenUtil.dpiToPxWithNaN(var[3]));
        view.requestLayout();
        return null;
    }

    //叶子节点（原生组件如：Label、ImageView），需要设置view的padding
    protected void setLeanPadding() {
        view.setPadding(
            mPaddingLeft,
            mPaddingTop,
            mPaddingRight,
            mPaddingBottom);
    }


    @LuaApiUsed
    public LuaValue[] crossSelf(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setAlignSelf(YogaAlign.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaAlign crossSelf = mNode.getAlignSelf();
        return varargsOf(LuaNumber.valueOf(crossSelf.intValue()));
    }

    @LuaApiUsed
    public LuaValue[] basis(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setFlex(var[0].toInt());
            view.requestLayout();
            return null;
        }

        float flex = mNode.getFlex();
        return varargsOf(LuaNumber.valueOf(flex));
    }

    @LuaApiUsed
    public LuaValue[] grow(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setFlexGrow(var[0].toInt());
            view.requestLayout();
            return null;
        }

        float flexGrow = mNode.getFlexGrow();
        return varargsOf(LuaNumber.valueOf(flexGrow));
    }

    @LuaApiUsed
    public LuaValue[] shrink(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setFlexShrink(var[0].toInt());
            view.requestLayout();
            return null;
        }

        float flexShrink = mNode.getFlexShrink();
        return varargsOf(LuaNumber.valueOf(flexShrink));
    }

    @LuaApiUsed
    public LuaValue[] display(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setDisplay(var[0].toBoolean() ? YogaDisplay.FLEX : YogaDisplay.NONE);
            view.requestLayout();
            return null;
        }

        YogaDisplay display = mNode.getDisplay();
        return varargsOf(LuaBoolean.valueOf(display == YogaDisplay.FLEX));
    }

    @LuaApiUsed
    public LuaValue[] positionType(LuaValue[] var) {
        if (var.length > 0) {
            mNode.setPositionType(YogaPositionType.fromInt(var[0].toInt()));
            view.requestLayout();
            return null;
        }

        YogaPositionType positionType = mNode.getPositionType();
        return varargsOf(LuaNumber.valueOf(positionType.intValue()));
    }

    /*position */
    @LuaApiUsed
    public LuaValue[] positionLeft(LuaValue[] var) {
        return handlerEdgeProps(POSITION, YogaEdge.LEFT, var);
    }

    @LuaApiUsed
    public LuaValue[] positionTop(LuaValue[] var) {
        return handlerEdgeProps(POSITION, YogaEdge.TOP, var);
    }

    @LuaApiUsed
    public LuaValue[] positionRight(LuaValue[] var) {
        return handlerEdgeProps(POSITION, YogaEdge.RIGHT, var);
    }

    @LuaApiUsed
    public LuaValue[] positionBottom(LuaValue[] var) {
        return handlerEdgeProps(POSITION, YogaEdge.BOTTOM, var);
    }

    //</editor-fold>

    @Override
    public String toString() {
        return view.getClass().getSimpleName() + "#" + view.hashCode();
    }

    //处理width、height 及其percent、max、min方法
    private LuaValue[] handlerNormalProps(int methodType, LuaValue[] var) {
        if (var.length > 0) {
            switch (methodType) {
                case WIDTH:
                    float src = var[0].toFloat();
                    checkSize(src);
                    setWidth(DimenUtil.dpiToPxWithNaN(src));
                    break;
                case WIDTH_PERCENT:
                    mNode.setWidthPercent(var[0].toFloat());
                    break;
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
                case HEIGHT:
                    src = var[0].toFloat();
                    checkSize(src);
                    setHeight(DimenUtil.dpiToPxWithNaN(src));
                    break;
                case HEIGHT_PERCENT:
                    mNode.setHeightPercent(var[0].toFloat());
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
        } else {
            switch (methodType) {
                case HEIGHT_AUTO:
                    mNode.setHeightAuto();
                    view.requestLayout();
                    return null;
                case WIDTH_AUTO:
                    mNode.setWidthAuto();
                    view.requestLayout();
                    return null;
            }
        }

        YogaValue yogaValue;
        YogaUnit methodUnit;
        switch (methodType) {
            case WIDTH:
                return LuaNumber.rNumber(DimenUtil.pxToDpi(getWidth()));
            case WIDTH_PERCENT:
                yogaValue = mNode.getWidth();
                methodUnit = YogaUnit.PERCENT;
                break;
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
            case HEIGHT:
                return LuaNumber.rNumber(DimenUtil.pxToDpi(getHeight()));
            case HEIGHT_PERCENT:
                yogaValue = mNode.getHeight();
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

        boolean hasValue = (yogaValue != null && methodUnit == yogaValue.unit);

        float value = hasValue ? yogaValue.value : 0;

        if (methodUnit == YogaUnit.POINT) {//percent 不是px
            value = DimenUtil.pxToDpi(value);
        }

        return LuaNumber.rNumber(value);
    }

    //处理margin、position、及其percent方法
    private LuaValue[] handlerEdgeProps(int methodType, @NonNull YogaEdge edge, LuaValue[] var) {

        if (var.length > 0) {
            switch (methodType) {
                case MARGIN:
                    mNode.setMargin(edge, DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case POSITION:
                    mNode.setPosition(edge, DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
                case PADDING:
                    if (!(this instanceof IYogaGroup)) {
                        setLeanPadding();//叶子节点，需要设置view的padding
                    }
                    mNode.setPadding(edge, DimenUtil.dpiToPxWithNaN(var[0]));
                    break;
            }
            view.requestLayout();
            return null;
        }

        YogaValue yogaValue = null;
        YogaUnit methodUnit = null;
        switch (methodType) {
            case MARGIN:
                yogaValue = mNode.getMargin(edge);
                methodUnit = YogaUnit.POINT;
                break;
            case POSITION:
                yogaValue = mNode.getPosition(edge);
                methodUnit = YogaUnit.POINT;
                break;
            case PADDING:
                yogaValue = mNode.getPadding(edge);
                methodUnit = YogaUnit.POINT;
                break;
            default:
                return null;
        }

        boolean hasValue = (yogaValue != null && methodUnit == yogaValue.unit);

        float value = hasValue ? yogaValue.value : 0;

        if (methodUnit == YogaUnit.POINT) {//percent 不是px
            value = DimenUtil.pxToDpi(value);
        }

        return LuaNumber.rNumber(value);
    }


    @Override
    protected void setWidth(float w) {
        mNode.setWidth(w);
    }

    @Override
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

    @Override
    protected void setHeight(float h) {
        mNode.setHeight(h);
    }

    @Override
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
}