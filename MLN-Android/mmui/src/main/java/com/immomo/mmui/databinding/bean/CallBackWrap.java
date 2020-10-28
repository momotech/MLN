/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;


/**
 * Description: IPropertyCallback的扩展类，
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午2:24
 */
public class CallBackWrap {
    private String observableTag;
    private Object observer;

    public String getObservableTag() {
        return observableTag;
    }

    public void setObservableTag(String observableTag) {
        this.observableTag = observableTag;
    }

    public Object getObserver() {
        return observer;
    }

    public void setObserver(Object observer) {
        this.observer = observer;
    }

    public static CallBackWrap obtain(Object observer, String observableTag) {
        CallBackWrap callBackWrap = new CallBackWrap();
        callBackWrap.observer = observer;
        callBackWrap.observableTag = observableTag;
        return callBackWrap;
    }
}
