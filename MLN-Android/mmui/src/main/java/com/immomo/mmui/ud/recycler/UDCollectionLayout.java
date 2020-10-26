/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;


import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ud.view.recycler.ILayoutInSet;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public class UDCollectionLayout extends UDBaseRecyclerLayout implements ILayoutInSet {
    public static final String LUA_CLASS_NAME = "CollectionLayout";

    public static final int DEFAULT_ITEM_SIZE = 100;
    public static final int DEFAULT_SPAN_COUNT = 1;

    private GridLayoutItemDecoration itemDecoration;

    private boolean mIsCanScrollTolScreenLeft = true;

    private final int[] paddingValues;

    private UDSize itemSize;
    private int spanCount;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDCollectionLayout(long L) {
        super(L);
        paddingValues = new int[4];
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    public boolean isCanScrollTolScreenLeft() {
        return mIsCanScrollTolScreenLeft;
    }

    //<editor-fold desc="api">

    @LuaApiUsed
    public UDSize getItemSize() {
        return itemSize;
    }

    @LuaApiUsed
    public void setItemSize(UDSize itemSize) {
        if (this.itemSize != null) {
            this.itemSize.onJavaRecycle();
        }
        this.itemSize = itemSize;
        itemSize.onJavaRef();
    }

    @LuaApiUsed
    public void setSpanCount(int spanCount) {
        this.spanCount = spanCount;
    }

    @LuaApiUsed
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
    public void layoutInset(float t, float l, float b, float r) {
        paddingValues[0] = DimenUtil.dpiToPx(l);//left
        paddingValues[1] = DimenUtil.dpiToPx(t);//top
        paddingValues[2] = DimenUtil.dpiToPx(r);//right
        paddingValues[3] = DimenUtil.dpiToPx(b);//bottom
    }

    @LuaApiUsed
    public void canScroll2Screen(boolean c) {
        this.mIsCanScrollTolScreenLeft = c;
    }
    //</editor-fold>

    public Size getSize() {
        return itemSize != null ? itemSize.getSize() : null;
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