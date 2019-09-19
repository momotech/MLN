/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter.impl;

import android.content.Context;
import androidx.annotation.NonNull;

import com.immomo.mls.adapter.MLSLoadViewAdapter;
import com.immomo.mls.fun.ui.DefaultLoadViewDelegate;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mls.weight.load.ScrollableView;

/**
 * Created by XiongFangyu on 2018/7/23.
 */

public class DefaultLoadViewAdapter implements MLSLoadViewAdapter {
    @NonNull
    @Override
    public ILoadViewDelegete newLoadViewDelegate(Context context, ScrollableView scrollableView) {
        return new DefaultLoadViewDelegate(context, scrollableView);
    }
}