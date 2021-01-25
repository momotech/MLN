/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ui;

import android.app.Activity;
import android.content.Context;

/**
 * Created by zhang.ke
 * 安全区域，对外接口。扩展安全区域判断、刘海屏判断
 * on 2020-01-19
 */
public interface MLNSafeAreaAdapter {

    boolean needSafeArea(Context context);

    boolean hasDisPlayCutout(Activity context);
}
