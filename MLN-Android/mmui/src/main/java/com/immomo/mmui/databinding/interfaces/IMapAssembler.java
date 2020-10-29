package com.immomo.mmui.databinding.interfaces;

import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.filter.IWatchFilter;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;

/**
 * Description:观察者装配器
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/4 下午3:21
 */
public interface IMapAssembler {

    /**
     * 设置自定义的过滤器
     * @param iWatchFilter
     * @return
     */
    IMapAssembler filter(IWatchFilter iWatchFilter);


    /**
     * 设置调用场景argoWatchContext {@link com.immomo.mmui.databinding.filter.ArgoContextFilter}
     * @param argoWatchContext
     * @return
     */
    IMapAssembler filter(@WatchContext int argoWatchContext);


    /**
     * 如果最后节点是list，设置是否item改变会执行回调
     * @param isItemChange
     * @return
     */
     IMapAssembler filterItemChange(boolean isItemChange);


    /**
     * 添加Action的过滤器
     * @param iWatchKeyFilter
     * @return
     */
     IMapAssembler filterAction(IWatchKeyFilter iWatchKeyFilter);


    /**
     * 指定的key进行过滤
     * @param iWatchKeyFilter
     * @return
     */
    IMapAssembler filter(IWatchKeyFilter iWatchKeyFilter);


    /**
     * 设置改变回调
     * @param iPropertyCallback
     * @return
     */
    IMapAssembler callback(IPropertyCallback iPropertyCallback);


    /**
     * 获取最终的观察者
     * @return
     */
    IObservable getObserved();

    /**
     * 获取最终观察的tag
     * @return
     */
    String getObservedTag();


    /**
     * 注销watch
     */
    void unwatch();

}
