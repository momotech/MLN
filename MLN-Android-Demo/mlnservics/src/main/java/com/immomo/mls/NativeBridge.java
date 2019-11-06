/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-08-28
 */
public class NativeBridge {

    private static boolean init = false;

    static {
        try {
            System.loadLibrary("mlnbridge");
            init = true;
        } catch (Throwable t) {
            init = false;
            t.printStackTrace();
        }
    }

    public static void registerNativeBridge(Globals g) {
        if (!init)
            return;
        _openLib(g.getL_State());
    }

    private static native void _openLib(long l);
}