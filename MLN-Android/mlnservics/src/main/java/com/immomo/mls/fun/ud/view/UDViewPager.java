/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.view.View;
import android.widget.FrameLayout;

import com.immomo.mls.Environment;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.view.viewpager.UDViewPagerAdapter;
import com.immomo.mls.fun.ud.view.viewpager.ViewPagerAdapter;
import com.immomo.mls.fun.ud.view.viewpager.ViewPagerContent;
import com.immomo.mls.fun.ui.DefaultPageIndicator;
import com.immomo.mls.fun.ui.IViewPager;
import com.immomo.mls.fun.ui.LuaViewPager;
import com.immomo.mls.fun.weight.LuaViewPagerContainer;
import com.immomo.mls.utils.ErrorUtils;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Function3;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.viewpager.widget.PagerAdapter;

/**
 * Created by fanqiang on 2018/8/30.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDViewPager<T extends FrameLayout & IViewPager> extends UDViewGroup<T> implements View.OnClickListener {
    public static final String LUA_CLASS_NAME = "ViewPager";
    public static final String[] methods = new String[]{
            "frame",
            "adapter",
            "reloadData",
            "autoScroll",
            "recurrence",
            "frameInterval",
            "endDragging",
            "showIndicator",
            "scrollToPage",
            "currentPage",
            "setPreRenderCount",
            "setScrollEnable",
            "aheadLoad",
            "cellWillAppear",
            "cellDidDisappear",
            "setPageClickListener",
            "currentPageColor",
            "pageDotColor",
            "setTabScrollingListener",
            "onChangeSelected"
    };
    private UDViewPagerAdapter adapter;
    private LuaFunction endDragFun;
    private LuaFunction cellWillAppearFun;
    private LuaFunction cellDidDisappearFun;
    private LuaFunction funOnPageClick;
    private LuaFunction mTabScrollingProgressFunction;
    private LuaFunction mPageSelectedFunction;
    private int preRenderCount = 0;
    private int mIndicatorSelectedColor = DefaultPageIndicator.SELECTED_COLOR, mIndicatorDefaultColor = DefaultPageIndicator.DEFAULT_COLOR;
    private  DefaultPageIndicator  mDefaultPageIndicator;

    private boolean mDefaultAddIndicator;

    private IViewPager.Callback callback;

    // 在展示到父视图前设置 scrollToPage() 时使用
    private int mScrollToPage = 0;
    private boolean mScrollToPageAnimated = false;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public UDViewPager(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected T newView(LuaValue[] init) {
        LuaViewPagerContainer luaViewPager = new LuaViewPagerContainer(getContext(), this);
        return (T) luaViewPager;
    }

    @Override
    public T getView() {
        return super.getView();
    }

    public LuaViewPager getViewPager() {
        return (LuaViewPager) getView().getViewPager();
    }
    //<editor-fold desc="API">

    @Override
    public LuaValue[] height(LuaValue[] varargs) {
        return super.height(varargs);
    }

    @Override
    public LuaValue[] frame(LuaValue[] varargs) {
        LuaValue values[] = super.frame(varargs);
        resetPageIndicator();
        return values;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDViewPagerAdapter.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] adapter(LuaValue[] values) {
        if (values.length == 0) {
            if (this.adapter != null)
                return varargsOf(this.adapter);
            return null;
        }

        LuaValue luaValue = values[0];

        UDViewPagerAdapter udAadapter = luaValue == null ? null : (UDViewPagerAdapter) luaValue.toUserdata();
        if (this.adapter != null) {
            getView().removeCallback(this.adapter.getAdapter());
        }

        this.adapter = udAadapter;
        if (funOnPageClick != null && adapter != null) {
            this.adapter.setOnClickListener(this);
        }

        if (udAadapter != null) {
            udAadapter.setUDViewPager(this);

            ViewPagerAdapter a = udAadapter.getAdapter();


            a.setViewPager(this);

            getViewPager().setAdapter(a);
            getView().addCallback(a);
//        a.setViewPager(getView());
            a.setCanPreRenderCount(preRenderCount != 0);

            if(!checkSinglePage(adapter.getAdapter())) {
                getViewPager().setScrollable(false);
            }

            setPageIndicator();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] reloadData(LuaValue[] values) {
        if (adapter != null) {
            adapter.reloadData();
        }
        if(!checkSinglePage(adapter.getAdapter())) {
            getViewPager().setScrollable(false);
        }

        // 配合IOS 回调一致性
        callbackCellDidDisAppear(getViewPager().getCurrentItem());
        callbackCellWillAppear(getViewPager().getCurrentItem());
        return null;
    }


    public boolean isAutoScroll() {
        return getView().isAutoScroll();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] autoScroll(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null) {
            getView().setAutoScroll(values[0].toBoolean());
            return null;
        }
        return LuaValue.rBoolean(isAutoScroll());
    }

    public boolean isRepeat() {
        return getView().isRepeat();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] recurrence(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null) {
            boolean repeat = values[0].toBoolean();
            // 如果同时设置 recurrence  和  TabSegment的 relatedToViewPager， 则将 recurrence设置为false无效,配合IOS
            if (getView() instanceof LuaViewPagerContainer && getViewPager().isRelatedTabLayout() && repeat) {
                getView().setRepeat(false);
            } else {
                getView().setRepeat(repeat);
            }

            if (getViewPager().getAdapter() != null) {
                getViewPager().getAdapter().notifyDataSetChanged();
            }

            return null;
        }

        return LuaValue.rBoolean(isRepeat());
    }

    public float getFrameInterval() {
        return getView().getFrameInterval();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] frameInterval(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null) {
            getView().setFrameInterval((float) values[0].toDouble());
            return null;
        }

        return LuaValue.rNumber(getFrameInterval());
    }

    @Deprecated
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] endDragging(LuaValue[] values) {
        ErrorUtils.debugDeprecatedMethodHook("endDragging", getGlobals());

        endDragFun = values[0] == null ? null : values[0].toLuaFunction();
        if (endDragFun != null) {
            if (callback == null) {
                callback = new C();
            }
        } else {
            callback = null;
        }
        getView().addCallback(callback);
        return null;
    }

    public boolean isShowIndicator() {
        return getView().getPageIndicator() != null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] showIndicator(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null) {
            mDefaultAddIndicator = values[0].toBoolean();
            setPageIndicator();
            return null;
        }
        return LuaValue.rBoolean(isShowIndicator());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] scrollToPage(LuaValue[] values) {
        if (getViewPager().getAdapter() == null) {
            mScrollToPage = values[0].toInt() - 1;
            mScrollToPageAnimated = values[1].toBoolean();
            return null;
        }
        int position = values[0].toInt();

        // 判断是否 越界
        PagerAdapter adapter = getViewPager().getAdapter();
        if (MLSEngine.DEBUG && adapter != null && (position - 1 >= adapter.getCount() || position - 1 < 0)) {
            Exception exception = new IndexOutOfBoundsException("Page index out of range! ");
            Environment.hook(exception, globals);
            return null;
        }

        getViewPager().setCurrentItem(position - 1, values[1].toBoolean());
        getViewPager().setLastPosition(position - 1);
        return null;
    }

    @Override
    public void onAttached() {
        super.onAttached();
        if (mScrollToPage != 0)
            getViewPager().setCurrentItem(mScrollToPage, mScrollToPageAnimated);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] currentPage(LuaValue[] values) {

        ViewPagerAdapter viewPagerAdapter = ((ViewPagerAdapter) getViewPager().getAdapter());

        if (isRecurrenceRepeat(viewPagerAdapter)) {

            return LuaValue.rNumber(getViewPager().getCurrentItem() % viewPagerAdapter.getRealCount() + 1);
        }

        return LuaValue.rNumber(getViewPager().getCurrentItem() + 1);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] currentPageColor(LuaValue[] values) {
        if (values.length >= 1) {
            mIndicatorSelectedColor = ((UDColor) values[0]).getColor();
            if (mDefaultPageIndicator != null)
                mDefaultPageIndicator.setFillColor(mIndicatorSelectedColor);
        }

        return mDefaultPageIndicator == null ? null : varargsOf(new UDColor(getGlobals(), mDefaultPageIndicator.getFillColor()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] pageDotColor(LuaValue[] values) {
        if (values.length >= 1) {
            mIndicatorDefaultColor = ((UDColor) values[0]).getColor();
            if (mDefaultPageIndicator != null)
                mDefaultPageIndicator.setPageColor(mIndicatorDefaultColor);
        }

        return mDefaultPageIndicator == null ? null : varargsOf(new UDColor(getGlobals(), mDefaultPageIndicator.getPageColor()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] setPreRenderCount(LuaValue[] values) {
        int count = values[0].toInt();
        preRenderCount = count;

        if (count < 1)
            count = 1;

        getViewPager().setOffscreenPageLimit(count);

        if (adapter != null) {
            adapter.getAdapter().setCanPreRenderCount(preRenderCount != 0);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] setScrollEnable(LuaValue[] values) {
        getViewPager().setScrollable(values[0].toBoolean());
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] bgColor(LuaValue[] var) {
        if (var.length == 1 && var[0] instanceof UDColor) {
            getView().setBackgroundColor(((UDColor) var[0]).getColor());
            return null;
        }
        UDColor ret = new UDColor(getGlobals(), getBgColor());
        return varargsOf(ret);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDViewPager.class)),
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(Boolean.class))
    })
    public LuaValue[] aheadLoad(LuaValue[] values) {
        if (values.length >= 1 && values[0] != null && values[0].isBoolean()) {
            if (values[0].toBoolean()) {
                setPreRenderCount(LuaValue.rNumber(1));
            } else {
                setPreRenderCount(LuaValue.rNumber(0));
            }
            return null;
        }
        return LuaValue.rBoolean(preRenderCount > 0);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {LuaValue.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] cellWillAppear(LuaValue[] values) {
        cellWillAppearFun = values[0].toLuaFunction();
        getViewPager().firstAttachAppearZeroPosition();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function2.class, typeArgs = {LuaValue.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] cellDidDisappear(LuaValue[] values) {
        cellDidDisappearFun = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] setPageClickListener(LuaValue[] values) {
        funOnPageClick = values[0].toLuaFunction();
        if (funOnPageClick != null && adapter != null) {
            adapter.setOnClickListener(this);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function3.class, typeArgs = {Float.class, Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] setTabScrollingListener(LuaValue[] v) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.destroy();
        mTabScrollingProgressFunction = v[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(UDViewPager.class))
    })
    public LuaValue[] onChangeSelected(LuaValue[] v) {
        if (mPageSelectedFunction != null)
            mPageSelectedFunction.destroy();
        mPageSelectedFunction = v[0].toLuaFunction();
        return null;
    }
    //</editor-fold>


    @Override
    public void setCornerRadiusWithDirection(float radius, int direcion) {
        super.setCornerRadiusWithDirection(radius, direcion);

        if (adapter != null && adapter.getAdapter() != null)
            adapter.getAdapter().notifyDataSetChanged();
    }

    public void resetPageIndicator() {
        getView().setPageIndicator(null);
        setPageIndicator();
    }

    private void setPageIndicator() {
        if (mDefaultAddIndicator) {
            if (getView().getPageIndicator() == null) {
                mDefaultPageIndicator = new DefaultPageIndicator(getContext());
                mDefaultPageIndicator.setFillColor(mIndicatorSelectedColor);
                mDefaultPageIndicator.setPageColor(mIndicatorDefaultColor);
                getView().setPageIndicator(mDefaultPageIndicator);
            }
            mDefaultPageIndicator.invalidate();
        } else
            getView().setPageIndicator(null);
    }

    @Override
    public void onClick(View v) {
        callPageClick(getViewPager().getCurrentItem() + 1);
    }

    private final class C implements IViewPager.Callback {

        @Override
        public void callbackEndDrag(int p) {


            p = getRecurrencePosition(p);

            if (endDragFun != null) {
                endDragFun.invoke(LuaNumber.rNumber(p + 1));
            }
        }

        @Override
        public void callbackStartDrag(int p) {

        }
    }

    public int getRecurrencePosition(int p) {
        ViewPagerAdapter viewPagerAdapter = ((ViewPagerAdapter) getViewPager().getAdapter());

        if (isRecurrenceRepeat(viewPagerAdapter)) {
            p = p % viewPagerAdapter.getRealCount();
        }
        return p;
    }

    public void callbackCellWillAppear(int position) {
        if (cellWillAppearFun != null) {

            position = getRecurrencePosition(position);

            LuaValue cellLuaValue = getCellAtPosition(position);
            if (cellLuaValue.isNil())
                return;

            cellWillAppearFun.invoke(varargsOf(cellLuaValue, LuaNumber.valueOf(position + 1)));

            if (position == 0)
                getViewPager().mFirstAttach = false;
        }


    }

    public void callbackCellDidDisAppear(int position) {
        if (cellDidDisappearFun != null) {

            position = getRecurrencePosition(position);

            LuaValue cell = getCellAtPosition(position);
            if (cell.isNil())
                return;
            cellDidDisappearFun.invoke(varargsOf(cell, LuaNumber.valueOf(position + 1)));
        }
    }

    public void callPageClick(int position) {
        if (funOnPageClick != null) {

            ViewPagerAdapter viewPagerAdapter = ((ViewPagerAdapter) getViewPager().getAdapter());

            if (isRecurrenceRepeat(viewPagerAdapter)) {
                funOnPageClick.invoke(LuaValue.rNumber(getViewPager().getCurrentItem() % viewPagerAdapter.getRealCount() + 1));
            } else
                funOnPageClick.invoke(LuaValue.rNumber(position));
        }
    }

    public boolean isRecurrenceRepeat(ViewPagerAdapter viewPagerAdapter) {
        return viewPagerAdapter != null && viewPagerAdapter.recurrenceRepeat() && viewPagerAdapter.getRealCount() > 1;
    }


    private LuaValue getCellAtPosition(int position) {
        if (adapter == null)
            return LuaValue.Nil();

        ViewPagerContent content = adapter.getAdapter().getViewPagerContentAt(position);
        if (content != null) {
            return content.getCell();
        }
        return LuaValue.Nil();
    }

    /**
     * 单页不滑动
     */
    private boolean checkSinglePage(ViewPagerAdapter a) {
        return a.getRealCount() != 1;
    }

    public void callTabScrollProgress(float progresss, int fromIndex, int toIndex) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.invoke(varargsOf(LuaNumber.valueOf(progresss), LuaNumber.valueOf(fromIndex + 1), LuaNumber.valueOf(toIndex + 1)));
    }

    public DefaultPageIndicator getDefaultPageIndicator() {
        return mDefaultPageIndicator;
    }

    public void pageSelectedCallback(int position) {
        if (mPageSelectedFunction != null)
            mPageSelectedFunction.invoke(varargsOf(LuaNumber.valueOf(position + 1)));
    }

}