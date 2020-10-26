/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.viewpager;

import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.ud.view.UDViewPager;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by fanqiang on 2018/8/30.
 */
@LuaApiUsed
public class UDViewPagerAdapter extends JavaUserdata {
    public static final String LUA_CLASS_NAME = "ViewPagerAdapter";
    public static final String[] methods = new String[]{
            "getCount",
            "initCell",
            "fillCellData",
            "reuseId",
            "initCellByReuseId",
            "fillCellDataByReuseId",
            "callInitAndFillWhenReloadData",
    };
    public static final String NONE_REUSE_ID = "NONE_REUSE_ID";

    private LuaFunction funGetCount;
    private LuaFunction funInitCell;
    private LuaFunction funFillCellData;
    private LuaFunction funReuseid;
    private Map<String, LuaFunction> initCellFunctions;
    private Map<String, LuaFunction> fillCellDataFunctions;

    private SparseArray<String> reuseIdCache;

    private ViewPagerAdapter adapter;
    private View.OnClickListener onClickListener;

    private int allCountCache;

    @LuaApiUsed
    public UDViewPagerAdapter(long L, LuaValue[] v) {
        super(L, v);
        allCountCache = -1;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] getCount(LuaValue[] values) {
        this.funGetCount = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] initCell(LuaValue[] values) {
        this.funInitCell = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] fillCellData(LuaValue[] values) {
        this.funFillCellData = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] reuseId(LuaValue[] values) {
        funReuseid = values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] initCellByReuseId(LuaValue[] values) {
        if (initCellFunctions == null) {
            initCellFunctions = new HashMap<>();
        }
        initCellFunctions.put(values[0].toJavaString(), values[1].toLuaFunction());

        getAdapter().notifyDataSetChanged();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] fillCellDataByReuseId(LuaValue[] values) {
        if (fillCellDataFunctions == null) {
            fillCellDataFunctions = new HashMap<>();
        }
        fillCellDataFunctions.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
    }

    /**
     * iOS暂无，测试用
     * <p>
     * call
     */
    @LuaApiUsed
    public LuaValue[] callInitAndFillWhenReloadData(LuaValue[] values) {
        getAdapter().setViewPagerConfig(values[0].toBoolean() ? 1 : 0);
        return null;
    }
    //</editor-fold>


    //<editor-fold desc="Call by UDViewPager">
    public ViewPagerAdapter getAdapter() {
        if (adapter == null) {
            adapter = new ViewPagerAdapter(this);
        }
        return adapter;
    }

    public void reloadData() {
        allCountCache = -1;
        if (reuseIdCache != null) {
            reuseIdCache.clear();
        }
        getAdapter().notifyDataSetChanged();
    }
    //</editor-fold>

    //<editor-fold desc="Call by Adapter">
    public String callGetReuseId(int p) {
        if (funReuseid == null || funReuseid.isNil()) {
            return NONE_REUSE_ID;
        }
        if (reuseIdCache == null) {
            reuseIdCache = new SparseArray<>();
        }
        String ret = reuseIdCache.get(p);
        if (ret != null)
            return ret;
        LuaValue[] rets = funReuseid.invoke(varargsOf(luaInt(p)));
        LuaValue v = rets == null || rets.length == 0 ? Nil() : rets[0];
        if (AssertUtils.assertString(v, funReuseid, getGlobals())) {
            ret = v.toJavaString();
        } else {
            ret = v.toString();
        }
        reuseIdCache.put(p, ret);
        return ret;
    }

    public int callGetCount() {
        if (allCountCache != -1) {
            return allCountCache;
        }
        if (funGetCount == null || funGetCount.isNil()) {
            return 0;
        }
        LuaValue[] rets = funGetCount.invoke(null);
        LuaValue v = rets == null || rets.length == 0 ? Nil() : rets[0];
        if (AssertUtils.assertNumber(v, funGetCount, getGlobals())) {
            allCountCache = v.toInt();
        } else {
            allCountCache = 0;
        }
        return allCountCache;
    }

    public void callInitView(LuaValue luaValue, String reuseId, int position) {
        LuaFunction delegate = null;
        if (reuseId != null && reuseId != NONE_REUSE_ID && initCellFunctions != null) {
            delegate = initCellFunctions.get(reuseId);
        }
        if (delegate == null) {
            delegate = funInitCell;
        }
        if (globals.isDestroyed()) {
            return;
        }
        if (!AssertUtils.assertFunction(delegate, "必须通过initCell把函数设置到adapter中", getGlobals()))
            return;

        resetLayoutParamsWhenWidth2Zero(luaValue);

        delegate.invoke(varargsOf(luaValue, luaInt(position)));
    }

    private void resetLayoutParamsWhenWidth2Zero(LuaValue luaValue) {
        if (luaValue instanceof LuaTable) {
            UDViewPagerCell udViewPagerCell = ((UDViewPagerCell) luaValue.get(UDViewPagerCell.WINDOW));
            ViewGroup.LayoutParams params = udViewPagerCell.getView().getLayoutParams();

            if (params == null)
                return;

            if (udViewPagerCell.getView().getWidth() == 0 && mUDViewPager != null)
                params.width = mUDViewPager.getWidth();

            if (udViewPagerCell.getView().getHeight() == 0 && mUDViewPager != null)
                params.height = mUDViewPager.getHeight();

            udViewPagerCell.getView().setLayoutParams(params);
        }
    }

    public void callFillCellData(LuaValue luaValue, String reuseId, int position) {
        LuaFunction delegate = null;
        if (reuseId != null && reuseId != NONE_REUSE_ID && fillCellDataFunctions != null) {
            delegate = fillCellDataFunctions.get(reuseId);
        }
        if (delegate == null) {
            delegate = funFillCellData;
        }
        if (delegate == null || delegate.isNil()) {
            return;
        }

        delegate.invoke(varargsOf(luaValue, luaInt(position)));
    }


    //</editor-fold>

    public View.OnClickListener getOnClickListener() {
        return onClickListener;
    }

    public void setOnClickListener(View.OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    private LuaValue luaInt(int p) {
        return LuaNumber.valueOf(p + 1);
    }

    UDViewPager mUDViewPager;

    public void setUDViewPager(UDViewPager udViewPager) {
        mUDViewPager = udViewPager;
    }
}