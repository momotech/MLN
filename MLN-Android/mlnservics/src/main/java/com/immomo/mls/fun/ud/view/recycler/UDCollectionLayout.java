/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.GridLayoutItemDecoration;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDCollectionLayout extends UDBaseRecyclerLayout  implements ILayoutInSet {
    public static final String LUA_CLASS_NAME = "CollectionViewLayout";
    public static final String[] methods = new String[]{
            "itemSize",
            "spanCount",
            "layoutInset",
            "canScroll2Screen",
    };

    public static final int DEFAULT_ITEM_SIZE = 100;
    public static final int DEFAULT_SPAN_COUNT = 1;

    private UDSize itemSize;
    private int spanCount;
    private GridLayoutItemDecoration itemDecoration;
    private boolean mIsCanScrollTolScreenLeft = true;
    private final int[] paddingValues;
    private boolean spanCountInit = false;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDCollectionLayout.class))
    })
    public UDCollectionLayout(long L, LuaValue[] v) {
        super(L, v);
        paddingValues = new int[4];
    }

    //<editor-fold desc="api">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDSize.class)
            }, returns = @LuaApiUsed.Type(UDCollectionLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDSize.class))
    })
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

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDCollectionLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Integer.class))
    })
    public LuaValue[] spanCount(LuaValue[] values) {
        if (values != null && values.length > 0) {
            this.spanCount = values[0].toInt();
            return null;
        }
        if (this.spanCount <= 0)
            this.spanCount = DEFAULT_SPAN_COUNT;
        return LuaValue.rNumber(spanCount);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Double.class),
                    @LuaApiUsed.Type(Double.class),
                    @LuaApiUsed.Type(Double.class),
                    @LuaApiUsed.Type(Double.class)
            }, returns = @LuaApiUsed.Type(UDCollectionLayout.class))
    })
    public LuaValue[] layoutInset(LuaValue[] values) {
        paddingValues[0] = DimenUtil.dpiToPx(values[1].toDouble());//left
        paddingValues[1] = DimenUtil.dpiToPx(values[0].toDouble());//top
        paddingValues[2] = DimenUtil.dpiToPx(values[3].toDouble());//right
        paddingValues[3] = DimenUtil.dpiToPx(values[2].toDouble());//bottom
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDCollectionLayout.class))
    })
    public LuaValue[] canScroll2Screen(LuaValue[] values) {
        this.mIsCanScrollTolScreenLeft = values[0].toBoolean();
        return null;
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
        if (this.spanCount <= 0){
            this.spanCount = DEFAULT_SPAN_COUNT;
            IllegalArgumentException e = new IllegalArgumentException("spanCount must > 0");
            if (!Environment.hook(e, getGlobals())) {
                throw e;
            }
        }

        return this.spanCount;
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

    public boolean isCanScrollTolScreenLeft() {
        return mIsCanScrollTolScreenLeft;
    }

    private void setItemDecoration() {
        itemDecoration = new GridLayoutItemDecoration(orientation, this);
    }

    @Override
    protected void onFooterAdded(boolean footerAdded) {
        if (itemDecoration != null) {
            itemDecoration.setHasFooter(footerAdded);
        }
    }

    @Override
    public int[] getPaddingValues() {
        return paddingValues;
    }
}