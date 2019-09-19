/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by Xiong.Fangyu
 */
@LuaApiUsed
public class UDListAutoFitAdapter extends UDListAdapter {
    public static final String LUA_CLASS_NAME = "TableViewAutoFitAdapter";

    @LuaApiUsed
    public UDListAutoFitAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}