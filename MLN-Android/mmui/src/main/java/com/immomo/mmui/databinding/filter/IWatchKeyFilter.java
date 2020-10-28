package com.immomo.mmui.databinding.filter;

import com.immomo.mmui.databinding.annotation.WatchContext;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/14 下午12:25
 */
public interface IWatchKeyFilter<T>{
    boolean call(@WatchContext int argoWatchContext, String key, T newer);
}
