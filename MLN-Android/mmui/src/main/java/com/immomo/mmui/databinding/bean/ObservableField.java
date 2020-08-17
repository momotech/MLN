/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;


import android.app.Activity;
import android.app.Fragment;

import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;



/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-25 14:19
 */
public class ObservableField implements IObservable {
    protected ObservableMap<String,Object> fields;


    public ObservableField() {
        fields = new ObservableMap<>();
    }

    /**
     * 存储属性
     * @return
     */
    public ObservableMap<String, Object> getFields() {
        return fields;
    }

    /**
     * 注册观察者
     * @param fieldTag 受监听的属性tag
     * @param iPropertyCallback
     */
    @Override
    public void watch(Activity activity, String fieldTag, IPropertyCallback iPropertyCallback) {
        fields.watch(activity,fieldTag,iPropertyCallback);
    }

    @Override
    public void watch(Fragment fragment, String fieldTag, IPropertyCallback iPropertyCallback) {
        fields.watch(fragment,fieldTag,iPropertyCallback);
    }

    /**
     * 如bind(userData.a.b.c)
     * @param observerId
     * @param wholeTag userData.a.b.c
     *
     * @param iPropertyCallback
     */
    @Override
    public void watch(int observerId, String wholeTag,boolean isSelfObserved, boolean isItemChangedNotify, IPropertyCallback iPropertyCallback) {
        fields.watch(observerId,wholeTag,isSelfObserved,isItemChangedNotify,iPropertyCallback);
    }

    @Override
    public void addObserver( ObserverWrap observerWrap) {
        fields.addObserver(observerWrap);
    }

    @Override
    public void removeObserver( IPropertyCallback iPropertyCallback) {
        fields.removeObserver(iPropertyCallback);
    }

    @Override
    public void removeObserver(String observerTag) {
        fields.removeObserver(observerTag);
    }

    @Override
    public void removeObserver(int observableId) {
        fields.removeObserver(observableId);
    }

    @Override
    public void removeObserverByCallBackId(String callBackId) {
        fields.removeObserverByCallBackId(callBackId);
    }

    @Override
    public void notifyPropertyChanged(String fieldName, Object older, Object newer) {
        fields.notifyPropertyChanged(fieldName,older,newer);
    }

    @Override
    public LuaTable getFieldCache(Globals globals) {
        return fields.getFieldCache(globals);
    }

    @Override
    public void addFieldCache(LuaTable luaTable) {
        fields.addFieldCache(luaTable);
    }


}