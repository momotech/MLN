/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
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
 * Created by Xiong.Fangyu on 2020/9/8
 */
@Retention(RetentionPolicy.SOURCE)
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.FIELD, ElementType.CONSTRUCTOR})
public @interface CGenerate {
    /**
     * 标记方法中每个参数类型
     * 0: 无特殊，默认
     * F: lua function，参数类型应该为long
     * T: lua table，参数类型应该为long
     * G: globals, 参数类型应该为long
     * U: userdata, 参数类型应该为long
     * eg:
     * <code>
     * @CGenerate(params="GTF0")
     * void test(long L, long t, long f, long n){...}
     * </code>
     */
    String params() default "";

    /**
     * 标记方法返回参数类型
     * 0: 无特殊，默认
     * F: lua function，参数类型应该为long
     * T: lua table，参数类型应该为long
     * G: globals, 参数类型应该为long
     * U: userdata, 参数类型应该为long
     * eg:
     * <code>
     * @CGenerate(returnType = "F")
     * long getFunction() {...}
     * </code>
     */
    String returnType() default "";

    /**
     * bridge别名
     */
    String alias() default "";

    /**
     * 标记构造函数是默认构造函数，在其他所有参数不匹配的情况下，使用这个构造函数创建对象
     * 一般
     */
    boolean defaultConstructor() default false;
}
