/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.interfaces;


import android.app.Activity;
import android.app.Fragment;


import com.immomo.mmui.databinding.bean.ObserverWrap;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-16 10:25
 */
public interface IObservable {

    /**
     * 根据属性变量名注册观察者
     * @param activity 在activity中watch
     * @param fieldTag 属性变量名
     * @param iPropertyCallback
     */
    void watch(Activity activity, String fieldTag, IPropertyCallback iPropertyCallback);


    /**
     * 根据属性变量名注册观察者
     * @param fragment 在fragment中watch
     * @param fieldTag 属性变量名
     * @param iPropertyCallback
     */
    void watch(Fragment fragment, String fieldTag, IPropertyCallback iPropertyCallback);

    /**
     * 根据属性
     * @param observerId （Activity的hashCode,Global的hashCode）
     * @param observerTag
     * @param isSelfObserved 自身是否被观察
     * @param isItemChangedNotify (如根结点是Map和List，item 改变是否通知观察者)
     * @param iPropertyCallback
     */
    void watch(int observerId, String observerTag,boolean isSelfObserved,boolean isItemChangedNotify,IPropertyCallback iPropertyCallback);

    /**
     * 添加观察者
     * @param observerWrap
     */
    void addObserver(ObserverWrap observerWrap);

    /**
     * 根据iPropertyCallback移除观察者
     * @param iPropertyCallback
     */
    void removeObserver(IPropertyCallback iPropertyCallback);


    /**
     * 根据observerTag移除监听（适用于bindCell）
     * @param observerTag
     */
    void removeObserver(String observerTag);

    /**
     * 根据activity和global的hashCode移除观察者
     * @param observableId
     */
    void removeObserver(int observableId);


    /**
     * 根据IPropertyCallback的hashCode移除观察者
     * @param callBackId
     */
    void removeObserverByCallBackId(String callBackId);

    /**
     * 属性改变进行传旧值和新值
     * @param fieldName
     * @param older
     * @param newer
     */
    void notifyPropertyChanged(String fieldName, Object older, Object newer);
}