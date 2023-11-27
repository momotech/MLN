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
 * 注解在需要提供给lua调用的方法上
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.FIELD, ElementType.CONSTRUCTOR})
public @interface LuaBridge {
    /**
     * 别名，有别名用别名
     */
    String alias() default "";

    /**
     * 类型为普通类型，还是getter/setter类型
     * @see BridgeType#SETTER
     * @see BridgeType#GETTER
     *
     */
    BridgeType type() default BridgeType.NORMAL;

    /**
     * 当type设置为{@link BridgeType#GETTER}时,通过名称寻找setter
     * 若不设置，将通过alias前加'set'寻找
     */
    String setterIs() default "";

    /**
     * 当type设置为{@link BridgeType#SETTER}时,通过名称寻找getter
     * 若不设置，将通过alias前加'get'寻找
     */
    String getterIs() default "";


//    若不设置则取默认参数
    Func[] value() default {};
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