/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.filter.IWatchFilter;
import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.interfaces.IListChangedCallback;

import java.util.List;
import java.util.Objects;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/7 下午2:44
 */
public class ObserverListWrap {


    private int observerId;
    /**
     * list监听
     */
    private IListChangedCallback iListChangedCallback;

    /**
     * watch回调过滤器
     */
    private List<IWatchFilter> watchFilters;


    public static ObserverListWrap obtain(int observerId, IListChangedCallback iListChangedCallback, List<IWatchFilter> watchKeyFilters) {
        ObserverListWrap observerListWrap = new ObserverListWrap();
        observerListWrap.iListChangedCallback = iListChangedCallback;
        observerListWrap.observerId = observerId;
        observerListWrap.watchFilters = watchKeyFilters;
        return observerListWrap;
    }


    public int getObserverId() {
        return observerId;
    }

    public IListChangedCallback getListChangedCallback() {
        return iListChangedCallback;
    }


    /**
     * 判断是否过滤
     *
     * @param argoWatchContext
     * @param newer
     * @return
     */
    public boolean isFilter(@WatchContext int argoWatchContext, Object newer) {
        if (watchFilters == null || watchFilters.size() == 0) {
            return true;
        }

        for (IWatchFilter watchFilter : watchFilters) {
            if (watchFilter != null && !watchFilter.call(argoWatchContext, newer)) {
                return false;
            }
        }
        return true;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ObserverListWrap that = (ObserverListWrap) o;
        return observerId == that.observerId &&
                Objects.equals(iListChangedCallback, that.iListChangedCallback);
    }

    @Override
    public int hashCode() {
        return Objects.hash(observerId, iListChangedCallback);
    }
}
