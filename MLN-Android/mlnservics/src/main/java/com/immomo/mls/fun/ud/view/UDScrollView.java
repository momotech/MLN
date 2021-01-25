/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.util.AttributeSet;
import android.util.Xml;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.R;
import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.constants.ScrollDirection;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ui.IScrollView;
import com.immomo.mls.fun.ui.LuaScrollViewContainer;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LuaViewUtil;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;
import org.xmlpull.v1.XmlPullParser;

import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;


/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaApiUsed
public class UDScrollView<V extends ViewGroup & IScrollView> extends UDViewGroup<V>
        implements IScrollView.OnScrollListener,IScrollView.touchActionListener,IScrollView.FlingListener, View.OnTouchListener {
    public static final String LUA_CLASS_NAME = "ScrollView";
    public static final String[] methods = {
            "width",
            "height",
            "contentSize",
            "contentOffset",
            "scrollEnabled",
            "showsHorizontalScrollIndicator",
            "showsVerticalScrollIndicator",
            "i_bounces",
            "i_bounceHorizontal",
            "i_bounceVertical",
            "i_pagingEnabled",
            "setScrollEnable",
            "setScrollBeginCallback",
            "setScrollingCallback",
            "setScrollEndCallback",
            "setContentInset",
            "setOffsetWithAnim",
            "setEndDraggingCallback",
            "setStartDeceleratingCallback",
            "getContentInset",
            "removeAllSubviews",
            "a_flingSpeed",
    };

    private LuaFunction scrollBeginCallback;
    private LuaFunction scrollingCallback;
    private LuaFunction scrollEndCallback;
    private LuaFunction endDraggingCallback;
    private LuaFunction touchDownCallback;
    private LuaFunction startDeceleratingCallback;
    private boolean touchListenerAdded = false;

    Size mSize;

    @LuaApiUsed
    protected UDScrollView(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected V newView(LuaValue[] init) {
        boolean vertical = true;
        boolean linear = false;
        if (init.length == 1) {
            if (init[0].isNumber())
                vertical = init[0].toInt() == ScrollDirection.VERTICAL ;

            if (init[0].isBoolean())
                vertical = !init[0].toBoolean();
        } else if (init.length == 2) {
            vertical = !init[0].toBoolean();
            linear = init[1].toBoolean();
        }

        return (V) new LuaScrollViewContainer(getContext(), this,vertical, linear,getAttributeSet());
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

    private void initSize() {
        if (mSize == null)
            mSize = new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
    }

    @LuaApiUsed
    @Override
    public LuaValue[] width(LuaValue[] varargs) {
        initSize();

        if (varargs.length == 1) {
            float w = (float) varargs[0].toDouble();
            if (w == MeasurementType.WRAP_CONTENT) {
                setWidth(w);
                mSize.setWidth(Size.WRAP_CONTENT);
            } else if (w == MeasurementType.MATCH_PARENT) {
                setWidth(w);
                mSize.setWidth(Size.MATCH_PARENT);
            } else if (w < 0 ) {
                checkSize(w);
                setWidth(0);
                mSize.setWidth(0);
            } else {
                setWidth(DimenUtil.dpiToPx(w));
                mSize.setWidth(w);
            }
            setContentSize(mSize);
            return null;
        }
        return super.width(varargs);
    }

    @LuaApiUsed
    @Override
    public LuaValue[] height(LuaValue[] varargs) {
        initSize();

        if (varargs.length == 1) {
            float h = (float) varargs[0].toDouble();
            if (h == MeasurementType.WRAP_CONTENT) {
                setHeight(h);
                mSize.setHeight(Size.WRAP_CONTENT);
            } else if (h == MeasurementType.MATCH_PARENT) {
                setHeight(h);
                mSize.setHeight(Size.MATCH_PARENT);
            } else if (h < 0) {
                checkSize(h);
                setHeight(0);
                mSize.setHeight(0);
            } else {
                setHeight(DimenUtil.dpiToPx(h));
                mSize.setHeight(h);
            }
            setContentSize(mSize);
            return null;
        }

        return super.height(varargs);
    }

    @Override
    public LuaValue[] padding(LuaValue[] p) {
        getView().getScrollView().setPadding(
                DimenUtil.dpiToPx((float) p[3].toDouble()),
                DimenUtil.dpiToPx((float) p[0].toDouble()),
                DimenUtil.dpiToPx((float) p[1].toDouble()),
                DimenUtil.dpiToPx((float) p[2].toDouble()));
        return null;
    }

    protected void setContentSize(Size size) {
        getView().setContentSize(size);
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    public LuaValue[] contentSize(LuaValue[] p) {
        if (p.length == 1) {
            setContentSize(((UDSize) p[0]).getSize());
            p[0].destroy();
            return null;
        }
        return varargsOf(new UDSize(globals, getView().getContentSize()));
    }

    @LuaApiUsed
    public LuaValue[] contentOffset(LuaValue[] p) {
        if (p.length == 1) {
            getView().setContentOffset(((UDPoint) p[0]).getPoint());
            p[0].destroy();
            return null;
        }
        return varargsOf(new UDPoint(globals, getView().getContentOffset()));
    }

    @LuaApiUsed
    public LuaValue[] scrollEnabled(LuaValue[] p) {
        if (p.length == 1) {
            getView().setEnabled(p[0].toBoolean());
            return null;
        }
        return rBoolean(getView().isEnabled());
    }

    @LuaApiUsed
    public LuaValue[] showsHorizontalScrollIndicator(LuaValue[] p) {
        if (p.length == 1) {
            getView().setHorizontalScrollBarEnabled(p[0].toBoolean());
            return null;
        }
        return rBoolean(getView().isHorizontalScrollBarEnabled());
    }

    @LuaApiUsed
    public LuaValue[] showsVerticalScrollIndicator(LuaValue[] p) {
        if (p.length == 1) {
            getView().setVerticalScrollBarEnabled(p[0].toBoolean());
            return null;
        }
        return rBoolean(getView().isVerticalScrollBarEnabled());
    }

    @LuaApiUsed
    public LuaValue[] setScrollEnable(LuaValue[] p) {
        getView().setScrollEnable(p[0].toBoolean());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] i_bounces(LuaValue[] bounces) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] i_bounceHorizontal(LuaValue[] bounces) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] i_bounceVertical(LuaValue[] bounces) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] i_pagingEnabled(LuaValue[] bounces) {
        return null;
    }

    //</editor-fold>

    @Override
    public void insertView(UDView view, int index) {
        ViewGroup v = getView().getContentView();
        if (v == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();
        if (v instanceof ILViewGroup) {
            ILViewGroup g = (ILViewGroup) v;
            layoutParams = g.applyLayoutParams(layoutParams,
                    view.udLayoutParams);
            layoutParams = g.applyChildCenter(layoutParams, view.udLayoutParams);
        }

        if (index > getView().getChildCount()) {
            index = -1;//index越界时，View放在末尾
        }

        v.addView(LuaViewUtil.removeFromParent(sub), index, layoutParams);
    }
    //<editor-fold desc="Method">

    @LuaApiUsed
    public LuaValue[] setScrollBeginCallback(LuaValue[] p) {
        if (scrollBeginCallback != null)
            scrollBeginCallback.destroy();
        this.scrollBeginCallback = p[0].toLuaFunction();
        if (scrollBeginCallback != null)
            getView().setOnScrollListener(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setScrollingCallback(LuaValue[] p) {
        if (scrollingCallback != null)
            scrollingCallback.destroy();
        this.scrollingCallback = p[0].toLuaFunction();
        if (scrollingCallback != null)
            getView().setOnScrollListener(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setScrollEndCallback(LuaValue[] p) {
        if (scrollEndCallback != null)
            scrollEndCallback.destroy();
        this.scrollEndCallback = p[0].toLuaFunction();
        if (scrollEndCallback != null)
             getView().setOnScrollListener(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setContentInset(LuaValue[] v) {
        destroyAllParams(v);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setOffsetWithAnim(LuaValue[] p) {
        getView().setOffsetWithAnim(((UDPoint) p[0]).getPoint());
        p[0].destroy();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setEndDraggingCallback(LuaValue[] p) {
        if (endDraggingCallback != null)
            endDraggingCallback.destroy();
        endDraggingCallback = p[0].toLuaFunction();

        if (endDraggingCallback != null)
            getView().setTouchActionListener(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] touchBegin(LuaValue[] p) {
        if (touchDownCallback != null)
            touchDownCallback.destroy();
        touchDownCallback = p[0].toLuaFunction();

        if (touchDownCallback != null)
            getView().setTouchActionListener(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setStartDeceleratingCallback(LuaValue[] p) {
        if (startDeceleratingCallback != null)
            startDeceleratingCallback.destroy();
        startDeceleratingCallback = p[0].toLuaFunction();
        if (startDeceleratingCallback != null) {
            getView().setFlingListener(this);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] getContentInset(LuaValue[] p) {
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeAllSubviews(LuaValue[] p) {
        ViewGroup v = getView().getContentView();
        if (v == null)
            return null;
        v.removeAllViews();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] a_flingSpeed(LuaValue[] p) {
        ViewGroup v = getView().getContentView();
        if (v == null)
            return null;
        getView().setFlingSpeed(p[0].toFloat());
        return null;
    }

    @Override
    @LuaApiUsed
    public LuaValue[] clipToBounds(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        view.setClipToPadding(clip);
        view.setClipChildren(clip);
        view.getContentView().setClipToPadding(clip);
        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP: LEVEL_FORCE_NOTCLIP);
        }
        return null;
    }
    //</editor-fold>
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
    public void onTouchDown() {
        if (touchDownCallback != null)
            callbackWithPoint(touchDownCallback);
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
        c.invoke(varargsOf(LuaNumber.valueOf(sx), LuaNumber.valueOf(sy)));
    }

    private void callbackWithPoint(LuaFunction c, boolean ecelerating) {
        View v = getView().getScrollView();
        float sx = DimenUtil.pxToDpi(v.getScrollX());
        float sy = DimenUtil.pxToDpi(v.getScrollY());
        c.invoke(varargsOf(LuaNumber.valueOf(sx), LuaNumber.valueOf(sy), LuaBoolean.valueOf(ecelerating)));
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }
}