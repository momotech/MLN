/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.core;


import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Choreographer;

import com.immomo.mmui.databinding.bean.WatchCallBack;


import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/7/24 下午2:49
 */
public class PropertyCallBackHandler implements Choreographer.FrameCallback {

    private ArrayList<WatchCallBack> callBacks = new ArrayList<>();
    public final static ThreadLocal<PropertyCallBackHandler> callBackHandler = new ThreadLocal<>();
    private Handler handler;

    public static PropertyCallBackHandler getInstance() {
        if (callBackHandler.get() == null) {
            callBackHandler.set(new PropertyCallBackHandler());
        }
        return callBackHandler.get();
    }

    private PropertyCallBackHandler() {
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void doFrame(long frameTimeNanos) {
        doCallBackFrame();

    }


    /**
     * 统一处理callBack
     */
    private void doCallBackFrame() {
        List<WatchCallBack> commitCallBacks = (List<WatchCallBack>) callBacks.clone();
        for (WatchCallBack watchCallBack : commitCallBacks) {
            watchCallBack.getiPropertyCallback().callBack(watchCallBack.getOlder(), watchCallBack.getNewer());
        }
        callBacks.removeAll(commitCallBacks);
        if (callBacks.size() > 0) {
            Choreographer.getInstance().postFrameCallback(this);
        } else {
            Choreographer.getInstance().removeFrameCallback(this);
        }
    }

    /**
     * 添加CallBack
     *
     * @param watchCallBack
     */
    public void addCallBack(WatchCallBack watchCallBack) {
        if (callBacks.size() == 0) {
            Choreographer.getInstance().postFrameCallback(this);
        }

        if (callBacks.contains(watchCallBack)) {
            callBacks.remove(watchCallBack);
        }

        callBacks.add(watchCallBack);
    }

}
