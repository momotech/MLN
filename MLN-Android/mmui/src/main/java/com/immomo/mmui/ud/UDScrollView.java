/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.util.AttributeSet;
import android.util.Xml;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.R;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ui.IScrollView;
import com.immomo.mmui.ui.LuaScrollViewContainer;
import com.immomo.mmui.util.VirtualViewUtil;
import com.immomo.mmui.weight.layout.IFlexLayout;
import com.immomo.mmui.weight.layout.IVirtualLayout;
import com.immomo.mmui.weight.layout.NodeLayout;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;
import org.xmlpull.v1.XmlPullParser;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaApiUsed
public class UDScrollView<V extends ViewGroup & IScrollView> extends UDView<V>
    implements IScrollView.OnScrollListener, IScrollView.touchActionListener, IScrollView.FlingListener, View.OnTouchListener {
    public static final String LUA_CLASS_NAME = "ScrollView";

    private LuaFunction scrollBeginCallback;
    private LuaFunction scrollingCallback;
    private LuaFunction scrollEndCallback;
    private LuaFunction endDraggingCallback;
    private LuaFunction startDeceleratingCallback;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDScrollView(long L) {
        this(L, false, false);
    }

    @CGenerate
    @LuaApiUsed
    protected UDScrollView(long L, boolean vertical) {
        this(L, vertical, false);
    }

    @CGenerate
    @LuaApiUsed
    protected UDScrollView(long L, boolean horizontal, boolean same) {
        super(L, null);
        if (javaUserdata instanceof LuaScrollViewContainer) {
            ((LuaScrollViewContainer) javaUserdata).init(!horizontal, same, getAttributeSet());
        }
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaScrollViewContainer(getContext(), this);
    }

    private AttributeSet getAttributeSet() {
        AttributeSet attr = null;
        try {
            XmlPullParser parser = getContext().getResources().getXml(R.xml.vertical_nested_scrollview);
            parser.next();
            parser.nextTag();
            attr = Xml.asAttributeSet(parser);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return attr;
    }

    @Override
    public void padding(double t, double r, double b, double l) {
        mPaddingTop = DimenUtil.dpiToPx(t);
        mPaddingRight = DimenUtil.dpiToPx(r);
        mPaddingBottom = DimenUtil.dpiToPx(b);
        mPaddingLeft = DimenUtil.dpiToPx(l);

        view.getScrollView().setPadding(
                mPaddingLeft,
                mPaddingTop,
                mPaddingRight,
                mPaddingBottom);
//        mNode.setPadding(YogaEdge.TOP,  mPaddingTop);
//        mNode.setPadding(YogaEdge.RIGHT,mPaddingRight);
//        mNode.setPadding(YogaEdge.BOTTOM, mPaddingBottom);
//        mNode.setPadding(YogaEdge.LEFT, mPaddingLeft);
//        view.requestLayout();
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">

    @LuaApiUsed
    public UDPoint getContentOffset() {
        float x = DimenUtil.pxToDpi(getView().getScrollX());
        float y = DimenUtil.pxToDpi(getView().getScrollY());
        return new UDPoint(globals, x, y);
    }

    @LuaApiUsed
    public void setContentOffset(UDPoint contentOffset) {
        getView().scrollTo(contentOffset.getXPx(), contentOffset.getYPx());
        contentOffset.destroy();
    }

    @LuaApiUsed
    public boolean isShowsHorizontalScrollIndicator() {
        return getView().isHorizontalScrollBarEnabled();
    }

    @LuaApiUsed
    public void setShowsHorizontalScrollIndicator(boolean showsHorizontalScrollIndicator) {
        getView().setHorizontalScrollBarEnabled((showsHorizontalScrollIndicator));
    }

    @LuaApiUsed
    public boolean isShowsVerticalScrollIndicator() {
        return getView().isVerticalScrollBarEnabled();
    }

    @LuaApiUsed
    public void setShowsVerticalScrollIndicator(boolean showsVerticalScrollIndicator) {
        getView().setVerticalScrollBarEnabled(showsVerticalScrollIndicator);
    }

    @LuaApiUsed
    public void setScrollEnable(boolean e) {
        getView().setScrollEnable(e);
    }

    @LuaApiUsed
    public void i_bounces() {
    }

    @LuaApiUsed
    public void i_bounceHorizontal() {
    }

    @LuaApiUsed
    public void i_bounceVertical() {
    }

    @LuaApiUsed
    public void i_pagingEnabled() {
    }

    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public UDSize contentSize() {
        View v = view.getContentView();
        return new UDSize(globals, DimenUtil.pxToDpi(v.getWidth()), DimenUtil.pxToDpi(v.getHeight()));
    }

    @LuaApiUsed
    public void setScrollBeginCallback(LuaFunction f) {
        if (scrollBeginCallback != null)
            scrollBeginCallback.destroy();
        this.scrollBeginCallback = f;
        if (scrollBeginCallback != null)
            getView().setOnScrollListener(this);
    }

    @LuaApiUsed
    public void setScrollingCallback(LuaFunction p) {
        if (scrollingCallback != null)
            scrollingCallback.destroy();
        this.scrollingCallback = p;
        if (scrollingCallback != null)
            getView().setOnScrollListener(this);
    }

    @LuaApiUsed
    public void setScrollEndCallback(LuaFunction f) {
        if (scrollEndCallback != null)
            scrollEndCallback.destroy();
        this.scrollEndCallback = f;
        if (scrollEndCallback != null)
            getView().setOnScrollListener(this);
    }

    /// Android 不实现
    @LuaApiUsed
    public void setContentInset() {
    }

    @LuaApiUsed
    public void setOffsetWithAnim(UDPoint p) {
        getView().smoothScrollTo(p.getXPx(), p.getYPx());
        p.destroy();
    }

    @LuaApiUsed
    public void setEndDraggingCallback(LuaFunction f) {
        if (endDraggingCallback != null)
            endDraggingCallback.destroy();
        endDraggingCallback = f;

        if (endDraggingCallback != null)
            getView().setTouchActionListener(this);
    }

    @LuaApiUsed
    public void setStartDeceleratingCallback(LuaFunction f) {
        if (startDeceleratingCallback != null)
            startDeceleratingCallback.destroy();
        startDeceleratingCallback = f;
        if (startDeceleratingCallback != null) {
            getView().setFlingListener(this);
        }
    }

    @LuaApiUsed
    public void getContentInset() {
    }

    //<editor-fold desc="view group">
    @LuaApiUsed
    public void addView(UDView v) {
        if (v == null) {
            ErrorUtils.debugLuaError("call addView(nil)!", globals);
            return;
        }
        insertView(v, -1);
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void insertView(UDView view, int index) {
        index --;
        NodeLayout v = getView().getContentView();
        if (v == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();

        if (index > getView().getChildCount()) {
            index = -1;//index越界时，View放在末尾
        }

        //判断Layout，是否需要转换virtual
        if (sub instanceof IVirtualLayout &&
                !((IVirtualLayout) sub).isVirtual() &&//非虚拟layout
                view.needConvertVirtual()) {//无交互或背景
            ((IVirtualLayout) sub).changeToVirtual();
        }

        if (layoutParams != null) {
            v.addView(VirtualViewUtil.removeFromParent(sub, view.getFlexNode()), index, layoutParams, ((IFlexLayout) view).getFlexNode());
        } else {
            v.addView(VirtualViewUtil.removeFromParent(sub, view.getFlexNode()), index, ((IFlexLayout) view).getFlexNode());
        }
        getFlexNode().dirty();
    }

    @LuaApiUsed
    public void removeAllSubviews() {
        ViewGroup v = getView().getContentView();
        if (v == null)
            return;
        v.removeAllViews();
        getFlexNode().dirty();
        return;
    }

    @LuaApiUsed
    public void a_flingSpeed(float s) {
        ViewGroup v = getView().getContentView();
        if (v == null)
            return;
        getView().setFlingSpeed(s);
        return;
    }
    //</editor-fold>
    //</editor-fold>

    @Override
    public void clipToBounds(boolean clip) {
        view.setClipToPadding(clip);
        view.setClipChildren(clip);
        view.getContentView().setClipToPadding(clip);
        view.getContentView().setClipChildren(clip);
        forceClip = clip;
        onClipChanged();
    }
    //</editor-fold>

    //<editor-fold desc="OnScrollListener">
    @Override
    public void onBeginScroll() {

        if (scrollBeginCallback != null)
            callbackWithPoint(scrollBeginCallback);
    }

    @Override
    public void onScrolling() {
        if (scrollingCallback != null) {
            callbackWithPoint(scrollingCallback);
        }
    }

    @Override
    public void onScrollEnd() {
        if (scrollEndCallback != null)
            callbackWithPoint(scrollEndCallback);
    }

    @Override
    public void onActionUp() {
        if (endDraggingCallback != null)
            callbackWithPoint(endDraggingCallback);
    }

    @Override
    public void onFling() {
        if (startDeceleratingCallback != null)
            callbackWithPoint(startDeceleratingCallback);
    }

    //</editor-fold>

    private void callbackWithPoint(LuaFunction c) {
        View v = getView().getScrollView();
        float sx = DimenUtil.pxToDpi(v.getScrollX());
        float sy = DimenUtil.pxToDpi(v.getScrollY());
        c.fastInvoke(sx, sy);
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }
}