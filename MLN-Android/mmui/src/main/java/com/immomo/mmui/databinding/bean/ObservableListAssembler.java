/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.filter.IWatchFilter;
import com.immomo.mmui.databinding.interfaces.IListAssembler;
import com.immomo.mmui.databinding.interfaces.IListChangedCallback;
import com.immomo.mmui.databinding.interfaces.IListObservable;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午10:43
 */
public class ObservableListAssembler implements IListAssembler {

    private int observerId;
    private IListObservable iListObservable;
    private List<IWatchFilter> iWatchFilters = new ArrayList<>();
    private IListChangedCallback iListChangedCallback;
    private boolean isCallBack = false;

    public static ObservableListAssembler create(int observerId,IListObservable iListObservable) {
        ObservableListAssembler observableListAssembler = new ObservableListAssembler();
        observableListAssembler.iListObservable = iListObservable;
        observableListAssembler.observerId = observerId;
        return observableListAssembler;
    }

    @Override
    public IListAssembler filter(IWatchFilter iWatchFilter) {
        checkAvailable();
        if(iWatchFilter == null) {
            return this;
        }
        iWatchFilters.clear();
        iWatchFilters.add(iWatchFilter);
        return this;
    }

    @Override
    public IListAssembler filter(final @WatchContext int argoWatchContext) {
        checkAvailable();
        iWatchFilters.clear();
        iWatchFilters.add(new IWatchFilter() {
            @Override
            public boolean call(int argoWatchContext1, Object newer) {
                return argoWatchContext1 == argoWatchContext;
            }
        });
        return this;
    }

    @Override
    public IListAssembler callback(IListChangedCallback iListChangedCallback) {
        isCallBack = true;
        this.iListChangedCallback = iListChangedCallback;
        if(iWatchFilters.size() == 0) {
            iWatchFilters.add(new IWatchFilter() {
                @Override
                public boolean call(int argoWatchContext, Object newer) {
                    return argoWatchContext == WatchContext.ArgoWatch_lua;
                }
            });
        }
        this.iListObservable.addListChangedCallback(ObserverListWrap.obtain(observerId,iListChangedCallback,iWatchFilters));
        return this;
    }


    public void checkAvailable() {
        if(isCallBack) {
            throw new RuntimeException("must invoke before callback");
        }
    }


    @Override
    public void unwatch() {
        this.iListObservable.removeListChangeCallback(this.iListChangedCallback);
    }
}
