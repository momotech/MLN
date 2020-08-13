/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.core;


import android.view.Choreographer;

import com.immomo.mmui.databinding.bean.WatchCallBack;


import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/7/24 下午2:49
 */
public class PropertyCallBackHandler implements Choreographer.FrameCallback {

    private List<WatchCallBack> callBacks = new ArrayList<>();
    public final static ThreadLocal<PropertyCallBackHandler> callBackHandler = new ThreadLocal<>();

    public static PropertyCallBackHandler getInstance() {
        if (callBackHandler.get() == null) {
            callBackHandler.set(new PropertyCallBackHandler());
        }
        return callBackHandler.get();
    }

    private PropertyCallBackHandler() {}

    @Override
    public void doFrame(long frameTimeNanos) {
        doCallBackFrame();
        if (callBacks.size() > 0) {
            Choreographer.getInstance().postFrameCallback(this);
        }
    }

    /**
     * 统一处理callBack
     */
    private void doCallBackFrame() {
        for (WatchCallBack watchCallBack : callBacks) {
            watchCallBack.getiPropertyCallback().callBack(watchCallBack.getOlder(), watchCallBack.getNewer());
        }
        callBacks.clear();
    }

    /**
     * 添加CallBack
     *
     * @param watchCallBack
     */
    public void addCallBack(WatchCallBack watchCallBack) {
        if(callBacks.size() ==0) {
            Choreographer.getInstance().postFrameCallback(this);
        }

        if (callBacks.contains(watchCallBack)) {
            callBacks.remove(watchCallBack);
        }

        callBacks.add(watchCallBack);
    }

}
