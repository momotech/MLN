/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.viewpager;

import android.content.Context;

import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.ui.LuaViewGroup;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;


/**
 * Created by XiongFangyu on 2018/9/27.
 */
public class ViewPagerContent extends LuaViewGroup {
    public ViewPagerContent(Context context, UDViewGroup userdata, LuaValue[] init) {
        super(context, userdata);
    }

    private LuaTable cell;

    public LuaTable getCell() {
        return cell;
    }

    public void setCell(LuaTable cell) {
        this.cell = cell;
    }

    public boolean isInit() {
        return getChildCount() > 0;
    }
}