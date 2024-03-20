package com.immomo.mmui.databinding.interfaces;

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.filter.IWatchFilter;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午9:33
 */
public interface IListAssembler {

    IListAssembler filter(IWatchFilter iWatchFilter);

    IListAssembler filter(@WatchContext int argoWatchContext);

    IListAssembler callback(IListChangedCallback iListChangedCallback);

    void unwatch();
}
