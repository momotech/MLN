/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.Environment;
import com.immomo.mls.fun.ud.view.recycler.ILayoutInSet;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * {@link UDWaterFallLayout}有两端差异，请用WaterfallNewLayout
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed
public class UDWaterFallLayout extends UDBaseRecyclerLayout implements ILayoutInSet {
    public static final String LUA_CLASS_NAME = "WaterfallLayout";
    private int spanCount;
    private static final int DEFAULT_SPAN_COUNT = 1;
    private WaterFallItemDecoration waterFallDecoration;
    private final int[] paddingValues;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDWaterFallLayout(long L) {
        super(L);
        spanCount = 2;
        paddingValues = new int[4];
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    //<editor-fold desc="API">
    @LuaApiUsed
    public void layoutInset(float t, float l, float b, float r) {
        paddingValues[0] = DimenUtil.dpiToPx(l);//left
        paddingValues[1] = DimenUtil.dpiToPx(t);//top
        paddingValues[2] = DimenUtil.dpiToPx(r);//right
        paddingValues[3] = DimenUtil.dpiToPx(b);//bottom
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