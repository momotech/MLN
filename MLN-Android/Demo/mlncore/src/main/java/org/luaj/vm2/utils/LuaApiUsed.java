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
}
