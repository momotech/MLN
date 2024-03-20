/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import com.immomo.mmui.ud.UDVStack;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

/**
 * Created by XiongFangyu on 2018/7/23.
 */
public class UDCell extends UDVStack {
    private static final String WINDOW = "contentView";
    private UDBaseRecyclerAdapter adapter;
    private LuaTable cell;

    public UDCell(Globals globals, UDBaseRecyclerAdapter adapter) {
        super(globals);
        this.adapter = adapter;
        cell = LuaTable.create(globals);
        cell.set(WINDOW, this);
    }

    public LuaTable getCell() {
        return cell;
    }

    @Override
    protected String initLuaClassName(Globals g) {
        return g.getLuaClassName(UDVStack.class);
    }

    @Override
    public boolean needConvertVirtual() {
        return false;
    }
}