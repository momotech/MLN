/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import androidx.annotation.CallSuper;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public abstract class UDBaseRecyclerLayout<A extends UDBaseRecyclerAdapter> extends JavaUserdata {
    public static final String LUA_CLASS_NAME = "__BaseRecyclerLayout";

    protected int lineSpacing = 0;
    protected int itemSpacing = 0;

    protected int width;
    protected int height;

    protected int orientation = RecyclerView.VERTICAL;
    protected A adapter;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDBaseRecyclerLayout(long L) {
        super(L, null);
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    //<editor-fold desc="API">

    @LuaApiUsed
    public void setLineSpacing(float lineSpacing) {
        this.lineSpacing = DimenUtil.dpiToPx(lineSpacing);
    }

    @LuaApiUsed
    public void setItemSpacing(float itemSpacing) {
        this.itemSpacing = DimenUtil.dpiToPx(itemSpacing);
    }

    @LuaApiUsed
    public float getLineSpacing() {
        return DimenUtil.pxToDpi(lineSpacing);
    }

    @LuaApiUsed
    public float getItemSpacing() {
        return DimenUtil.pxToDpi(itemSpacing);
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