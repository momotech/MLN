/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by Xiong.Fangyu on 2019/3/5
 *
 * 标记类、方法、构造方法、参数是Native需要直接使用的
 * 不能混淆
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.FIELD, ElementType.CONSTRUCTOR})
public @interface LuaApiUsed {
    String name() default "";
    Func[] value() default {};

    boolean ignore() default false;
    boolean ignoreTypeArgs() default false;
    @interface Func {
        String name() default "";
        Type[] params() default {};
        Type[] returns() default {};
        String comment() default "";
    }

    @interface Type {
        String name() default "";
        Class value() default Object.class;
        //目前仅支持一层泛型
        Class[] typeArgs() default {};
        boolean[] typeArgsNullable() default {};
        boolean nullable() default false;
    }
}