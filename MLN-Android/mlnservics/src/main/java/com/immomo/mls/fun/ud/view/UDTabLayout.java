/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
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

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;

import androidx.core.view.ViewCompat;
import androidx.viewpager.widget.ViewPager;


/**
 * Created by fanqiang on 2018/9/14.
 */
@LuaApiUsed
public class UDTabLayout<T extends BaseTabLayout> extends UDViewGroup<T> implements ITabLayoutScrollProgress {

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
            "setTabScrollingListener"

    };

    private LuaFunction addTabSelectedCallback;

    private LuaFunction itemClickCallBackFunction;
    private LuaFunction mTabScrollingProgressFunction;

    private int textColor;
    private int selectTextColor;

    private ViewPager mViewPager = null;

    private int mAlign;
    DefaultSlidingIndicator indicator = null;

    @LuaApiUsed
    public UDTabLayout(long L, LuaValue[] v) {
        super(L, v);
        mAlign = TabSegmentAlignment.LEFT;
        init(v);
    }

    private void init(LuaValue[] varargs) {
        getView().setTabMode(BaseTabLayout.MODE_SCROLLABLE);
        indicator = new DefaultSlidingIndicator(getContext());
        getView().setSelectedTabSlidingIndicator(indicator);
        getView().addOnTabSelectedListener(tabSelectedListener);
        textColor = Color.argb(255, 50, 51, 51);
        if (varargs == null) {
            throw new IllegalArgumentException();
        }
        if (varargs.length > 2) {
            UDColor color = (UDColor) varargs[2];
            textColor = color.getColor();
            indicator.setColor(textColor);
        }
        getView().setTabTextColors(textColor, textColor);

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

    @LuaApiUsed
    public LuaValue[] setTabSelectedListener(LuaValue[] v) {
        if (addTabSelectedCallback != null)
            addTabSelectedCallback.destroy();
        addTabSelectedCallback = v[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setItemTabClickListener(LuaValue[] v) {
        if (itemClickCallBackFunction != null)
            itemClickCallBackFunction.destroy();
        itemClickCallBackFunction = v[0].toLuaFunction();
        return null;
    }

    //<editor-fold>
    @LuaApiUsed
    public LuaValue[] selectScale(LuaValue[] v) {
        if (v.length == 0) {
            if (getView().getTabCount() >= 1) {
                BaseTabLayout.Tab tab = getView().getTabAt(0);
                TextDotTabInfoLua info = tab.getTabInfo();
                return varargsOf(LuaNumber.valueOf(info.getSelectScale()));
            }
            return varargsOf(LuaNumber.valueOf(0));
        }
        for (int i = 0; i < getView().getTabCount(); i++) {
            BaseTabLayout.Tab tab = getView().getTabAt(i);
            TextDotTabInfoLua info = tab.getTabInfo();
            info.setSelectScale((float) v[0].toDouble());
        }
        int selectedTab = getView().getSelectedTabPosition();
        if (selectedTab != BaseTabLayout.Tab.INVALID_POSITION) {
            BaseTabLayout.Tab tab = getView().getTabAt(selectedTab);
            if (tab != null) {
                tab.select();
                TextDotTabInfoLua info = tab.getTabInfo();
                info.upDataScale();
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] normalFontSize(LuaValue[] v) {
        if (v.length == 0) {
            if (getView().getTabCount() >= 1) {
                BaseTabLayout.Tab tab = getView().getTabAt(0);
                TextDotTabInfoLua info = tab.getTabInfo();
                return varargsOf(LuaNumber.valueOf(DimenUtil.pxToSp(info.getNormalFontSize())));
            }
            return varargsOf(LuaNumber.valueOf(0));
        }
        for (int i = 0; i < getView().getTabCount(); i++) {
            BaseTabLayout.Tab tab = getView().getTabAt(i);
            TextDotTabInfoLua info = tab.getTabInfo();
            info.setNormalFontSize((float) v[0].toDouble());
        }
        getView().requestLayout();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] tintColor(LuaValue[] v) {
        if (v.length == 0) {
            UDColor ret = new UDColor(getGlobals(), this.textColor);
            return varargsOf(ret);
        }

        this.textColor = ((UDColor) v[0]).getColor();
        // getView().setTabTextColors(this.textColor, this.textColor);

        for (int i = 0; i < getView().getTabCount(); i++) {
            BaseTabLayout.Tab tab = getView().getTabAt(i);
            TextDotTabInfoLua info = tab.getTabInfo();
            info.setTitleColor(textColor);
        }
        setIndicatorColor(this.textColor);
        getView().invalidate();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] selectedColor(LuaValue[] v) {
        if (v.length == 0) {
            UDColor ret = new UDColor(getGlobals(), this.selectTextColor);
            return varargsOf(ret);
        }

        this.selectTextColor = ((UDColor) v[0]).getColor();

        setSelectedColor(getView().getSelectedTabPosition());
        setIndicatorColor(this.selectTextColor);
        getView().invalidate();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setTabScrollingListener(LuaValue[] v) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.destroy();
        mTabScrollingProgressFunction = v[0].toLuaFunction();
        getView().setmITabLayoutScrollProgress(this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] currentIndex(LuaValue[] v) {
        if (v.length != 0) {
            getView().setSelectedTabPosition(v[0].toInt() - 1);
            return null;
        }

        return rNumber(getView().getSelectedTabPosition() + 1);
    }

    @LuaApiUsed
    public LuaValue[] relatedToViewPager(LuaValue[] v) {
        if (v.length == 0 || v[0].isNil()) {
            return null;
        }

        mViewPager = (ViewPager) ((UDViewPager) v[0]).getView();

        if (mViewPager instanceof LuaViewPager && ((LuaViewPager) mViewPager).isRepeat()) {

            ((LuaViewPager) mViewPager).setRelatedTabLayout(true);
            ((LuaViewPager) mViewPager).setRepeat(false);

            if (mViewPager.getAdapter() != null)
                mViewPager.getAdapter().notifyDataSetChanged();
        }

        mViewPager.addOnPageChangeListener(new BaseTabLayout.TabLayoutOnPageChangeListener(getView(),this));
        getView().addOnTabSelectedListener(new BaseTabLayout.ViewPagerOnTabSelectedListener(mViewPager));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setCurrentIndexAnimated(LuaValue[] v) {
        if (v.length != 0) {
            final int index = v[0].toInt();
            if (!ViewCompat.isLaidOut(getView()))
                MainThreadExecutor.postDelayed(getTag(), new Runnable() {
                    @Override
                    public void run() {
                        getView().setSelectedTabPosition(index - 1);
                    }
                }, 10);
            else
                getView().setSelectedTabPosition(index - 1);
        }
        return null;
    }

    private Object getTag() {
        return "UDTabLayout" + hashCode();
    }

    @LuaApiUsed
    public LuaValue[] setTapBadgeNumAtIndex(LuaValue[] v) {
        if (!v[0].isNumber() || !v[1].isNumber()) {//参数不是number，直接返回
            return null;
        }
        int number = v[0].toInt();
        int index = v[1].toInt() - 1;
        if (index > getView().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getView().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (number == 0)
            info.setHint("");
        else
            info.setHint(String.valueOf(number));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setTapBadgeTitleAtIndex(LuaValue[] v) {
        String title = v.length > 0 && !v[0].isNil() ? v[0].toJavaString() : null;
        int index = v[1].toInt() - 1;
        if (index > getView().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getView().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (title != null && title.length() > 0)
            info.setHint(title);
        else
            info.setHint("");
        return null;
    }

    @LuaApiUsed
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

    @LuaApiUsed
    public LuaValue[] setTabSpacing(LuaValue[] v) {
        float tabSpacing = (float) v[0].toDouble();
        BaseTabLayout.SlidingTabStrip slidingTabStrip = getView().getTabStrip();

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
                getView().setStartEndPadding((padding));

                ViewCompat.setPaddingRelative(subview, paddingInt, paddingInt,
                        paddingInt, paddingInt);

            }

            subview.setLayoutParams(params);
        }

        slidingTabStrip.requestLayout();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setRedDotHiddenAtIndex(LuaValue[] v) {
        int index = v[0].toInt() - 1;
        if (index > getView().getTabCount() - 1) {
            return null;
        }
        BaseTabLayout.Tab tab = getView().getTabAt(index);
        TextDotTabInfoLua info = tab.getTabInfo();

        if (v.length > 1 && v[1].toBoolean())
            info.setHasDot(true);
        else
            info.setHasDot(false);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] changeRedDotStatusAtIndex(LuaValue[] v) {
        setRedDotHiddenAtIndex(v);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setTapTitleAtIndex(LuaValue[] v) {
        String title = v.length > 0 ? v[0].toJavaString() : null;
        int index = v.length > 1 ? v[1].toInt() - 1 : -1;
        if (!TextUtils.isEmpty(title) && index >= 0 && getView().getTabCount() > index) {
            BaseTabLayout.Tab tab = getView().getTabAt(index);
            if (tab != null)
                tab.setText(title);
        }
        return null;
    }

    //</editor-fold>

    public void setIndicatorColor(int color) {
        indicator.setColor(color);
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
        BaseTabLayout.Tab tab = getView().newTab();

        TextDotTabInfoLua textDotTabInfoLua = new TextDotTabInfoLua(tabInfo);
        tab.setTabInfo(textDotTabInfoLua);

        getView().addTab(tab);

        if (tab.getCustomView() != null) {
            tab.getCustomView().setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    if (itemClickCallBackFunction != null)
                        itemClickCallBackFunction.invoke(varargsOf(LuaNumber.valueOf(position + 1)));

                    setSelectedColor(position);

                    getView().setSelectedTabPosition(position);
                    if (mViewPager != null) {
                        mViewPager.setCurrentItem(position, false);
                    }
                }
            });
        }

    }

    private void setAlign() {
        View parentView = getView().getChildAt(0);

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
                addTabSelectedCallback.invoke(varargsOf(LuaNumber.valueOf(getView().getSelectedTabPosition() + 1)));
            }
            setSelectedColor(getView().getSelectedTabPosition());
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
        if (selectTextColor ==0)
            return;

        for (int i = 0; i < getView().getTabCount(); i++) {
            BaseTabLayout.Tab tab1 = getView().getTabAt(i);
            TextDotTabInfoLua info1 = tab1.getTabInfo();
            if (position == i) {
                info1.setTitleColor(selectTextColor);
            } else
                info1.setTitleColor(textColor);
        }

        setIndicatorColor(this.selectTextColor);
        getView().invalidate();
    }

    @Override
    public void tabScrollProgress(double progresss, int fromIndex,  int  toIndex) {
        if (mTabScrollingProgressFunction != null)
            mTabScrollingProgressFunction.invoke(varargsOf(LuaNumber.valueOf(progresss), LuaNumber.valueOf(fromIndex + 1), LuaNumber.valueOf(toIndex + 1)));
    }

    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
        MainThreadExecutor.cancelAllRunnable(getTag());

    }
}