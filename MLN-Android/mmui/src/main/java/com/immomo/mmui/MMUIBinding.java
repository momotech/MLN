/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;


import com.immomo.mls.OnGlobalsCreateListener;
import com.immomo.mmui.databinding.DataBinding;

import org.luaj.vm2.Globals;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-23 03:13
 */
public class MMUIBinding {
    private MMUIInstance mlsInstance;

    public MMUIBinding(MMUIInstance mlsInstance) {
        this.mlsInstance = mlsInstance;
    }


    /**
     * 绑定数据（ViewModel）
     * @param key
     * @param target
     */
    public void bind(final String key, final Object target) {
        if(mlsInstance.getGlobals() ==null) {
            mlsInstance.addOnGlobalsCreateListener(new OnGlobalsCreateListener() {
                @Override
                public void onCreate(Globals g) {
                    DataBinding.bind(g, target, key);
                }
            });
        } else {
            DataBinding.bind(mlsInstance.getGlobals(), target, key);
        }
    }

}