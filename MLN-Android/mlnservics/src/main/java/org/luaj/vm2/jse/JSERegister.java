/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.jse;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-10-15
 *
 * 注册jse相关对象
 */
public class JSERegister {

    public static void registerLuaJava(Globals g) {
        g.registerJavaMetatable(Luajava.class, Luajava.NAME);
        _registerJSE(g.getL_State());
    }

    private static native void _registerJSE(long l);
}