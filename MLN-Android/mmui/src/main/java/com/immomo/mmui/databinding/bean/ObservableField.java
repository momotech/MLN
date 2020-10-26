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

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.interfaces.IFieldObservable;
import com.immomo.mmui.databinding.interfaces.IMapAssembler;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.vmParse.AutoFillConvertUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

import java.util.Map;
import java.util.Set;


/**
 * Description: 可监听属性改变的ViewModel
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-25 14:19
 */
public class ObservableField implements IFieldObservable {
    protected ObservableMap<String, Object> fields;

    /**
     * ViewModel 绑定的key
     */
    protected String modelKey;

    /**
     * 加载的lua文件
     */
    protected String entryFile;

    /**
     *  加载lua文件的根目录
     */
    protected String rootPath;


    public String getEntryFile() {
        return entryFile;
    }

    public String getRootPath() {
        return rootPath;
    }

    public ObservableField() {
        fields = new ObservableMap<>();
    }


    public String getModelKey() {
        return modelKey;
    }

    /**
     * 存储属性
     *
     * @return
     */
    public ObservableMap<String, Object> getFields() {
        return fields;
    }

    /**
     * 注册观察者
     *
     * @param fieldTag 受监听的属性tag
     */
    @Override
    public IMapAssembler watch(Activity activity, String fieldTag) {
        return fields.watch(activity, fieldTag);
    }

    @Override
    public IMapAssembler watch(Fragment fragment, String fieldTag) {
        return fields.watch(fragment, fieldTag);
    }

    @Override
    public IMapAssembler watchValue(Activity activity, String fieldTag) {
        return fields.watchValue(activity, fieldTag);
    }

    @Override
    public IMapAssembler watchValue(Fragment fragment, String fieldTag) {
        return fields.watchValue(fragment, fieldTag);
    }

    @Override
    public void autoFill(Map map) {
        Set<Map.Entry<Object, Object>> entrySet = map.entrySet();
        for (Map.Entry<Object, Object> entry : entrySet) {
            if (entry.getKey() instanceof String) {
                fields.put((String) entry.getKey(), AutoFillConvertUtils.toNativeValue(map.get(entry.getKey())));
            } else {
                throw new RuntimeException("key must instanceof String");
            }
        }
    }

    /**
     * 如bind(userData.a.b.c)
     *
     * @param globals
     * @param observerTag userData.a.b.c
     */
    @Override
    public IMapAssembler watchAll(Globals globals, String observerTag) {
        return fields.watchAll(globals, observerTag);
    }


    @Override
    public void addObserver(ObserverWrap observerWrap) {
        fields.addObserver(observerWrap);
    }

    @Override
    public void createObserver(ObserverWrap observerWrap) {
        fields.createObserver(observerWrap);
    }

    @Override
    public void removeObserver(IPropertyCallback iPropertyCallback) {
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
    public void notifyPropertyChanged(@WatchContext int argoWatchContext, String fieldName, Object older, Object newer) {
        fields.notifyPropertyChanged(argoWatchContext, fieldName, older, newer);
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