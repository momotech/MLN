package com.immomo.mls.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by XiongFangyu on 2019/3/15.
 *
 * 注解在userdata类上，或静态Bridge类上
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface LuaClass {
    /**
     * 是否是静态Bridge
     */
    boolean isStatic() default false;

    boolean isSingleton() default false;
    /**
     * 若类型为userdata，是否让lua来管理内存
     */
    boolean gcByLua() default true;

    /**
     * 是否是abstract class
     */
    boolean abstractClass() default false;

    String name() default "";
    String comment() default "";
}
