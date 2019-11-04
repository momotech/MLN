package com.immomo.mls.fun.ud.view.recycler;

import com.immomo.mls.fun.other.WaterFallItemDecoration;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.recyclerview.widget.RecyclerView;


/**
 * {@link UDWaterFallLayout}有两端差异，避免影响现有业务，新建UDWaterFallNewLayout解决差异
 * Created by zhang.ke on 2019/9/14
 */
@LuaApiUsed
public class UDWaterfallLayoutFix extends UDWaterFallLayout implements ILayoutInSet {
    public static final String LUA_CLASS_NAME = "WaterfallLayoutFix";
    public static final String[] methods = new String[]{
            "layoutInset",
    };
    private WaterFallItemDecoration waterFallDecoration;
    private final int[] paddingValues;

    @LuaApiUsed
    public UDWaterfallLayoutFix(long L, LuaValue[] v) {
        super(L, v);
        paddingValues = new int[4];
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] layoutInset(LuaValue[] values) {
        paddingValues[0] = DimenUtil.dpiToPx(values[1].toDouble());//left
        paddingValues[1] = DimenUtil.dpiToPx(values[0].toDouble());//top
        paddingValues[2] = DimenUtil.dpiToPx(values[3].toDouble());//right
        paddingValues[3] = DimenUtil.dpiToPx(values[2].toDouble());//bottom
        return null;
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
