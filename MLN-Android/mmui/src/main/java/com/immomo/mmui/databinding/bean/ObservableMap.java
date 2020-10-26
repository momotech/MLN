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

import androidx.annotation.Nullable;

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.core.PropertyCallBackHandler;
import com.immomo.mmui.databinding.filter.WatchActionFilter;
import com.immomo.mmui.databinding.interfaces.IMapAssembler;
import com.immomo.mmui.databinding.interfaces.IMapObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.lifeCycle.FragmentLifecycle;
import com.immomo.mmui.databinding.lifeCycle.LifecycleListener;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.ObserverUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

import java.util.*;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-15 18:20
 */
public class ObservableMap<K, V> extends HashMap<K, V> implements IMapObservable<K, V> {
    /**
     * 存储添加的lua层watch回调 {@link IPropertyCallback}
     */
    private ArrayList<ObserverWrap> observerWraps;

    /**
     * LuaTable缓存辅助类
     */
    private final FieldCacheHelper fieldCacheHelper = new FieldCacheHelper();

    private Set<StickField> stickFields;

    @Override
    public IMapAssembler watch(Activity activity, final String fieldTag) {
        final int observerId = activity.hashCode();
        final String observerTag = Constants.ACTIVITY + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(activity).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId, this, observerTag);
            }
        });

        return ObservableMapAssembler.create(WatchContext.ArgoWatch_native, this, observerId, observerTag)
                .filterAction(new WatchActionFilter(observerTag))
                .filter(WatchContext.ArgoWatch_lua);
    }


    @Override
    public IMapAssembler watch(Fragment fragment, String fieldTag) {
        final int observerId = fragment.hashCode();
        final String observerTag = Constants.FRAGMENT + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(fragment).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId, this, observerTag);
            }
        });

        return ObservableMapAssembler.create(WatchContext.ArgoWatch_native, this, observerId, fieldTag)
                .filterAction(new WatchActionFilter(observerTag))
                .filter(WatchContext.ArgoWatch_lua);
    }

    @Override
    public IMapAssembler watchValue(Activity activity, String fieldTag) {
        final int observerId = activity.hashCode();
        final String observerTag = Constants.ACTIVITY + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(activity).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId, this, observerTag);
            }
        });
        return ObservableMapAssembler.create(WatchContext.ArgoWatch_native, this, observerId, observerTag)
                .filter(WatchContext.ArgoWatch_lua);
    }

    @Override
    public IMapAssembler watchValue(Fragment fragment, String fieldTag) {
        final int observerId = fragment.hashCode();
        final String observerTag = Constants.FRAGMENT + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(fragment).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId, this, observerTag);
            }
        });
        return ObservableMapAssembler.create(WatchContext.ArgoWatch_native, this, observerId, observerTag)
                .filter(WatchContext.ArgoWatch_lua);
    }


    @Override
    public IMapAssembler watchAll(Globals globals, final String observerTag) {
        final int observerID = globals.hashCode();
        globals.addOnDestroyListener(new Globals.OnDestroyListener() {
            @Override
            public void onDestroy(Globals g) {
                ObserverUtils.removeObserver(g.hashCode(), this, observerTag);
            }
        });
        return ObservableMapAssembler.create(WatchContext.ArgoWatch_lua, this, observerID, observerTag);
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
        //处理粘性WatchAction的逻辑
        if (observerWrap.isWatchAction() && stickFields != null) {
            String filedTag = observerWrap.getSourceTag().replace(observerWrap.getBindTag() + Constants.SPOT, "");
            for(StickField stickField:stickFields) {
                if(stickField.getField().equals(filedTag)  && observerWrap.getWatchContext() != stickField.getWatchContext()) {
                    Object newClass = get(filedTag);
                    PropertyCallBackHandler.getInstance().addCallBack(WatchCallBack.obtain(observerWrap.getPropertyListener(), null, newClass));
                    stickFields.remove(stickField);
                    break;
                }
            }
        }
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


    @Nullable
    @Override
    public V put(K key, V value) {
        return put(WatchContext.ArgoWatch_native, key, value);
    }

    public V mock(K key, V value) {
        ObserverUtils.checkMainThread();
        return super.put(key, value);
    }

    @Override
    public V putInLua(K key, V value) {
        return put(WatchContext.ArgoWatch_lua, key, value);
    }


    /**
     * @param argoWatchContext
     * @param key
     * @param value
     * @return
     */
    private V put(@WatchContext int argoWatchContext, K key, V value) {
        ObserverUtils.checkMainThread();
        V oldV = super.put(key, value);
        if (key instanceof String) {
            if (stickFields == null) {
                stickFields = new HashSet<>();
            }
            StickField stickField = StickField.obtain(argoWatchContext,(String) key);
            if(stickFields.contains(stickField)) {
                stickFields.remove(stickField);
            }
            stickFields.add(stickField);
            fieldCacheHelper.putField((String) key, value);
            if (observerWraps != null && observerWraps.size() > 0) {
                notifyPropertyChanged(argoWatchContext, (String) key, oldV, value);
            }
        } else {
            throw new RuntimeException("map.key must String");
        }
        return oldV;
    }


    @Override
    public void putAll(@Nullable Map<? extends K, ? extends V> m) {
        ObserverUtils.checkMainThread();
        Map older = (Map) this.clone();
        super.putAll(m);
        if (m instanceof ObservableMap) {
            fieldCacheHelper.putAllField((ObservableMap) m);
            if (observerWraps != null && observerWraps.size() > 0) {
                notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
            }
        } else {
            throw new RuntimeException("parameter must ObservableMap");
        }
    }

    @Nullable
    @Override
    public V remove(@Nullable Object key) {
        ObserverUtils.checkMainThread();
        Map older = (Map) this.clone();
        V k = super.remove(key);
        fieldCacheHelper.removeField((String) k);
        if (observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
        }
        return k;
    }

    @Override
    public void clear() {
        ObserverUtils.checkMainThread();
        Map older = (Map) this.clone();
        super.clear();
        fieldCacheHelper.clearFields();
        if (observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged(WatchContext.ArgoWatch_native, "", older, this);
        }
    }


    @Override
    public void notifyPropertyChanged(@WatchContext int argoWatchContext, String fieldName, Object older, Object newer) {
        if (observerWraps == null || observerWraps.size() == 0) {
            return;
        }
        ObserverUtils.notifyPropertyChanged((List<ObserverWrap>) observerWraps.clone(), argoWatchContext, fieldName, older, newer);
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