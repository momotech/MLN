package com.immomo.mls.lite;

import com.immomo.mls.lite.data.LuaClientRecyclerViewPool;
import com.immomo.mls.lite.data.UserdataType;
import com.immomo.mls.lite.interceptor.EngineInitCheckInterceptor;
import com.immomo.mls.lite.interceptor.ExceptionInterceptor;
import com.immomo.mls.lite.interceptor.Interceptor;
import com.immomo.mls.lite.interceptor.ScriptLoadExceptionInterceptor;
import com.immomo.mls.lite.interceptor.StopWatchInterceptor;
import com.immomo.mls.wrapper.ScriptBundle;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.recyclerview.widget.RecyclerView;

/**
 * @author jidongdong
 * <p>
 * 轻量级加载lua视图的客户端 一个客户端 只能绑定一次lifecycle
 * @date 2022-01-04 18:06:57
 */
public class LuaClient implements Call.Factory, LifecycleEventObserver {
    public static final String TAG = "LuaClient";
    final Dispatcher dispatcher;


    /**
     * errorview interceptor 预埋包加载异常 最顶级拦截器
     */
    final Interceptor errorViewInterceptor;
    /**
     * errorCatchInterceptors 处理异常 或者监测执行时间的拦截器 需优先加载
     */
    final List<Interceptor> errorCatchInterceptors;

    /**
     * preProcessorInterceptors 预处理 参数配置等处理
     */
    final List<Interceptor> preProcessorInterceptors;
    /*
     *resourceProcessorInterceptors 资源加载的拦截器
     */
    final List<Interceptor> resourceProcessorInterceptors;

    /*
     *other interceptors 介于资源加载和正式执行的中间层的拦截器
     */
    final List<Interceptor> middlewareInterceptors;
    /**
     * 定制化Userdata注入
     */
    final List<Interceptor> customUserdataInjectInterceptors;

    final LifecycleOwner lifecycleOwner;
    private final EventListener.Factory eventListenerFactory;
    /**
     * 是否从PreGlobalInitUtils中取全量bridge的虚拟机 默认为true
     */
    private UserdataType userdataType = UserdataType.ONLY_FULL;

    public Dispatcher dispatcher() {
        return dispatcher;
    }

    public LuaClient(Builder builder, LifecycleOwner owner) {
        this.dispatcher = builder.dispatcher;
        this.lifecycleOwner = owner;
        this.lifecycleOwner.getLifecycle().addObserver(this);
        this.errorViewInterceptor = builder.errorViewInterceptor;
        this.eventListenerFactory = builder.eventListenerFactory;
        this.userdataType = builder.userdataType;
        this.customUserdataInjectInterceptors = builder.customUserdataInjectInterceptors;
        this.errorCatchInterceptors = Collections.unmodifiableList(new ArrayList<>(builder.errorCatchInterceptors()));
        this.preProcessorInterceptors = Collections.unmodifiableList(new ArrayList<>(builder.preProcessorInterceptors()));
        this.resourceProcessorInterceptors = Collections.unmodifiableList(new ArrayList<>(builder.resourceProcessorInterceptors()));
        this.middlewareInterceptors = Collections.unmodifiableList(new ArrayList<>(builder.middlewareInterceptors()));
    }

    public Interceptor errorViewInterceptor() {
        return errorViewInterceptor;
    }

    public List<Interceptor> customUserdataInjectInterceptors() {
        return customUserdataInjectInterceptors;
    }

    public List<Interceptor> errorCatchInterceptors() {
        return errorCatchInterceptors;
    }

    public List<Interceptor> preProcessorInterceptors() {
        return preProcessorInterceptors;
    }


    public List<Interceptor> resourceProcessorInterceptors() {
        return resourceProcessorInterceptors;
    }

    public List<Interceptor> middlewareInterceptors() {
        return middlewareInterceptors;
    }

    public EventListener.Factory eventListenerFactory() {
        return eventListenerFactory;
    }

    public UserdataType userdataType() {
        return userdataType;
    }

    @Override
    public Call newCall(ScriptBundle request) {
        request.setTag(lifecycleOwner);
        return RealCall.newRealCall(this, request);
    }


    public Builder newBuilder() {
        return new Builder(this);
    }

    @Override
    public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
        if (event == Lifecycle.Event.ON_RESUME) {
            dispatcher().resume(lifecycleOwner);
        } else if (event == Lifecycle.Event.ON_PAUSE) {
            dispatcher().pause(lifecycleOwner);
        } else if (event == Lifecycle.Event.ON_DESTROY) {
            dispatcher().cancelAll(lifecycleOwner);
        }
    }

    public static final class Builder {
        Interceptor errorViewInterceptor = new ExceptionInterceptor();
        final List<Interceptor> errorCatchInterceptors = new ArrayList<>();
        final List<Interceptor> preProcessorInterceptors = new ArrayList<>();
        final List<Interceptor> resourceProcessorInterceptors = new ArrayList<>();
        final List<Interceptor> middlewareInterceptors = new ArrayList<>();
        final List<Interceptor> customUserdataInjectInterceptors = new ArrayList<>();
        Dispatcher dispatcher;
        RecyclerView recyclerView;
        EventListener.Factory eventListenerFactory;
        int maxRecycledViews = 5;
        /**
         * 是否从PreGlobalInitUtils中取全量bridge的虚拟机 默认为true
         */
        UserdataType userdataType = UserdataType.ONLY_FULL;

        public Builder() {
            dispatcher = new Dispatcher();
            eventListenerFactory = EventListener.factory(EventListener.NONE);
        }

        public List<Interceptor> errorCatchInterceptors() {
            return errorCatchInterceptors;

        }

        public List<Interceptor> preProcessorInterceptors() {
            return preProcessorInterceptors;
        }

        public List<Interceptor> resourceProcessorInterceptors() {
            return resourceProcessorInterceptors;
        }

        public List<Interceptor> middlewareInterceptors() {
            return middlewareInterceptors;
        }

        /**
         * To adjust an existing client before making a request
         *
         * @param client 初始化luaView的客户机
         */
        Builder(LuaClient client) {
            this.dispatcher = client.dispatcher();
            this.errorViewInterceptor = client.errorViewInterceptor;
            this.customUserdataInjectInterceptors.addAll(client.customUserdataInjectInterceptors);
            this.errorCatchInterceptors.addAll(client.errorCatchInterceptors);
            this.preProcessorInterceptors.addAll(client.preProcessorInterceptors);
            this.resourceProcessorInterceptors.addAll(client.resourceProcessorInterceptors);
            this.middlewareInterceptors.addAll(client.middlewareInterceptors);
            this.eventListenerFactory = client.eventListenerFactory;
            this.userdataType = client.userdataType;
        }

        public Builder addErrorCatchInterceptor(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            errorCatchInterceptors.add(interceptor);
            if (resourceProcessorInterceptors.size() > 0)
                throw new IllegalArgumentException("addErrorCatchInterceptor must before addResourceProcessorInterceptor");
            return this;
        }

        public Builder addErrorViewInterceptor(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            errorViewInterceptor = interceptor;
            return this;
        }

        public Builder addPreProcessorInterceptor(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            preProcessorInterceptors.add(interceptor);
            return this;
        }

        public Builder addCustomUserDataInjectInterceptor(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            customUserdataInjectInterceptors.add(interceptor);
            return this;
        }

        public Builder addResourceProcessorInterceptor(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            resourceProcessorInterceptors.add(interceptor);
            return this;
        }

        public Builder addMiddlewareInterceptors(Interceptor interceptor) {
            if (interceptor == null) throw new IllegalArgumentException("interceptor == null");
            middlewareInterceptors.add(interceptor);
            return this;
        }

        public Builder setup(RecyclerView recyclerView, int maxRecycledViews) {
            this.recyclerView = recyclerView;
            this.maxRecycledViews = maxRecycledViews;
            return this;
        }

        public Builder setup(RecyclerView recyclerView) {
            this.recyclerView = recyclerView;
            return this;
        }

        public Builder userdataType(UserdataType userdataType) {
            this.userdataType = userdataType;
            return this;
        }

        /**
         * Configure a single client scoped listener that will receive all analytic events
         * for this client.
         *
         * @see EventListener for semantics and restrictions on listener implementations.
         */
        public Builder eventListener(EventListener eventListener) {
            if (eventListener == null) throw new NullPointerException("eventListener == null");
            this.eventListenerFactory = EventListener.factory(eventListener);
            return this;
        }

        /**
         * Configure a factory to provide per-call scoped listeners that will receive analytic events
         * for this client.
         *
         * @see EventListener for semantics and restrictions on listener implementations.
         */
        public Builder eventListenerFactory(EventListener.Factory eventListenerFactory) {
            if (eventListenerFactory == null) {
                throw new NullPointerException("eventListenerFactory == null");
            }
            this.eventListenerFactory = eventListenerFactory;
            return this;
        }


        public LuaClient build(LifecycleOwner owner) {
            LuaClient luaClient = new LuaClient(this, owner);
            if (recyclerView != null) {
                recyclerView.setRecycledViewPool(new LuaClientRecyclerViewPool(luaClient, maxRecycledViews));
            }
            return luaClient;
        }
    }

    public static Builder newDefaultBuilder() {
        return new Builder()
                .addErrorViewInterceptor(new ExceptionInterceptor())
                .addErrorCatchInterceptor(new EngineInitCheckInterceptor())
                .addErrorCatchInterceptor(new ScriptLoadExceptionInterceptor(2))
                .addErrorCatchInterceptor(new StopWatchInterceptor());
    }
}
