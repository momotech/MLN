/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.annotation;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import static com.immomo.mmui.databinding.annotation.WatchContext.ArgoWatch_all;
import static com.immomo.mmui.databinding.annotation.WatchContext.ArgoWatch_native;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/3 下午8:40
 */

@ConstantClass(alias = "WatchContext")
@IntDef({WatchContext.ArgoWatch_lua, ArgoWatch_native,ArgoWatch_all})
@Retention(RetentionPolicy.SOURCE)
public @interface WatchContext {
    @Constant(alias = "LUA")
    int ArgoWatch_lua = 1;

    @Constant(alias = "NATIVE")
    int ArgoWatch_native = 2;

    @Constant(alias = "ALL")
    int ArgoWatch_all = 3;
}
