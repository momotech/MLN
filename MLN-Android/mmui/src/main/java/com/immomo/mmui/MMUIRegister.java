/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.wrapper.Register;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.utils.SizeOfUtils;

/**
 * Created by Xiong.Fangyu on 2020-05-27
 */
public class MMUIRegister extends Register {

    public void registerUserdata(UDHolder holder) {
        if (MLSEngine.DEBUG && holder.needCheck)
            checkClassMethods(holder.clz, holder.methods, true);
        if (UDView.class.isAssignableFrom(holder.clz)) {
            lvUserdataHolder.add(holder);
        } else {
            SizeOfUtils.sizeof(holder.clz);
            allUserdataHolder.add(holder);
        }
    }

}