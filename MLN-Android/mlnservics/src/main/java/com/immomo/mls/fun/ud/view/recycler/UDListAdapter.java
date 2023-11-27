/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.view.ViewGroup;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.view.UDSwitch;
import com.immomo.mls.fun.ui.LuaLinearLayoutManager;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDListAdapter extends UDBaseNeedHeightAdapter {
    public static final String LUA_CLASS_NAME = "TableViewAdapter";
    public static final String[] methods = new String[]{

    };

    private LinearLayoutManager layoutManager;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDListAdapter.class))
    })
    public UDListAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    public RecyclerView.LayoutManager getLayoutManager() {
        if (layoutManager == null) {
            layoutManager = new LuaLinearLayoutManager(getContext());
        }
        return layoutManager;
    }

    @Override
    public int getCellViewWidth() {
        return viewWidth;
    }

    @Override
    public ViewGroup.LayoutParams newLayoutParams(ViewGroup.LayoutParams p, boolean fullSpan) {
        if (p == null) {
            p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
        return p;
    }

    @Override
    protected void onLayoutSet(UDBaseRecyclerLayout layout) {
        throw new UnsupportedOperationException("cannot set layout to list adapter");
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}