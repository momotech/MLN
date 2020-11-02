/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import android.content.Context;

import com.immomo.mls.LuaViewManager;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2020-05-27
 */
public class MMUILuaViewManager extends LuaViewManager {
    public MMUIInstance instance;

    public MMUILuaViewManager(Context c) {
        super(c);
    }

    @Override
    public void onGlobalsDestroy(Globals g) {
        if (g.isIsolate()) return;
        context = null;
        instance = null;
        STDOUT = null;
        luaCache.clear();
        if (onActivityResultListeners != null)
            onActivityResultListeners.clear();
    }

    @Override
    public void showPrinterIfNot() {
        if (instance != null && !instance.isShowPrinter() && !instance.hasClosePrinter()) {
            instance.showPrinter(true);
        }
    }
}