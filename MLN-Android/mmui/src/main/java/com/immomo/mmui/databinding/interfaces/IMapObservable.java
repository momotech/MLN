package com.immomo.mmui.databinding.interfaces;

import android.app.Activity;
import android.app.Fragment;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午10:32
 */
public interface IMapObservable<K,V> extends IObservable {
    /**
     * 根据属性变量名注册观察者(最后节点更改才会触发callBack)
     *
     * @param activity 在activity中watch
     * @param fieldTag 属性变量名
     */
    IMapAssembler watch(Activity activity, String fieldTag);


    /**
     * 根据属性变量名注册观察者(最后节点更改才会触发callBack)
     *
     * @param fragment 在fragment中watch
     * @param fieldTag 属性变量名
     */
    IMapAssembler watch(Fragment fragment, String fieldTag);



    /**
     * 根据属性变量名注册观察者(值更改才会触发callBack)
     *
     * @param activity 在activity中watchValue
     * @param fieldTag 属性变量名
     */
    IMapAssembler watchValue(Activity activity, String fieldTag);


    /**
     * 根据属性变量名注册观察者(值更改才会触发callBack)
     *
     * @param fragment 在fragment中watchValue
     * @param fieldTag 属性变量名
     */
    IMapAssembler watchValue(Fragment fragment, String fieldTag);


    /**
     * 在lua层调用put
     *
     * @param key
     * @param value
     */
    V putInLua(K key,V value);




}
