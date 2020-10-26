/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.filter.WatchActionFilter;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;

import java.util.List;

/**
 * Description: 观察者属性
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-02 11:29
 */

public class ObserverWrap {

    /**
     * 上下文
     */
    private @WatchContext
    int watchContext;

    /**
     * Global，Activity,Fragment的hashCode
     */
    private int observerId;

    /**
     * bind的整个key
     */
    private String sourceTag;

    /**
     * 已经bind的key
     */
    private String bindTag;


    /**
     * 改变监听
     */
    private IPropertyCallback propertyListener;


    /**
     * 如最后节点是Map 或者list，其中item改变是否通知
     * ListView 和 普通数据 区别
     */
    private boolean isItemChangeNotify = true;


    public boolean isWatchAction() {
        return isWatchAction;
    }

    private boolean isWatchAction = false;

    /**
     * watch回调过滤器
     */
    private List<IWatchKeyFilter> watchKeyFilters;

    public int getObserverId() {
        return observerId;
    }

    public String getBindTag() {
        return bindTag;
    }

    public String getSourceTag() {
        return sourceTag;
    }

    public boolean isItemChangeNotify() {
        return isItemChangeNotify;
    }

    public IPropertyCallback getPropertyListener() {
        return propertyListener;
    }

    public int getWatchContext() {
        return watchContext;
    }


    public List<IWatchKeyFilter> getWatchFilters() {
        return watchKeyFilters;
    }


    public static ObserverWrap obtain(@WatchContext int argoWatchContext, int observerId, String sourceTag, String bindTag, boolean isItemChangeNotify, List<IWatchKeyFilter> iWatchFilters, IPropertyCallback iPropertyCallback) {
        ObserverWrap observerWrap = new ObserverWrap();
        observerWrap.watchContext = argoWatchContext;
        observerWrap.isItemChangeNotify = isItemChangeNotify;
        observerWrap.observerId = observerId;
        observerWrap.sourceTag = sourceTag;
        observerWrap.bindTag = bindTag;
        observerWrap.propertyListener = iPropertyCallback;
        observerWrap.watchKeyFilters = iWatchFilters;
        for (IWatchKeyFilter watchFilter : iWatchFilters) {
            if (watchFilter instanceof WatchActionFilter) {
                observerWrap.isWatchAction = true;
                break;
            }
        }
        return observerWrap;
    }


    /**
     * 判断是否过滤
     *
     * @param argoWatchContext
     * @param newer
     * @return
     */
    public boolean isFilter(@WatchContext int argoWatchContext, String key, Object newer) {
        if (watchKeyFilters == null || watchKeyFilters.size() == 0) {
            return true;
        }

        for (IWatchKeyFilter watchFilter : watchKeyFilters) {
            if (watchFilter instanceof WatchActionFilter) {
                isWatchAction = true;
            }
            if (watchFilter != null && !watchFilter.call(argoWatchContext, key, newer)) {
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof ObserverWrap) {
            ObserverWrap observerWrap = (ObserverWrap) obj;
            return watchContext == observerWrap.watchContext
                    && observerId == observerWrap.getObserverId()
                    && sourceTag.equals(observerWrap.getSourceTag())
                    && bindTag.equals(observerWrap.getBindTag())
                    && propertyListener.equals(observerWrap.propertyListener);
        }
        return super.equals(obj);
    }

    @Override
    public String toString() {
        return "ObserverWrap{" +
                "watchContext=" + watchContext +
                ", observerId=" + observerId +
                ", sourceTag='" + sourceTag + '\'' +
                ", bindTag='" + bindTag + '\'' +
                ", propertyListener=" + propertyListener +
                ", isItemChangeNotify=" + isItemChangeNotify +
                ", watchFilters=" + watchKeyFilters +
                '}';
    }


}