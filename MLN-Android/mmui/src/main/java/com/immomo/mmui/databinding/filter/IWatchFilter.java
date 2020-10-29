package com.immomo.mmui.databinding.filter;


import com.immomo.mmui.databinding.annotation.WatchContext;

/**
 * Description:watch 过滤器
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/3 下午8:24
 */
public interface IWatchFilter<T> {
    boolean call(@WatchContext int argoWatchContext, T newer);
}
