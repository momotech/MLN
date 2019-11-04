package com.immomo.mls.fun.ui;

import android.content.Context;
import android.util.AttributeSet;

import androidx.recyclerview.widget.GridLayoutManager;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/2/12
 * Time         :   下午5:34
 * Description  :
 */
public class LuaGridLayoutManager extends GridLayoutManager implements IScrollEnabled {
    private boolean isScrollEnabled = true;

    public LuaGridLayoutManager(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public LuaGridLayoutManager(Context context, int spanCount) {
        super(context, spanCount);
    }

    public LuaGridLayoutManager(Context context, int spanCount, int orientation, boolean reverseLayout) {
        super(context, spanCount, orientation, reverseLayout);
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
