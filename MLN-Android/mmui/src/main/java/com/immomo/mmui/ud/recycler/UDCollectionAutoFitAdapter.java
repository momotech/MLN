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


/**
 * Created by Xiong.Fangyu
 */
@LuaApiUsed
public class UDCollectionAutoFitAdapter extends UDCollectionAdapter {
    public static final String LUA_CLASS_NAME = "CollectionViewAutoFitAdapter";

    @LuaApiUsed
    public UDCollectionAutoFitAdapter(long L, LuaValue[] v) {
        super(L);
    }

    @Override
    protected Size initSize() {
       return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
    }

    /**
     * autoFitAdapter 两端统一，cellSize用Wrap_Content
     */
    @Override
    protected void onOrientationChanged() {
        super.onOrientationChanged();
        initSize.setHeight(Size.WRAP_CONTENT);
        initSize.setWidth(Size.WRAP_CONTENT);
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}