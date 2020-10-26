package com.immomo.mmui.databinding.interfaces;

import android.app.Activity;
import android.app.Fragment;

import com.immomo.mmui.databinding.bean.ObservableField;

import java.util.Map;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午10:32
 */
public interface IFieldObservable extends IObservable {
    /**
     * 根据属性变量名注册观察者
     * 默认只监听lua层改变
     * @param activity 在activity中watch
     * @param fieldTag 属性变量名
     */
    IMapAssembler watch(Activity activity, String fieldTag);


    /**
     * 根据属性变量名注册观察者
     * 默认只监听lua层改变
     * @param fragment 在fragment中watch
     * @param fieldTag 属性变量名
     */
    IMapAssembler watch(Fragment fragment, String fieldTag);


    /**
     * 根据属性变量名注册观察者(值更改才会触发callBack)
     * 默认只监听lua层改变
     * @param activity 在activity中watchValue
     * @param fieldTag 属性变量名
     */
    IMapAssembler watchValue(Activity activity, String fieldTag);


    /**
     * 根据属性变量名注册观察者(值更改才会触发callBack)
     * 默认只监听lua层改变
     * @param fragment 在fragment中watchValue
     * @param fieldTag 属性变量名
     */
    IMapAssembler watchValue(Fragment fragment, String fieldTag);


    /**
     * map转ViewModel
     * @param map
     * @return
     */
    void autoFill(Map map);


}
