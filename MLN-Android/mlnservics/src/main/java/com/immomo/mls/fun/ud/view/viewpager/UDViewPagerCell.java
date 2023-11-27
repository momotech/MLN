/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.viewpager;

import com.immomo.mls.fun.ud.view.UDViewGroup;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by fanqiang on 2018/8/30.
 */
@LuaApiUsed(ignore = true)
public class UDViewPagerCell<T extends ViewPagerContent> extends UDViewGroup<T> {
    protected static final String WINDOW = "contentView";
    private LuaTable cell;

    public UDViewPagerCell(Globals globals) {
        super(globals);
        cell = LuaTable.create(globals);
        cell.set(WINDOW, this);
        view.setCell(cell);
    }

    @Override
    protected T newView(LuaValue[] init) {
        return (T) new ViewPagerContent(getContext(), this, null);
    }

    public LuaTable getCell() {
        return cell;
    }

    @Override
    protected String initLuaClassName(Globals g) {
        return g.getLuaClassName(UDViewGroup.class);
    }
}