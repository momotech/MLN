/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.DividerWaterFallItemDecoration;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * {@link UDWaterFallLayout}有两端差异，请用WaterfallNewLayout
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed
public class UDWaterFallLayout extends UDBaseRecyclerLayout {
    public static final String LUA_CLASS_NAME = "WaterfallLayout";
    public static final String[] methods = new String[]{
            "spanCount",
    };
    private int spanCount;
    private static final int DEFAULT_SPAN_COUNT = 1;
    private DividerWaterFallItemDecoration itemDecoration;

    @LuaApiUsed
    public UDWaterFallLayout(long L, LuaValue[] v) {
        super(L, v);
        spanCount = 2;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] spanCount(LuaValue[] values) {
        if (values != null && values.length > 0) {
            spanCount = values[0].toInt();
            return null;
        }
        return LuaValue.rNumber(getSpanCount());
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

        return spanCount;
    }
    //</editor-fold>

    @Override
    public RecyclerView.ItemDecoration getItemDecoration() {
        if (itemDecoration == null) {
            itemDecoration = new DividerWaterFallItemDecoration(itemSpacing, lineSpacing);
        } else if (itemDecoration.horizontalSpace != itemSpacing || itemDecoration.verticalSpace != lineSpacing) {
            itemDecoration = new DividerWaterFallItemDecoration(itemSpacing, lineSpacing);
        }
        return itemDecoration;
    }
}