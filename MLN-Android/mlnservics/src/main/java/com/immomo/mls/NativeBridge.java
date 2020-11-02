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

    public static void registerNativeBridge(Globals g) {
        _openLib(g.getL_State(), MLSEngine.DEBUG);
        NativeBroadcastChannel.register(g);
    }

    static int callGencoveragereport(Globals g) {
        return _callGencoveragereport(g.getL_State());
    }

    private static native void _openLib(long l, boolean debug);

    private static native int _callGencoveragereport(long L);
}