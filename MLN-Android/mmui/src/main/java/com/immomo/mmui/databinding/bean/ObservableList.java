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
import com.immomo.mmui.databinding.annotation.ListNotifyType;
import com.immomo.mmui.databinding.interfaces.IListAssembler;
import com.immomo.mmui.databinding.interfaces.IListObservable;
import com.immomo.mmui.databinding.interfaces.IListChangedCallback;
import com.immomo.mmui.databinding.interfaces.IMapAssembler;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.lifeCycle.FragmentLifecycle;
import com.immomo.mmui.databinding.lifeCycle.LifecycleListener;
import com.immomo.mmui.databinding.utils.ObserverUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

import java.util.ArrayList;
import java.util.Collection;

/**
 * Description: 可监听改变的list
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-05 17:24
 */
public class ObservableList<T> extends ArrayList<T> implements IListObservable<T> {

    /**
     * 存储添加的lua层watch回调 {@link IPropertyCallback}
     */
    private ArrayList<ObserverWrap> observerWraps;

    /**
     * 存储list增删该查的回调 {@link IListChangedCallback}
     */
    private ArrayList<ObserverListWrap> observerListWraps;

    /**
     * LuaTable缓存辅助类
     */
    private final FieldCacheHelper fieldCacheHelper = new FieldCacheHelper();

    @Override
    public void addListChangedCallback(ObserverListWrap observerListWrap) {
        if (observerListWraps == null) {
            observerListWraps = new ArrayList<>();
        }
        if(observerListWraps.contains(observerListWrap)) {
            observerListWraps.remove(observerListWrap);
        }
        observerListWraps.add(observerListWrap);
    }

    @Override
    public void removeListChangeCallback(IListChangedCallback iListChangedCallback) {
        if (observerListWraps != null) {
            for(ObserverListWrap observerListWrap:observerListWraps) {
                if(observerListWrap.getListChangedCallback() == iListChangedCallback) {
                    observerListWraps.remove(observerListWrap);
                    break;
                }
            }
        }
    }

    @Override
    public void removeListChangeCallback(int observerId) {
        if (observerListWraps != null) {
            ArrayList<ObserverListWrap> ObserverListWrapClone = (ArrayList<ObserverListWrap>) observerListWraps.clone();
            for(ObserverListWrap observerListWrap:ObserverListWrapClone) {
                if(observerListWrap.getObserverId() == observerId) {
                    observerListWraps.remove(observerListWrap);
                }
            }
        }
    }


    @Override
    public IListAssembler watch(Activity activity) {
        final int observerID = activity.hashCode();
        FragmentLifecycle.getLifeListenerFragment(activity).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                removeListChangeCallback(observerID);
            }
        });
        return ObservableListAssembler.create(observerID,this).filter(WatchContext.ArgoWatch_lua);
    }

    @Override
    public IListAssembler watch(Fragment fragment) {
        final int observerID = fragment.hashCode();
        FragmentLifecycle.getLifeListenerFragment(fragment).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                removeListChangeCallback(observerID);
            }
        });
        return ObservableListAssembler.create(observerID,this).filter(WatchContext.ArgoWatch_lua);
    }



    @Override
    public IMapAssembler watchAll(Globals globals, final String observerTag) {
        final int observerID = globals.hashCode();
        globals.addOnDestroyListener(new Globals.OnDestroyListener() {
            @Override
            public void onDestroy(Globals g) {
                ObserverUtils.removeObserver(g.hashCode(),this,observerTag);
            }
        });
        return ObservableMapAssembler.create(WatchContext.ArgoWatch_lua,this,observerID,observerTag);
    }


    @Override
    public boolean add(T object) {
        return addT(WatchContext.ArgoWatch_native, object);
    }


    @Override
    public boolean addInLua(T object) {
        return addT(WatchContext.ArgoWatch_lua, object);
    }

    /**
     * 区分调用场景（区分lua层还是native层）
     * {@link ObservableList#add(int, Object)}
     * @param argoWatchContext
     * @param object
     * @return
     */
    private boolean addT(@WatchContext int argoWatchContext, T object) {
        ObserverUtils.checkMainThread();
        Object older = this;
        int oldSize = size();
        if (super.add(object)) {
            fieldCacheHelper.addField(oldSize, object);
            notifyChange(argoWatchContext, ListNotifyType.INSERTED, oldSize, 1);
            notifyPropertyChanged(argoWatchContext, "", older, this);
            return true;
        }
        return false;
    }


    @Override
    public void addInLua(int index, T object) {
        addT(WatchContext.ArgoWatch_lua, index, object);
    }


    @Override
    public void add(int index, T object) {
        addT(WatchContext.ArgoWatch_native, index, object);
    }


    /**
     * 区分调用场景（区分lua层还是native层）
     *
     * @param argoWatchContext
     * @param index
     * @param object
     */
    private void addT(@WatchContext int argoWatchContext, int index, T object) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        super.add(index, object);
        fieldCacheHelper.addField(index, object);
        notifyChange(argoWatchContext,ListNotifyType.INSERTED, index, 1);
        notifyPropertyChanged(argoWatchContext, "", older, this);
    }

    @Override
    public T remove(int index) {
        return remove(WatchContext.ArgoWatch_native, index);
    }

    @Override
    public T removeInLua(int index) {
        return remove(WatchContext.ArgoWatch_lua, index);
    }


    /**
     * 区分调用场景（区分lua层还是native层）
     *
     * @param argoWatchContext
     * @param index
     * @return
     */
    private T remove(@WatchContext int argoWatchContext, int index) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        T val = super.remove(index);
        fieldCacheHelper.removeField(index);
        notifyChange(argoWatchContext,ListNotifyType.REMOVED, index, 1);
        notifyPropertyChanged(argoWatchContext, "", older, this);
        return val;
    }


    @Override
    public T set(int index, T object) {
        return set(WatchContext.ArgoWatch_native, index, object);
    }


    @Override
    public T setInLua(int index, T object) {
        return set(WatchContext.ArgoWatch_lua, index, object);
    }


    /**
     * 区分调用场景（区分lua层还是native层）
     * @param argoWatchContext
     * @param index
     * @param object
     * @return
     */
    private T set(@WatchContext int argoWatchContext, int index, T object) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        T val = super.set(index, object);
        fieldCacheHelper.setField(index, object);
        notifyChange(argoWatchContext,ListNotifyType.CHANGED, index, 1);
        notifyPropertyChanged(argoWatchContext, "", older, this);
        return val;
    }


    @Override
    public boolean addAll(Collection<? extends T> collection) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        int oldSize = size();
        boolean added = super.addAll(collection);
        if (added) {
            fieldCacheHelper.addFields((ObservableList) collection);
            notifyChange(WatchContext.ArgoWatch_native,ListNotifyType.INSERTED, oldSize, collection.size());
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
        }
        return added;
    }

    @Override
    public boolean addAll(int index, Collection<? extends T> collection) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        boolean added = super.addAll(index, collection);
        if (added) {
            fieldCacheHelper.addFields(index, (ObservableList) collection);
            notifyChange(WatchContext.ArgoWatch_native,ListNotifyType.INSERTED, index, collection.size());
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
        }
        return added;
    }

    @Override
    public void clear() {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        int oldSize = size();
        super.clear();
        if (oldSize != 0) {
            fieldCacheHelper.clearFields();
            notifyChange(WatchContext.ArgoWatch_native,ListNotifyType.REMOVED, 0, oldSize);
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
        }
    }


    @Override
    public boolean remove(Object object) {
        ObserverUtils.checkMainThread();
        Object older = this.clone();
        int index = indexOf(object);
        if (index >= 0) {
            fieldCacheHelper.removeField(index);
            remove(index);
            notifyChange(WatchContext.ArgoWatch_native,ListNotifyType.REMOVED, index, 1);
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
            return true;
        } else {
            return false;
        }
    }


    /**
     * list中增删改执行该方法 触发{@link IListChangedCallback}接口
     * @param argoWatchContext 改变调用方
     * @param type 增删改查 {@link ListNotifyType}
     * @param start 改变的index
     * @param count 改变的数量
     */
    private void notifyChange(@WatchContext int argoWatchContext, @ListNotifyType int type, int start, int count) {
        if (observerListWraps == null) {
            return;
        }

        ArrayList<ObserverListWrap> ObserverListWrapClone = (ArrayList<ObserverListWrap>) observerListWraps.clone();

        for(ObserverListWrap observerListWrap : ObserverListWrapClone) {
            if(observerListWrap.isFilter(argoWatchContext,this)) {
                observerListWrap.getListChangedCallback().notifyChange(type, start, count);
            }
        }

    }



    @Override
    public void addObserver(ObserverWrap observerWrap) {
        if (observerWraps == null) {
            observerWraps = new ArrayList<>();
        }
        ObserverUtils.addObserver(observerWraps, observerWrap);
    }

    @Override
    public void createObserver(ObserverWrap observerWrap) {
        if (observerWraps == null) {
            observerWraps = new ArrayList<>();
        }
        ObserverUtils.addObserver(observerWraps, observerWrap);
    }

    @Override
    public void removeObserver(IPropertyCallback iPropertyCallback) {
        ObserverUtils.removeObserver(observerWraps, iPropertyCallback);
    }

    @Override
    public void removeObserver(String observerTag) {
        ObserverUtils.removeObserver(observerWraps, observerTag);
    }


    @Override
    public void removeObserver(int observableId) {
        ObserverUtils.removeObserver(observerWraps, observableId);
    }

    @Override
    public void removeObserverByCallBackId(String callBackId) {
        ObserverUtils.removeObserverByCallBackId(observerWraps, callBackId);
    }


    /**
     * item 改变触发 {@link IPropertyCallback} 回调
     * @param argoWatchContext 改变调用方
     * @param fieldName 属性名为""
     * @param older 原值
     * @param newer 新值
     */
    @Override
    public void notifyPropertyChanged(@WatchContext int argoWatchContext, String fieldName, Object older, Object newer) {
        if (observerWraps == null || observerWraps.size() == 0) {
            return;
        }
        ObserverUtils.notifyPropertyChanged((ArrayList<ObserverWrap>) observerWraps.clone(), argoWatchContext, fieldName, older, newer);
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