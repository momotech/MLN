/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/7 下午6:22
 */

@IntDef({ListNotifyType.CHANGED, ListNotifyType.INSERTED,ListNotifyType.REMOVED})
@Retention(RetentionPolicy.SOURCE)
public @interface ListNotifyType {
    int CHANGED = 1;
    int INSERTED = 2;
    int REMOVED = 3;
}
