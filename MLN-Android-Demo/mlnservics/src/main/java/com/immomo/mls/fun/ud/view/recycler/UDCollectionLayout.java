package com.immomo.mls.fun.ud.view.recycler;


import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.NormalItemDecoration;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public class UDCollectionLayout extends UDBaseRecyclerLayout {
    public static final String LUA_CLASS_NAME = "CollectionViewLayout";
    public static final String[] methods = new String[]{
            "itemSize",
    };

    public static final int DEFAULT_SPAN_COUNT = 1;

    private UDSize itemSize;
    private int spanCount;
    private NormalItemDecoration itemDecoration;
    private boolean spanCountInit = false;

    @LuaApiUsed
    public UDCollectionLayout(long L, LuaValue[] v) {
        super(L, v);
    }

    //<editor-fold desc="api">
    @LuaApiUsed
    public LuaValue[] itemSize(LuaValue[] values) {
        LuaValue value = values[0];
        if (value != null) {
            if (itemSize != null) {
                itemSize.onJavaRecycle();
            }
            itemSize = (UDSize) value.toUserdata();
            itemSize.onJavaRef();
            spanCountInit = false;
            return null;
        }
        return varargsOf(getitemSize());
    }
    //</editor-fold>

    public LuaValue getitemSize() {
        return itemSize;
    }

    public Size getSize() {
        return itemSize != null ? itemSize.getSize() : null;
    }

    @Override
    public int getSpanCount() {
        initSpanCount();
        return spanCount;
    }

    @Override
    public @Nullable
    RecyclerView.ItemDecoration getItemDecoration() {
        if (itemDecoration == null) {
            itemDecoration = new NormalItemDecoration(itemSpacing, lineSpacing, orientation, spanCount);
        } else if (!itemDecoration.isSame(itemSpacing, lineSpacing)) {
            itemDecoration = new NormalItemDecoration(itemSpacing, lineSpacing, orientation, spanCount);
        }
        return itemDecoration;
    }

    @Override
    protected void onOrientationChanged(int now) {
        if (spanCountInit) {
            spanCountInit = false;
            initSpanCount();
        }
    }

    @Override
    public void setRecyclerViewSize(int width, int height) {
        super.setRecyclerViewSize(width, height);
        if (spanCountInit) {
            spanCountInit = false;
            initSpanCount();
        }
    }

    private void initSpanCount() {
        if (spanCountInit)
            return;
        if (orientation == RecyclerView.VERTICAL) {
            spanCount = getSpanCountForWidth();
        } else {
            spanCount = getSpanCountForHeight();
        }
        if (this.spanCount <= 0){
            this.spanCount = DEFAULT_SPAN_COUNT;
            IllegalArgumentException e = new IllegalArgumentException("spanCount must > 0");
            if (!Environment.hook(e, getGlobals())) {
                throw e;
            }
        }
        spanCountInit = true;
    }

    private int getSpanCountForWidth() {
        int w = (int) itemSize.getWidthPx();
        int screenW = width == 0 ? getScreenWidth() : width;
        int spanCount = (screenW - itemSpacing) / w;
        return recalculateSpanCount(spanCount, w, screenW, itemSpacing);
    }

    private int getSpanCountForHeight() {
        int h = (int) itemSize.getHeightPx();
        int screenH = height == 0 ? getScreenHeight() : height;
        int spanCount = (screenH - lineSpacing) / h;
        return recalculateSpanCount(spanCount, h, screenH, lineSpacing);
    }

    private int recalculateSpanCount(int c, int item, int max, int spacingSize) {
        if (spacingSize == 0) {
            return c;
        } else {
            while (c * (item + spacingSize) > (max - spacingSize)) {
                c--;
            }
        }
        return c;
    }
}
