/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.graphics.Color;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.core.view.ViewCompat;
import androidx.viewpager.widget.ViewPager;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.constants.TabSegmentAlignment;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Rect;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDRect;
import com.immomo.mls.fun.ui.ITabLayoutScrollProgress;
import com.immomo.mls.fun.ui.LuaTabLayout;
import com.immomo.mls.fun.ui.LuaViewPager;
import com.immomo.mls.tabinfo.DefaultSlidingIndicator;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.weight.BaseTabLayout;
import com.immomo.mls.weight.TextDotTabInfoLua;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function3;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;


/**
 * Created by fanqiang on 2018/9/14.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDTabLayout<T extends LuaTabLayout> extends UDViewGroup<T> implements ITabLayoutScrollProgress {

    public static final String LUA_CLASS_NAME = "TabSegmentView";

    public static final String[] methods = {
            "setTabSelectedListener",
            "setItemTabClickListener",
            "selectScale",
            "normalFontSize",
            "tintColor",
            "currentIndex",
            "relatedToViewPager",
            "setCurrentIndexAnimated",
            "setTapBadgeNumAtIndex",
            "setTapBadgeTitleAtIndex",
            "setAlignment",
            "setTabSpacing",
            "setTapTitleAtIndex",
            "setRedDotHiddenAtIndex",
            "changeRedDotStatusAtIndex",
            "selectedColor",
            "setTabScrollingListener",
            "indicatorColor",
            "removeTab",
            "setIndicatorHeight"

    };

    private LuaFunction addTabSelectedCallback;

    private LuaFunction itemClickCallBackFunction;
    private LuaFunction mTabScrollingProgressFunction;

    public static final int DEFAULT_COLOR = Color.argb(255, 170, 170, 170);
    private static final int DEFAULT_SELECT_COLOR = Color.argb(255, 50, 51, 51);

    private int textColor = DEFAULT_COLOR;
    private int selectTextColor = DEFAULT_SELECT_COLOR;
    private int indicatorColor = DEFAULT_SELECT_COLOR;

    private boolean mLuaSetIndicatorColor = false;

    private ViewPager mViewPager = null;

    private int mAlign;
    DefaultSlidingIndicator indicator = null;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDRect.class),
                    @LuaApiUsed.Type(UDArray.class),
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDRect.class),
                    @LuaApiUsed.Type(UDArray.class),
                    @LuaApiUsed.Type(value = UDColor.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public UDTabLayout(long L, LuaValue[] v) {
        super(L, v);
        mAlign = TabSegmentAlignment.LEFT;
        init(v);
    }

    private BaseTabLayout getTabLayout() {
        return getView().getTabLayout();
    }

    private void init(LuaValue[] varargs) {
        getTabLayout().setTabMode(BaseTabLayout.MODE_SCROLLABLE);
        indicator = new DefaultSlidingIndicator(getContext());
        getTabLayout().setSelectedTabSlidingIndicator(indicator);
        getTabLayout().addOnTabSelectedListener(tabSelectedListener);
        if (varargs == null) {
            throw new IllegalArgumentException();
        }
        if (varargs.length > 2) {
            UDColor color = (UDColor) varargs[2];
            textColor = color.getColor();
            indicator.setColor(selectTextColor);
        }
        getTabLayout().setTabTextColors(textColor, textColor);

        if (varargs[0] instanceof UDRect && varargs[1] instanceof UDArray) {
            Rect rect = ((UDRect) varargs[0]).getRect();
            Point point = rect.getPoint();
            Size size = rect.getSize();
            setWidth(size.getWidthPx());
            setHeight(size.getHeightPx());
            setX((int) point.getXPx());
            setY((int) point.getYPx());
            addTabs(((UDArray) varargs[1]).getArray());
        } else if (varargs[0] instanceof UDRect && varargs[1] instanceof LuaTable) {
            Rect rect = ((UDRect) varargs[0]).getRect();
            Point point = rect.getPoint();
            Size size = rect.getSize();
            setWidth(size.getWidthPx());
            setHeight(size.getHeightPx());
            setX((int) point.getXPx());
            setY((int) point.getYPx());
            addTabs((ConvertUtils.toList(varargs[1].toLuaTable())));
        }

        /*else if (varargs[1] instanceof UDPoint && varargs[0] instanceof UDArray) {
            Point point = ((UDPoint) varargs[1]).getPoint();
            setX((int) point.getXPx());
            setY((int) point.getYPx());
            setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
            setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
            addTabs(((UDArray) varargs[0]).getArray());
        }*/
        else {
            throw new IllegalArgumentException();
        }
    }

    @Override
    protected T newView(LuaValue[] init) {
        return (T) new LuaTabLayout(getContext(), this, init);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTabSelectedListener(LuaValue[] v) {
        if (addTabSelectedCallback != null)
            addTabSelectedCallback.destroy();
        addTabSelectedCallback = v[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setItemTabClickListener(LuaValue[] v) {
        if (itemClickCallBackFunction != null)
            itemClickCallBackFunction.destroy();
        itemClickCallBackFunction = v[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setIndicatorHeight(LuaValue[] v) {
        if (v.length > 0) {
            int height = (int) v[0].toInt();
            int h = DimenUtil.dpiToPx(height);
            int cs = DimenUtil.check(h);
            indicator.setHeight(cs);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(getHeight())));
    }


    @LuaApiUsed
    public LuaValue[] removeTab(LuaValue[] v) {
        int index = (int) v[0].toInt();
        if (getTabLayout().getTabCount() > index) {
            BaseTabLayout.Tab tab = getTabLayout().getTabAt(index);
            if (tab != null) {
                getTabLayout().removeTab(tab);
            }
        }
        return null;
    }

    //<editor-fold>
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] selectScale(LuaValue[] v) {
        if (v.length == 0) {
            if (getTabLayout().getTabCount() >= 1) {
                BaseTabLayout.Tab tab = getTabLayout().getTabAt(0);
                TextDotTabInfoLua info = tab.getTabInfo();
                return varargsOf(LuaNumber.valueOf(info.getSelectScale()));
            }
            return varargsOf(LuaNumber.valueOf(0));
        }
        for (int i = 0; i < getTabLayout().getTabCount(); i++) {
            BaseTabLayout.Tab tab = getTabLayout().getTabAt(i);
            TextDotTabInfoLua info = tab.getTabInfo();
            info.setSelectScale((float) v[0].toDouble());
        }
        int selectedTab = getTabLayout().getSelectedTabPosition();
        if (selectedTab != BaseTabLayout.Tab.INVALID_POSITION) {
            BaseTabLayout.Tab tab = getTabLayout().getTabAt(selectedTab);
            if (tab != null) {
                tab.select();
                TextDotTabInfoLua info = tab.getTabInfo();
                info.upDataScale(getTabLayout());
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] normalFontSize(LuaValue[] v) {
        if (v.length == 0) {
            if (getTabLayout().getTabCount() >= 1) {
                BaseTabLayout.Tab tab = getTabLayout().getTabAt(0);
                TextDotTabInfoLua info = tab.getTabInfo();
                return varargsOf(LuaNumber.valueOf(DimenUtil.pxToSp(info.getNormalFontSize())));
            }
            return varargsOf(LuaNumber.valueOf(0));
        }
        for (int i = 0; i < getTabLayout().getTabCount(); i++) {
            BaseTabLayout.Tab tab = getTabLayout().getTabAt(i);
            TextDotTabInfoLua info = tab.getTabInfo();
            info.setNormalFontSize((float) v[0].toDouble());
        }
        getView().requestLayout();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] tintColor(LuaValue[] v) {
        if (v.length == 0) {
            UDColor ret = new UDColor(getGlobals(), this.textColor);
            return varargsOf(ret);
        }

        this.textColor = ((UDColor) v[0]).getColor();
        // getTabLayout().setTabTextColors(this.textColor, this.textColor);

        setSelectedColor(getTabLayout().getSelectedTabPosition());
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] selectedColor(LuaValue[] v) {
        if (v.length == 0) {
            UDColor ret = new UDColor(getGlobals(), this.selectTextColor);
            return varargsOf(ret);
        }

        this.selectTextColor = ((UDColor) v[0]).getColor();

        setSelectedColor(getTabLayout().getSelectedTabPosition());

        if (!mLuaSetIndicatorColor) {
            setIndicatorColor(this.selectTextColor);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDColor.class))
    })
    public LuaValue[] indicatorColor(LuaValue[] v) {
        if (v.length == 0) {
            UDColor ret = new UDColor(getGlobals(), this.indicatorColor);
            return varargsOf(ret);
        }

        this.indicatorColor = ((UDColor) v[0]).getColor();
        setIndicatorColor(this.indicatorColor);
        mLuaSetIndicatorColor = true;
        return null;
    }

    private void setIndicatorColor(int color) {
        indicator.setColor(color);
        (getView()).getTabLayout().getTabStrip().invalidate();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function3.class, typeArgs = {Float.class, Integer.class, Integer.class, Unit.class})
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTabScrollingListener(LuaValue[] v) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.destroy();
        mTabScrollingProgressFunction = v[0].toLuaFunction();
        getTabLayout().setmITabLayoutScrollProgress(this);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] currentIndex(LuaValue[] v) {
        if (v.length != 0) {
            getTabLayout().setSelectedTabPosition(v[0].toInt() - 1);
            return null;
        }

        return rNumber(getTabLayout().getSelectedTabPosition() + 1);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDViewPager.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] relatedToViewPager(LuaValue[] v) {
        if (v.length == 0 || v[0].isNil()) {
            return null;
        }

        mViewPager = ((UDViewPager) v[0]).getViewPager();

        boolean animated = true;
        if (v.length >= 2)
            animated = v[1].toBoolean();

        if (mViewPager != null && ((LuaViewPager) mViewPager).isRepeat()) {

            ((LuaViewPager) mViewPager).setRelatedTabLayout(true);
            ((LuaViewPager) mViewPager).setRepeat(false);

            if (mViewPager.getAdapter() != null)
                mViewPager.getAdapter().notifyDataSetChanged();
        }

        mViewPager.addOnPageChangeListener(new BaseTabLayout.TabLayoutOnPageChangeListener(getTabLayout(), this));
        getTabLayout().addOnTabSelectedListener(new BaseTabLayout.ViewPagerOnTabSelectedListener(mViewPager, animated));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setCurrentIndexAnimated(LuaValue[] v) {
        if (v.length != 0) {
            final int index = v[0].toInt();
            if (!ViewCompat.isLaidOut(getTabLayout()))
                MainThreadExecutor.postDelayed(getTag(), new Runnable() {
                    @Override
                    public void run() {
                        getTabLayout().setSelectedTabPosition(index - 1);
                    }
                }, 10);
            else
                getTabLayout().setSelectedTabPosition(index - 1);
        }
        return null;
    }

    private Object getTag() {
        return "UDTabLayout" + hashCode();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTapBadgeNumAtIndex(LuaValue[] v) {
        if (!v[0].isNumber() || !v[1].isNumber()) {//参数不是number，直接返回
            return null;
        }
        int number = v[0].toInt();
        int index = v[1].toInt() - 1;
        if (index > getTabLayout().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getTabLayout().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (number == 0)
            info.setHint("");
        else
            info.setHint(String.valueOf(number));
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTapBadgeTitleAtIndex(LuaValue[] v) {
        if (v[0].isNil()) {
            IllegalArgumentException e = new IllegalArgumentException("setTapBadgeTitleAtIndex() method  title cannot be nil ");
            if (!Environment.hook(e, getGlobals())) {
                throw e;
            }
        }

        String title = v.length > 0 && !v[0].isNil() ? v[0].toJavaString() : null;
        int index = v[1].toInt() - 1;
        if (index > getTabLayout().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getTabLayout().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (title != null && title.length() > 0)
            info.setHint(title);
        else
            info.setHint("");
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setAlignment(LuaValue[] alignment) {

        if (alignment.length == 1) {
            LuaValue value = alignment[0];

            if (value != null && value.type() == LUA_TNUMBER) {
                mAlign = (int) (value.toDouble());
            }
        }

        setAlign();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTabSpacing(LuaValue[] v) {
        float tabSpacing = (float) v[0].toDouble();
        BaseTabLayout.SlidingTabStrip slidingTabStrip = getTabLayout().getTabStrip();

        if (slidingTabStrip == null)
            return null;

        for (int i = 0, size = slidingTabStrip.getChildCount(); i < size; i++) {
            View subview = slidingTabStrip.getChildAt(i);

            ViewGroup.LayoutParams params = subview.getLayoutParams();
            if (params instanceof ViewGroup.MarginLayoutParams) {
                ((ViewGroup.MarginLayoutParams) params).rightMargin = DimenUtil.dpiToPx(tabSpacing);
            }

            if (v.length > 1) {
                float padding = (float) v[1].toDouble();
                int paddingInt = (int) padding;
                getTabLayout().setStartEndPadding((padding));

                ViewCompat.setPaddingRelative(subview, paddingInt, paddingInt,
                        paddingInt, paddingInt);

            }

            subview.setLayoutParams(params);
        }

        slidingTabStrip.requestLayout();
        return null;
    }


    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class),
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setRedDotHiddenAtIndex(LuaValue[] v) {
        int index = v[0].toInt() - 1;
        if (index > getTabLayout().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getTabLayout().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (v.length > 1 && v[1].toBoolean())
            info.setHasDot(true);
        else
            info.setHasDot(false);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Integer.class),
                    @LuaApiUsed.Type(value = Boolean.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] changeRedDotStatusAtIndex(LuaValue[] v) {
        setRedDotHiddenAtIndex(v);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(name = "title", value = String.class),
                    @LuaApiUsed.Type(name = "index", value = Integer.class)
            }, returns = @LuaApiUsed.Type(value = UDTabLayout.class))
    })
    public LuaValue[] setTapTitleAtIndex(LuaValue[] v) {
        String title = v.length > 0 ? v[0].toJavaString() : null;
        int index = v.length > 1 ? v[1].toInt() - 1 : -1;
        if (!TextUtils.isEmpty(title) && index >= 0 && getTabLayout().getTabCount() > index) {
            BaseTabLayout.Tab tab = getTabLayout().getTabAt(index);
            if (tab != null)
                tab.setText(title);
        }
        return null;
    }

    //</editor-fold>

    public void setIndicatorColor() {
        if (indicatorColor != DEFAULT_SELECT_COLOR)
            indicator.setColor(indicatorColor);
        else if (selectTextColor != DEFAULT_SELECT_COLOR)
            indicator.setColor(selectTextColor);
        else
            indicator.setColor(textColor);

        getView().invalidate();
    }

    private void addTabs(List<String> array) {
        if (array == null || array.size() == 0) {
            return;
        }

        for (int i = 0, size = array.size(); i < size; i++) {
            addTab(array.get(i), i);
        }

    }

    public void addTab(String tabInfo, final int position) {
        BaseTabLayout.Tab tab = getTabLayout().newTab();

        TextDotTabInfoLua textDotTabInfoLua = new TextDotTabInfoLua(tabInfo);
        tab.setTabInfo(textDotTabInfoLua);

        getTabLayout().addTab(tab);

        if (tab.getCustomView() != null) {
            tab.getCustomView().setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    if (itemClickCallBackFunction != null)
                        itemClickCallBackFunction.invoke(varargsOf(LuaNumber.valueOf(position + 1)));

                    getTabLayout().setSelectedTabPosition(position);
                }
            });
        }

    }

    private void setAlign() {
        View parentView = getTabLayout().getChildAt(0);

        if (parentView == null)
            return;

        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) parentView.getLayoutParams();

        if (params == null)
            return;

        switch (mAlign) {
            case TabSegmentAlignment.LEFT:
                params.gravity = Gravity.LEFT;
                break;

            case TabSegmentAlignment.CENTER:
                params.gravity = Gravity.CENTER;
                break;

            case TabSegmentAlignment.RIGHT:
                params.gravity = Gravity.RIGHT;
                break;

            default:
                params.gravity = Gravity.LEFT;

        }
        parentView.setLayoutParams(params);
    }

    private BaseTabLayout.OnTabSelectedListener tabSelectedListener = new BaseTabLayout.OnTabSelectedListener() {
        @Override
        public void onTabSelected(BaseTabLayout.Tab tab) {
            if (addTabSelectedCallback != null) {
                addTabSelectedCallback.invoke(varargsOf(LuaNumber.valueOf(getTabLayout().getSelectedTabPosition() + 1)));
            }
            setSelectedColor(getTabLayout().getSelectedTabPosition());
            //tabScrollProgress(1);
        }

        @Override
        public void onTabUnselected(BaseTabLayout.Tab tab) {

        }

        @Override
        public void onTabReselected(BaseTabLayout.Tab tab) {

        }
    };

    private void setSelectedColor(int position) {

        for (int i = 0; i < getTabLayout().getTabCount(); i++) {
            BaseTabLayout.Tab tab1 = getTabLayout().getTabAt(i);
            TextDotTabInfoLua info1 = tab1.getTabInfo();
            if (position == i) {
                info1.setTitleColor(selectTextColor);
            } else
                info1.setTitleColor(textColor);
        }


    }

    @Override
    public void tabScrollProgress(double progresss, int fromIndex, int toIndex) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.invoke(varargsOf(LuaNumber.valueOf(progresss), LuaNumber.valueOf(fromIndex + 1), LuaNumber.valueOf(toIndex + 1)));
    }

    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
        MainThreadExecutor.cancelAllRunnable(getTag());

    }
}