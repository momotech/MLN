/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.weight.newui;

import android.content.Context;
import android.util.AttributeSet;

/**
 * Created by zhang.ke
 * on 2020-03-11
 */
public class HStack extends BaseRowColumn {
    public HStack(Context context) {
        super(context);
        init();
    }

    public HStack(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public HStack(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        setOrientation(HORIZONTAL);
    }
}
