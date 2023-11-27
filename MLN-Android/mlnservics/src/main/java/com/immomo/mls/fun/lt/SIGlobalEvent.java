/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.LVCallback;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
@LuaClass(name = "GlobalEvent", isSingleton = true)
public class SIGlobalEvent {
    public static final String LUA_CLASS_NAME = "GlobalEvent";

    public SIGlobalEvent(Globals globals, LuaValue[] init) {
    }

    public void __onLuaGc() {
        clearGlobalEvent();
    }

    private Map<String, List<LVCallback>> globalEvents;

    //<editor-fold desc="invoke by sdk">
    private void save(String event, LVCallback callback) {
        if (globalEvents == null) {
            globalEvents = new HashMap<>();
        }
        List<LVCallback> callbacks = globalEvents.get(event);
        if (callbacks == null) {
            callbacks = new ArrayList<>();
            globalEvents.put(event, callbacks);
            callbacks.add(callback);
            return;
        }
        if (!callbacks.contains(callback))
            callbacks.add(callback);
    }

    private void remove(String event, LVCallback callback) {
        if (globalEvents == null)
            return;
        List<LVCallback> callbacks = globalEvents.get(event);
        if (callbacks != null) {
            callbacks.remove(callback);
            if (callbacks.isEmpty())
                globalEvents.remove(event);
        }
        callback.destroy();
    }

    private void remove(String event) {
        if (globalEvents == null)
            return;
        List<LVCallback> callbacks = globalEvents.remove(event);
        if (callbacks != null) {
            for (LVCallback c : callbacks) {
                c.destroy();
            }
        }
    }

    private void clearGlobalEvent() {
        if (globalEvents == null || globalEvents.isEmpty())
            return;
        for (Map.Entry<String, List<LVCallback>> entry : globalEvents.entrySet()) {
            String e = entry.getKey();
            List<LVCallback> cs = entry.getValue();
            MLSAdapterContainer.getGlobalEventAdapter().removeEventListener(e, cs.toArray(new LVCallback[cs.size()]));
        }
    }
    //</editor-fold>

    @Deprecated
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "event", value = String.class),
                    @LuaBridge.Type(value = Function1.class, typeArgs = {Map.class, Unit.class})
            })
    })
    public void addEventListener(String event, LVCallback callback) {
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            adapter.addEventListener(event, callback);
            save(event, callback);
        }
    }

    /**
     * 1.0.5 两端实现统一
     *
     * @param event
     * @param callback
     */
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "event", value = String.class),
                    @LuaBridge.Type(value = Function1.class, typeArgs = {Map.class, Unit.class})
            })
    })
    public void addListener(String event, LVCallback callback) {
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            adapter.addListener(event, callback);
            save(event, callback);
        }
    }

    @LuaBridge
    public void postEvent(String event, Map map) {
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            String[] env = null;
            Object e = map.get(MLSGlobalEventAdapter.KEY_DST);
            if (e != null) {
                env = e.toString().split("\\|");
            }
            adapter.postEvent(event, env, (Map) map.get(MLSGlobalEventAdapter.KEY_MSG));
        }
    }

    @LuaBridge
    public void removeEventListener(String event) {
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            adapter.removeEventListener(event);
            remove(event);
        }
    }
}