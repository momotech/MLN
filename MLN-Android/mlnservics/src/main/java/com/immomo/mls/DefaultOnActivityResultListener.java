/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-08-21
 */
public class DefaultOnActivityResultListener implements OnActivityResultListener {
    /**
     * function(bool, table)
     */
    private final LuaFunction callback;

    public DefaultOnActivityResultListener(LuaFunction callback) {
        AssertUtils.assertNullForce(callback);
        this.callback = callback;
    }

    @Override
    public boolean onActivityResult(int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_CANCELED) {
            callback(false, null);
            return true;
        }
        Bundle extra = data.getExtras();
        if (extra == null) {
            callback(true, null);
            return true;
        }
        LuaTable table = LuaTable.create(callback.getGlobals());
        for (String key :extra.keySet()) {
            table.set(key, ConvertUtils.toLuaValue(callback.getGlobals(), extra.get(key)));
        }
        callback(true, table);
        table.destroy();
        return true;
    }

    private void callback(boolean result, LuaTable table) {
        try {
            if (table == null) {
                callback.fastInvoke(result);
            } else {
                callback.invoke(LuaValue.varargsOf(result ? LuaValue.True() : LuaValue.False(), table));
                table.destroy();
            }
        } catch (Throwable t) {
            Environment.hook(t, callback.getGlobals());
        }
    }
}