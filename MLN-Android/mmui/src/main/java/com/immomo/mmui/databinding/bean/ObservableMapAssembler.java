/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.DataBindingEngine;
import com.immomo.mmui.databinding.filter.ArgoContextFilter;
import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.interfaces.IMapAssembler;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.filter.IWatchFilter;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.ObserverUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:观察者装配
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/4 下午3:19
 */
public class ObservableMapAssembler implements IMapAssembler {


    private @WatchContext
    int argoWatchContext;
    private IObservable observed;
    private int observerId;
    private String observedTag;
    /**
     * 添加过滤器
     */
    private List<IWatchKeyFilter> iWatchFilters = new ArrayList<>();

    /**
     * 回调
     */
    private IPropertyCallback iPropertyCallback;

    /**
     * 是否已经执行callBack, callBack 最后执行，如果顺序错误，会报错
     */
    private boolean isInvokeCallBack = false;

    /**
     * 最后节点是list，list的item改变是否通知设置
     */
    private boolean isItemChange = true;


    /**
     * action的过滤器
     */
    private IWatchKeyFilter actionFilter;


    public ObservableMapAssembler(@WatchContext int argoWatchContext, IObservable observed, int observerId, String observedTag) {
        this.argoWatchContext = argoWatchContext;
        this.observed = observed;
        this.observerId = observerId;
        this.observedTag = observedTag;
    }


    /**
     * 创建装配器
     * @param argoWatchContext
     * @param observer
     * @param observerId
     * @param fieldTag
     * @return
     */
    public static IMapAssembler create(@WatchContext int argoWatchContext, IObservable observer, int observerId, String fieldTag) {
        ObservableMapAssembler observableMapAssembler = new ObservableMapAssembler(argoWatchContext,observer,observerId,fieldTag);
        return observableMapAssembler;
    }

    @Override
    public IMapAssembler filter(final IWatchFilter iWatchFilter) {
        checkAvailable();
        if(iWatchFilter == null) {
            return this;
        }
        iWatchFilters.clear();
        iWatchFilters.add(new IWatchKeyFilter() {
            @Override
            public boolean call(int argoWatchContext, String key, Object newer) {
                return iWatchFilter.call(argoWatchContext,newer);
            }
        });
        return this;
    }

    @Override
    public IMapAssembler filter(@WatchContext int argoWatchContext) {
        checkAvailable();
        iWatchFilters.clear();
        iWatchFilters.add(new ArgoContextFilter(argoWatchContext));
        return this;
    }

    @Override
    public IMapAssembler filterItemChange(boolean isItemChange) {
        checkAvailable();
        this.isItemChange = isItemChange;
        return this;
    }

    @Override
    public IMapAssembler filterAction(IWatchKeyFilter iWatchKeyFilter) {
        actionFilter = iWatchKeyFilter;
        return this;
    }

    @Override
    public IMapAssembler filter(IWatchKeyFilter iWatchKeyFilter) {
        if(iWatchKeyFilter == null) {
            return this;
        }
        iWatchFilters.clear();
        iWatchFilters.add(iWatchKeyFilter);
        return this;
    }


    @Override
    public IMapAssembler callback(IPropertyCallback iPropertyCallback) {
        this.iPropertyCallback = iPropertyCallback;
        this.isInvokeCallBack = true;
        String[] tags = observedTag.split(Constants.SPOT_SPLIT);
        int finalNumIndex =ObserverUtils.getFinalNumFromTag(tags);
        if (finalNumIndex != -1) { //表示没有数字
            String beforeNumTag = ObserverUtils.getBeforeStr(tags, finalNumIndex);
            if (beforeNumTag.length() != observedTag.length()) {
                String afterNumTag = observedTag.substring(beforeNumTag.length() + 1);
                observedTag = new StringBuilder(tags[0]).append(Constants.SPOT).append(afterNumTag).toString();
            } else {
                observedTag = tags[0];
            }
            observed = (IObservable) DataBindingEngine.getInstance().getGetSetAdapter().get(observed, beforeNumTag.substring(beforeNumTag.indexOf(Constants.SPOT) + 1));
        }

        //添加watchAction
        if(actionFilter !=null) {
            iWatchFilters.add(actionFilter);
        }

        ObserverUtils.subscribe(argoWatchContext, observed, observerId, observedTag,  isItemChange,iWatchFilters, iPropertyCallback);
        return this;
    }

    @Override
    public IObservable getObserved() {
        return observed;
    }

    @Override
    public String getObservedTag() {
        return observedTag;
    }

    public void checkAvailable() {
        if(isInvokeCallBack) {
            throw new RuntimeException("must invoke before callback");
        }
    }

    @Override
    public void unwatch() {
        if(observed !=null && iPropertyCallback !=null) {
            DataBindingEngine.getInstance().getDataProcessor().removeObserver(observed,String.valueOf(iPropertyCallback.hashCode()), observedTag);
        }
    }


}
