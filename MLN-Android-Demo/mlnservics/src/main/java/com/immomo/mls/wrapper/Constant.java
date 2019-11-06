package com.immomo.mls.wrapper;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 * 常量
 * 可注解到基本数据类型和String上
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
public @interface Constant {
    /**
     * 别名，有别名用别名
     */
    String alias() default "";
}
