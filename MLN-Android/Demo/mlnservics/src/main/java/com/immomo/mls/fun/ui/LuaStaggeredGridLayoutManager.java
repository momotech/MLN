package com.immomo.mls.fun.ui;

import android.content.Context;
import android.util.AttributeSet;

import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/2/12
 * Time         :   下午5:34
 * Description  :
 */
public class LuaStaggeredGridLayoutManager extends StaggeredGridLayoutManager implements  IScrollEnabled{
    private boolean isScrollEnabled = true;

    public LuaStaggeredGridLayoutManager(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public LuaStaggeredGridLayoutManager(int spanCount, int orientation) {
        super(spanCount, orientation);
    }


    public void setScrollEnabled(boolean scrollEnabled) {
        isScrollEnabled = scrollEnabled;
    }

    @Override
    public boolean canScrollVertically() {
        return isScrollEnabled && super.canScrollVertically();
    }

    @Override
    public boolean canScrollHorizontally() {
        return isScrollEnabled && super.canScrollHorizontally();
    }
}
