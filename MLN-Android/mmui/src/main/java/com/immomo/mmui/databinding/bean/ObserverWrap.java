/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.interfaces.IPropertyCallback;

/**
 * Description: 观察者属性
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-02 11:29
 */

public class ObserverWrap {


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

    public static ObserverWrap obtain(int observerId,String sourceTag, String bindTag,boolean isItemChangeNotify, IPropertyCallback iPropertyCallback) {
        ObserverWrap observerWrap = new ObserverWrap();
        observerWrap.isItemChangeNotify = isItemChangeNotify;
        observerWrap.observerId = observerId;
        observerWrap.sourceTag = sourceTag;
        observerWrap.bindTag = bindTag;
        observerWrap.propertyListener = iPropertyCallback;
        return observerWrap;
    }


    @Override
    public boolean equals(Object obj) {
        if(obj instanceof ObserverWrap) {
            ObserverWrap observerWrap = (ObserverWrap)obj;
            return observerId == observerWrap.getObserverId()
                    && sourceTag.equals(observerWrap.getSourceTag())
                    && bindTag.equals(observerWrap.getBindTag())
                    && propertyListener.equals(observerWrap.propertyListener);
        }
        return super.equals(obj);
    }
}