/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view.recycler;

import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.other.WaterFallItemDecoration;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * {@link UDWaterFallLayout}有两端差异，请用WaterfallNewLayout
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDWaterFallLayout extends UDBaseRecyclerLayout implements ILayoutInSet {
    public static final String LUA_CLASS_NAME = "WaterfallLayout";
    public static final String[] methods = new String[]{
            "spanCount",
            "layoutInset",
    };
    private int spanCount;
    private static final int DEFAULT_SPAN_COUNT = 1;
    private WaterFallItemDecoration waterFallDecoration;
    private final int[] paddingValues;

    @LuaApiUsed({
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDWaterFallLayout.class)),
    })
    public UDWaterFallLayout(long L, LuaValue[] v) {
        super(L, v);
        spanCount = 2;
        paddingValues = new int[4];
    }

    //<editor-fold desc="API">

    @LuaApiUsed({
            @LuaApiUsed.Func(
                    params = {
                            @LuaApiUsed.Type(Double.class),
                            @LuaApiUsed.Type(Double.class),
                            @LuaApiUsed.Type(Double.class),
                            @LuaApiUsed.Type(Double.class)},
                    returns = @LuaApiUsed.Type(UDWaterFallLayout.class)),
    })
    public LuaValue[] layoutInset(LuaValue[] values) {
        paddingValues[0] = DimenUtil.dpiToPx(values[1].toDouble());//left
        paddingValues[1] = DimenUtil.dpiToPx(values[0].toDouble());//top
        paddingValues[2] = DimenUtil.dpiToPx(values[3].toDouble());//right
        paddingValues[3] = DimenUtil.dpiToPx(values[2].toDouble());//bottom
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(
                    params = {@LuaApiUsed.Type(Integer.class)},
                    returns = @LuaApiUsed.Type(UDWaterFallLayout.class)),
    })
    public LuaValue[] spanCount(LuaValue[] values) {
        if (values != null && values.length > 0) {
            spanCount = values[0].toInt();
            return null;
        }
        return LuaValue.rNumber(getSpanCount());
    }

    @Override
    public int getSpanCount() {
        if (this.spanCount <= 0) {
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
        if (waterFallDecoration == null) {
            waterFallDecoration = new WaterFallItemDecoration(this);
        } else if (waterFallDecoration.horizontalSpace != itemSpacing || waterFallDecoration.verticalSpace != lineSpacing) {
            waterFallDecoration = new WaterFallItemDecoration(this);
        }
        return waterFallDecoration;
    }

    @Override
    protected void onFooterAdded(boolean footerAdded) {
        if (waterFallDecoration != null) {
            waterFallDecoration.setHasFooter(footerAdded);
        }
    }

    @Override
    public int[] getPaddingValues() {
        return paddingValues;
    }
}