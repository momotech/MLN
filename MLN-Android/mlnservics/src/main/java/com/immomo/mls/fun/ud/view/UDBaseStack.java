/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.view.ViewGroup;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDBaseStack<V extends ViewGroup & ILViewGroup> extends UDViewGroup<V> {
    public static final String LUA_CLASS_NAME = "_BaseStack";
    public static final String[] methods = {
        "children"
    };

    @LuaApiUsed
    protected UDBaseStack(long L, LuaValue[] v) {
        super(L, v);
    }

    public UDBaseStack(Globals g, V jud) {
        super(g, jud);
    }

    @Override
    protected boolean clipToPadding() {
        return MLSConfigs.defaultClipContainer;
    }

    @Override
    protected boolean clipChildren() {
        return MLSConfigs.defaultClipContainer;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] children(LuaValue[] var) {
        if (var.length > 0) {
            LuaTable children = var[0].toLuaTable();

            DisposableIterator<LuaTable.KV> iterator = children.iterator();
            if (iterator == null)
                return null;
            while (iterator.hasNext()) {
                LuaValue value = iterator.next().value;
                if (value.isNil()) {
                    ErrorUtils.debugLuaError("children table has nil value!", globals);
                    continue;
                }
                if (AssertUtils.assertUserData(value, UDView.class, "addView", getGlobals()))
                    insertView((UDView) value, -1);
            }
            iterator.dispose();
            children.destroy();
        }

        return null;
    }


    //</editor-fold>
}
