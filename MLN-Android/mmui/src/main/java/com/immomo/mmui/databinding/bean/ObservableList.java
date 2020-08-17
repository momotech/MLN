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

import androidx.annotation.NonNull;

import com.immomo.mmui.databinding.interfaces.IItemChangeCallback;
import com.immomo.mmui.databinding.interfaces.IListChangeObservable;
import com.immomo.mmui.databinding.interfaces.IListChangedCallback;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.ObserverUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-05 17:24
 */
public class ObservableList<T> extends ArrayList<T> implements IObservable, IListChangeObservable {
    public static final int CHANGED = 1;
    public static final int INSERTED = 2;
    public static final int REMOVED = 4;


    private ArrayList<ObserverWrap> observerWraps;
    private List<IItemChangeCallback> iItemChangeCallbacks;
    private List<IListChangedCallback> iListChangedCallbackList;

    private final FieldCacheHelper fieldCacheHelper = new FieldCacheHelper();

    @Override
    public void addListChangedCallback(IListChangedCallback iListChangedCallback) {
        if (iListChangedCallbackList == null) {
            iListChangedCallbackList = new ArrayList<>();
        }
        iListChangedCallbackList.add(iListChangedCallback);
    }

    @Override
    public void removeListChangeCallback(IListChangedCallback iListChangedCallback) {
        if (iListChangedCallbackList != null) {
            iListChangedCallbackList.remove(iListChangedCallback);
        }
    }

    /**
     * 注册item 监听
     * @param iItemChangeCallback
     */
    public void subscribeItem(IItemChangeCallback iItemChangeCallback) {
        if(iItemChangeCallbacks ==null) {
            iItemChangeCallbacks = new ArrayList<>();
        }
        iItemChangeCallbacks.add(iItemChangeCallback);
    }


    /**
     * mode 改动
     * @param mode
     * @param keyPath
     * @param older
     * @param newV
     */
    public void updateMode(Object mode,String keyPath,Object older, Object newV) {
        for(IItemChangeCallback iItemChangeCallback:iItemChangeCallbacks) {
            iItemChangeCallback.callBack(mode,keyPath,older,newV);
        }
    }



    @Override
    public boolean add(T object) {
        Object older = this;
        int oldSize = size();
        if (super.add(object)) {
            fieldCacheHelper.addField(oldSize,object);
            notifyChange(INSERTED, oldSize, 1);
            notifyPropertyChanged("",older,this);
            return true;
        }
        return false;
    }

    @Override
    public void add(int index, T object) {
        Object older = this.clone();
        super.add(index, object);
        fieldCacheHelper.addField(index,object);
        notifyChange(INSERTED, index, 1);
        notifyPropertyChanged("",older,this);
    }

    @Override
    public boolean addAll(Collection<? extends T> collection) {
        Object older = this.clone();
        int oldSize = size();
        boolean added = super.addAll(collection);
        if (added) {
            fieldCacheHelper.addFields((ObservableList)collection);
            notifyChange(INSERTED, oldSize, collection.size());
            notifyPropertyChanged("",older,this);
        }
        return added;
    }

    @Override
    public boolean addAll(int index, Collection<? extends T> collection) {
        Object older = this.clone();
        boolean added = super.addAll(index, collection);
        if (added) {
            fieldCacheHelper.addFields(index,(ObservableList)collection);
            notifyChange(INSERTED, index, collection.size());
            notifyPropertyChanged("",older,this);
        }
        return added;
    }

    @Override
    public void clear() {
        Object older = this.clone();
        int oldSize = size();
        super.clear();
        if (oldSize != 0) {
            fieldCacheHelper.clearFields();
            notifyChange(REMOVED, 0, oldSize);
            notifyPropertyChanged("",older,this);
        }
    }

    @Override
    public T remove(int index) {
        Object older = this.clone();
        T val = super.remove(index);
        fieldCacheHelper.removeField(index);
        notifyChange(REMOVED, index, 1);
        notifyPropertyChanged("",older,this);
        return val;
    }


    @Override
    public boolean remove(Object object) {
        Object older = this.clone();
        int index = indexOf(object);
        if (index >= 0) {
            remove(index);
            notifyChange(REMOVED, index, 1);
            notifyPropertyChanged("",older,this);
            return true;
        } else {
            return false;
        }
    }

    @Override
    public T set(int index, T object) {
        Object older = this.clone();
        T val = super.set(index, object);
        fieldCacheHelper.addField(index,object);
        notifyChange(CHANGED, index, 1);
        notifyPropertyChanged("",older,this);
        return val;
    }

    private void notifyChange(int type, int start, int count) {
        if (iListChangedCallbackList == null) {
            return;
        }
        for (IListChangedCallback iListChangedCallback : iListChangedCallbackList) {
            iListChangedCallback.notifyChange(type, start, count);
        }
    }


    @Override
    public void watch(Activity activity, String fieldTag, IPropertyCallback iPropertyCallback) {
        //空实现
    }

    @Override
    public void watch(Fragment fragment, String fieldTag, IPropertyCallback iPropertyCallback) {
        //空实现
    }

    @Override
    public void watch(int observerId, String observerTag ,boolean isSelfObserved, boolean isItemChangedNotify, IPropertyCallback iPropertyCallback) {
        ObserverUtils.subscribe(this,observerId,observerTag, isSelfObserved,isItemChangedNotify,iPropertyCallback);
    }

    @Override
    public void addObserver(ObserverWrap observerWrap) {
        if(observerWraps == null) {
            observerWraps = new ArrayList<>();
        }
        ObserverUtils.addObserver(observerWraps,observerWrap);
    }

    @Override
    public void removeObserver(IPropertyCallback iPropertyCallback) {
        ObserverUtils.removeObserver(observerWraps,iPropertyCallback);
    }

    @Override
    public void removeObserver(String observerTag) {
        ObserverUtils.removeObserver(observerWraps,observerTag);
    }


    @Override
    public void removeObserver(int observableId) {
        ObserverUtils.removeObserver(observerWraps,observableId);
    }

    @Override
    public void removeObserverByCallBackId(String callBackId) {
        ObserverUtils.removeObserverByCallBackId(observerWraps,callBackId);
    }

    @Override
    public void notifyPropertyChanged(String fieldName, Object older, Object newer) {
        if(observerWraps ==null || observerWraps.size() ==0) {
            return;
        }
        ObserverUtils.notifyPropertyChanged((ArrayList<ObserverWrap>) observerWraps.clone(),fieldName,older,newer);
    }

    @Override
    public LuaTable getFieldCache(Globals globals) {
        return fieldCacheHelper.getFieldCache(globals);
    }

    @Override
    public void addFieldCache(LuaTable luaTable) {
        fieldCacheHelper.addFieldCache(luaTable);
    }


}