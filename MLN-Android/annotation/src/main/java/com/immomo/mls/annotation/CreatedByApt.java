/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by XiongFangyu on 2019/3/15.
 *
 * 标识此类是由apt生成
 */
@Retention(RetentionPolicy.CLASS)
@Target(ElementType.TYPE)
public @interface CreatedByApt {
}