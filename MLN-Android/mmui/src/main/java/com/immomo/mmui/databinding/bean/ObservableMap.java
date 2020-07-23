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

import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.lifeCycle.FragmentLifecycle;
import com.immomo.mmui.databinding.lifeCycle.LifecycleListener;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.ObserverUtils;

import java.util.*;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-15 18:20
 */
public class ObservableMap<K,V> extends HashMap<K, V> implements IObservable {
    private ArrayList<ObserverWrap> observerWraps;

    @Override
    public void watch(Activity activity, final String fieldTag, IPropertyCallback iPropertyCallback) {
        final int observerId = activity.hashCode();
        final String observerTag = this.getClass().getSimpleName() + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(activity).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId,this,observerTag);
            }
        });
        watch(observerId,observerTag,true,true,iPropertyCallback);
    }

    @Override
    public void watch(Fragment fragment, String fieldTag, IPropertyCallback iPropertyCallback) {
        final int observerId = fragment.hashCode();
        final String observerTag = this.getClass().getSimpleName() + Constants.SPOT + fieldTag;
        FragmentLifecycle.getLifeListenerFragment(fragment).addListener(new LifecycleListener() {
            @Override
            public void onDestroy() {
                ObserverUtils.removeObserver(observerId,this,observerTag);
            }
        });
    }

    @Override
    public void watch(int observerId, String wholeTag,boolean isSelfObserved, boolean isItemChangedNotify, IPropertyCallback iPropertyCallback) {
        ObserverUtils.subscribe(this,observerId,wholeTag,isSelfObserved,isItemChangedNotify,iPropertyCallback);
    }


    @Override
    public void addObserver( ObserverWrap observerWrap) {
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


    @Nullable
    @Override
    public V put(K key, V value) {
        V oldV = super.put(key, value);
        if(observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged((String)key,oldV,value);
        }

        return oldV;
    }

    @Override
    public void putAll(@Nullable Map<? extends K, ? extends V> m) {
        Map older = (Map) this.clone();
        super.putAll(m);
        if(observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged("",older,this);
        }
    }

    @Nullable
    @Override
    public V remove(@Nullable Object key) {
        Map older = (Map) this.clone();
        V k = super.remove(key);
        if(observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged("",older,this);
        }
        return k;
    }

    @Override
    public void clear() {
        Map older = (Map) this.clone();
        super.clear();
        if(observerWraps != null && observerWraps.size() > 0) {
            notifyPropertyChanged("",older,this);
        }
    }


    @Override
    public void notifyPropertyChanged(String fieldName, Object older, Object newer) {
        if(observerWraps ==null || observerWraps.size() ==0) {
            return;
        }
        ObserverUtils.notifyPropertyChanged((List<ObserverWrap>) observerWraps.clone(),fieldName,older,newer);
    }


}