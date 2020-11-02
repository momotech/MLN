/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.interfaces.IPropertyCallback;

import java.util.Objects;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/7/24 下午3:08
 */
public class WatchCallBack {

    private Object older;
    private Object newer;
    private IPropertyCallback iPropertyCallback;

    public Object getOlder() {
        return older;
    }

    public void setOlder(Object older) {
        this.older = older;
    }

    public Object getNewer() {
        return newer;
    }

    public void setNewer(Object newer) {
        this.newer = newer;
    }

    public IPropertyCallback getiPropertyCallback() {
        return iPropertyCallback;
    }

    public void setiPropertyCallback(IPropertyCallback iPropertyCallback) {
        this.iPropertyCallback = iPropertyCallback;
    }


    public static WatchCallBack obtain(IPropertyCallback iPropertyCallback,Object older,Object newer) {
        WatchCallBack watchCallBack = new WatchCallBack();
        watchCallBack.iPropertyCallback = iPropertyCallback;
        watchCallBack.older = older;
        watchCallBack.newer = newer;
        return watchCallBack;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        WatchCallBack that = (WatchCallBack) o;
        return Objects.equals(iPropertyCallback, that.iPropertyCallback);
    }

    @Override
    public int hashCode() {
        return Objects.hash(iPropertyCallback);
    }
}
