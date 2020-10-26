/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.recycler;

import com.immomo.mls.fun.other.Size;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/7/20.
 * 瀑布流自适应adapter
 */
@LuaApiUsed
public class UDWaterFallAutoFitAdapter extends UDWaterFallAdapter {
    public static final String LUA_CLASS_NAME = "WaterfallAutoFitAdapter";

    public UDWaterFallAutoFitAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    /**
     * called when {@link #hasCellSize} return true
     *
     * @param position
     * @return
     */
    @NonNull
    @Override
    public Size getCellSize(int position) {
        return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }


    @NonNull
    @Override
    public Size getHeaderSize(int position) {
        return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}
