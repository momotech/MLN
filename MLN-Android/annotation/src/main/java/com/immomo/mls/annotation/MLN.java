package com.immomo.mls.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface MLN {
    Type type() default Type.Normal;

    Class convertClass() default Object.class;

    public enum Type {
        Normal,//通用桥接 常用于能多次初始化的类型 例如各种View
        Singleton,//单例 常用于管理类
        Static,//静态 常用于工具类 方法为静态 类似kotlin的object
        //        Convert,//数据转换 不常使用 具体可参考UDMap,
        Const//枚举 参考Gravity
    }
}
