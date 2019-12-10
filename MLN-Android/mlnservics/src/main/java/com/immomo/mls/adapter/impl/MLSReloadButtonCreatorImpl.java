/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.adapter.impl;

import android.view.ViewGroup;

import com.immomo.mls.MLSInstance;
import com.immomo.mls.adapter.MLSReloadButtonCreator;
import com.immomo.mls.adapter.MLSReloadButtonGenerator;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class MLSReloadButtonCreatorImpl implements MLSReloadButtonCreator {
    @Override
    public MLSReloadButtonGenerator newGenerator(ViewGroup container, MLSInstance instance) {
        return new MLSReloadButtonGenerator(container, instance);
    }
}
