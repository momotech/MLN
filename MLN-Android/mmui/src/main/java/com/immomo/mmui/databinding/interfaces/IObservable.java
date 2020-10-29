/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.interfaces;


import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.bean.ObserverWrap;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-16 10:25
 */
public interface IObservable {


    /**
     * 根据observerTag添加回调
     *
     * @param globals  lua中增加watch
     * @param observerTag
     */
    IMapAssembler watchAll(Globals globals, String observerTag);

    /**
     * 添加观察者
     *
     * @param observerWrap
     */
    void addObserver(ObserverWrap observerWrap);


    /**
     * 创建观察者
     * @param observerWrap
     */
    void createObserver(ObserverWrap observerWrap);

    /**
     * 根据iPropertyCallback移除观察者
     *
     * @param iPropertyCallback
     */
    void removeObserver(IPropertyCallback iPropertyCallback);


    /**
     * 根据observerTag移除监听（适用于bindCell）
     *
     * @param observerTag
     */
    void removeObserver(String observerTag);

    /**
     * 根据activity和global的hashCode移除观察者
     *
     * @param observableId
     */
    void removeObserver(int observableId);


    /**
     * 根据IPropertyCallback的hashCode移除观察者
     *
     * @param callBackId
     */
    void removeObserverByCallBackId(String callBackId);

    /**
     * 属性改变进行传旧值和新值
     *
     * @param fieldName
     * @param older
     * @param newer
     */
    void notifyPropertyChanged(@WatchContext int argoWatchContext, String fieldName, Object older, Object newer);


    /**
     * 获取缓存
     *
     * @param globals
     * @return
     */
    LuaTable getFieldCache(Globals globals);


    /**
     * 添加缓存
     *
     * @param luaTable
     */
    void addFieldCache(LuaTable luaTable);

}