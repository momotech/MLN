/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;

import kotlin.jvm.functions.Function2;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.CallSuper;
import androidx.recyclerview.widget.RecyclerView;


/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public abstract class UDBaseRecyclerLayout<A extends UDBaseRecyclerAdapter> extends JavaUserdata {
    public static final String LUA_CLASS_NAME = "__BaseRecyclerLayout";
    public static final String[] methods = new String[]{
            "lineSpacing",
            "itemSpacing",

    };
    protected int lineSpacing = 0;
    protected int itemSpacing = 0;

    protected int width;
    protected int height;

    protected int orientation = RecyclerView.VERTICAL;
    protected A adapter;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDBaseRecyclerLayout.class))
    })
    protected UDBaseRecyclerLayout(long L, LuaValue[] v) {
        super(L, v);
    }

    //<editor-fold desc="API">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Number.class),
            }, returns = @LuaApiUsed.Type(UDBaseRecyclerLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Number.class)),
    })
    public LuaValue[] lineSpacing(LuaValue[] values) {
        if (values.length > 0) {
            this.lineSpacing = DimenUtil.dpiToPx(values[0]);
            return null;
        }
        return varargsOf(getLineSpacing());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Number.class),
            }, returns = @LuaApiUsed.Type(UDBaseRecyclerLayout.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Number.class)),
    })
    public LuaValue[] itemSpacing(LuaValue[] values) {
        if (values.length > 0) {
            this.itemSpacing = DimenUtil.dpiToPx(values[0]);
            return null;
        }

        return varargsOf(getItemSpacing());
    }

    public LuaValue getLineSpacing() {
        return LuaNumber.valueOf(DimenUtil.pxToDpi(lineSpacing));
    }

    public LuaValue getItemSpacing() {
        return LuaNumber.valueOf(DimenUtil.pxToDpi(itemSpacing));
    }
    //</editor-fold>

    public final void setOrientation(int o) {
        if (orientation != o) {
            orientation = o;
            onOrientationChanged(o);
        }
    }

    public int getOrientation() {
        return orientation;
    }

    protected void onOrientationChanged(int now) {

    }

    public int getItemSpacingPx() {
        return itemSpacing;
    }

    public int getlineSpacingPx() {
        return lineSpacing;
    }


    public abstract int getSpanCount();

    public abstract RecyclerView.ItemDecoration getItemDecoration();

    @CallSuper
    public void setRecyclerViewSize(int width, int height) {
        this.width = width;
        this.height = height;
    }

    protected static int getScreenWidth() {
        return AndroidUtil.getScreenWidth(MLSEngine.getContext());
    }

    protected static int getScreenHeight() {
        return AndroidUtil.getScreenHeight(MLSEngine.getContext());
    }

    protected void onFooterAdded(boolean footerAdded) {//footer加载栏存在，layoutInSet、lineSpacing特殊处理
    }

    public void setAdapter(A adapter) {
        this.adapter = adapter;
    }
}