package com.immomo.mls.fun.ud.view.recycler;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.GridLayoutItemDecoration;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 原gridLayout，已废弃
 */
@Deprecated
@LuaApiUsed
public class UDCollectionGridLayout extends UDCollectionLayout {
    public static final String LUA_CLASS_NAME = "CollectionViewGridLayout";
    public static final String[] methods = new String[]{
            "spanCount",
            "layoutInset",
            "canScroll2Screen",
    };

    public static final int DEFAULT_SPAN_COUNT = 1;
    public static final int DEFAULT_ITEM_SIZE = 100;

    private int spanCount;
    private GridLayoutItemDecoration itemDecoration;

    private boolean mIsCanScrollTolScreenLeft = true;

    private final int[] paddingValues;

    @LuaApiUsed
    public UDCollectionGridLayout(long L, LuaValue[] v) {
        super(L, v);
        paddingValues = new int[4];
    }

    public boolean isCanScrollTolScreenLeft() {
        return mIsCanScrollTolScreenLeft;
    }

    @LuaApiUsed
    public LuaValue[] spanCount(LuaValue[] values) {
        if (values != null && values.length > 0) {
            this.spanCount = values[0].toInt();
            return null;
        }
        if (this.spanCount <= 0)
            this.spanCount = DEFAULT_SPAN_COUNT;
        return LuaValue.rNumber(spanCount);
    }

    @Override
    public int getSpanCount() {
        if (this.spanCount <= 0){
            this.spanCount = DEFAULT_SPAN_COUNT;
            IllegalArgumentException e = new IllegalArgumentException("spanCount must > 0");
            if (!Environment.hook(e, getGlobals())) {
                throw e;
            }
        }

        return this.spanCount;
    }

    @LuaApiUsed
    public LuaValue[] layoutInset(LuaValue[] values) {
        paddingValues[0] = DimenUtil.dpiToPx(values[1].toDouble());
        paddingValues[1] = DimenUtil.dpiToPx(values[0].toDouble());
        paddingValues[2] = DimenUtil.dpiToPx(values[3].toDouble());
        paddingValues[3] = DimenUtil.dpiToPx(values[2].toDouble());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] canScroll2Screen(LuaValue[] values) {
        this.mIsCanScrollTolScreenLeft = values[0].toBoolean();
        return null;
    }

    @Override
    public @Nullable
    RecyclerView.ItemDecoration getItemDecoration() {
        if (itemDecoration == null) {
            setItemDecoration();
        } else if (!itemDecoration.isSame(itemSpacing, lineSpacing)) {
            setItemDecoration();
        }

        return itemDecoration;
    }

    private void setItemDecoration() {
         itemDecoration = new GridLayoutItemDecoration(itemSpacing, lineSpacing, orientation, spanCount, this);
    }

    public int[] getPaddingValues() {
        return paddingValues;
    }
}
