/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.provider;

import android.graphics.drawable.Drawable;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public interface DrawableLoadCallback {
    void onLoadResult(Drawable drawable, String errMsg);
}