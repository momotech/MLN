/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;


import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;

/**
 * Created by Xiong.Fangyu on 2019/3/19
 */
public interface IUserdataConstructor<L extends LuaUserdata, O> {

    L newInstance(Globals g, O obj);
}