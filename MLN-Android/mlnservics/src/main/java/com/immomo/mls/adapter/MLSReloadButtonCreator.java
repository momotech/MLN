/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.adapter;

import android.view.ViewGroup;

import com.immomo.mls.MLSInstance;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public interface MLSReloadButtonCreator {

    MLSReloadButtonGenerator newGenerator(ViewGroup container, MLSInstance instance);
}
