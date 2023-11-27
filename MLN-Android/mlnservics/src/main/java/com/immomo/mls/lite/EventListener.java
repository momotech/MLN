//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.immomo.mls.lite;

import android.util.Log;

public abstract class EventListener {
    public static final EventListener NONE = new EventListener() {
    };

    /**
     * 生命周期监听
     */
    public EventListener() {
    }

    static EventListener.Factory factory(final EventListener listener) {
        return new Factory() {
            @Override
            public EventListener create(Call call) {
                return listener;
            }
        };
    }

    /**
     * 初始化luaView请求开始
     *
     * @param call 请求
     */
    public void callStart(Call call) {
    }

    /**
     * 资源处理开始 默认没有被调用 需要具体业务拦截器自己调用 可能会多次调用
     *
     * @param call 请求
     */
    public void resourceProcessStart(Call call) {
    }

    /**
     * 资源处理结束 默认没有被调用 需要具体业务拦截器自己调用 可能会多次调用
     *
     * @param call 请求
     */
    public void resourceProcessEnd(Call call) {
    }

    /**
     * lua 引擎初始化开始
     *
     * @param call 请求
     */
    public void engineInitStart(Call call) {
    }

    /**
     * lua 引擎初始化结束
     *
     * @param call 请求
     */
    public void engineInitEnd(Call call) {
    }

    /**
     * 桥接注册开始  可能会多次调用
     *
     * @param call 请求
     */
    public void bridgeRegisterStart(Call call) {
    }

    /**
     * 桥接注册结束  可能会多次调用
     *
     * @param call 请求
     */
    public void bridgeRegisterEnd(Call call) {
    }

    /**
     * 脚本执行开始
     *
     * @param call 请求
     */
    public void scriptExecuteStart(Call call) {
    }
    /**
     * 脚本执行结束
     *
     * @param call 请求
     */
    public void scriptExecuteEnd(Call call) {
    }

    /**
     * 整个链路执行结束
     * @param call
     */
    public void callEnd(Call call) {
    }

    /**
     * 脚本执行报错 触发降级策略时触发
     * @param call
     */
    public void scriptLoadFailed(Call call, Exception e) {
    }
    /**
     * 其他报错 触发错误view
     * @param call
     */
    public void callFailed(Call call, Exception e) {
        Log.e("sfsjdfsfsf", "", e);
    }


    public interface Factory {
        EventListener create(Call var1);
    }
}
