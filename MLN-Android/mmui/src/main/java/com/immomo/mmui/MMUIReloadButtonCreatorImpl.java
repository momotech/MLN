/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.view.ViewGroup;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class MMUIReloadButtonCreatorImpl implements MMUIReloadButtonCreator {
    @Override
    public MMUIReloadButtonGenerator newGenerator(ViewGroup container, MMUIInstance instance) {
        return new MMUIReloadButtonGenerator(container, instance);
    }
}