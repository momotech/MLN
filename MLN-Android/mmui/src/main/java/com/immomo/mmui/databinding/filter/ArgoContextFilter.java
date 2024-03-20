package com.immomo.mmui.databinding.filter;

import android.util.Log;

import com.immomo.mmui.databinding.annotation.WatchContext;

/**
 * Description:argo 上下文过滤器(根据{#link})
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/4 下午3:50
 */
public class ArgoContextFilter implements IWatchKeyFilter{
    private @WatchContext
    int argoWatchContext;

    public ArgoContextFilter(@WatchContext int argoWatchContext) {
        this.argoWatchContext = argoWatchContext;
    }

    @Override
    public boolean call(int argoWatchContext, String key, int invokeNum) {
        if(this.argoWatchContext == WatchContext.ArgoWatch_all && invokeNum == 1) {
            return true;
        }
        return argoWatchContext == this.argoWatchContext && invokeNum == 1;
    }

}
