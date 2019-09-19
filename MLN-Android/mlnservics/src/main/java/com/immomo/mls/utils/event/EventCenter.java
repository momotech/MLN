/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.event;

import androidx.annotation.NonNull;

import com.immomo.mls.fun.java.Event;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public class EventCenter {
    private static volatile EventCenter instance;

    public static EventCenter getInstance() {
        if (instance == null) {
            synchronized (EventCenter.class) {
                if (instance == null) {
                    instance = new EventCenter();
                }
            }
        }
        return instance;
    }

    private final Map<Object, Map<String, EventListener>> envListeners;

    private EventCenter() {
        envListeners = new HashMap<>();
    }

    //<editor-fold desc="API">
    public EventListener addEventListener(@NonNull Object env, @NonNull String eventKey, @NonNull EventListener listener) {
        Map<String, EventListener> lis = envListeners.get(env);
        if (lis == null) {
            lis = new HashMap<>();
            envListeners.put(env, lis);
        }
        return lis.put(eventKey, listener);
    }

    public EventListener removeEventListener(@NonNull Object env, @NonNull String eventKey) {
        Map<String, EventListener> lis = envListeners.get(env);
        if (lis != null) {
            EventListener r = lis.remove(eventKey);
            if (lis.isEmpty()) {
                envListeners.remove(env);
            }
            return r;
        }
        return null;
    }

    public void clear(@NonNull Object env) {
        if (env == null) {
            for (Map.Entry<Object, Map<String, EventListener>> e : envListeners.entrySet()) {
                e.getValue().clear();
            }
            envListeners.clear();
        } else {
            Map<String, EventListener> lis = envListeners.remove(env);
            if (lis != null) {
                lis.clear();
            }
        }
    }

    public void postEvent(@NonNull Object env, @NonNull Event e) {
        if (!e.valid())
            throw new IllegalArgumentException("Invalid Event " + e);
        postEventImpl(env, e);
    }
    //</editor-fold>

    private void postEventImpl(Object env, Event e) {
        Map<String, EventListener> lis = envListeners.get(env);
        if (lis == null)
            return;
        if (lis.isEmpty())
            return;
        EventListener listener = lis.get(e.getKey());
        if (listener == null)
            return;
        listener.onEventReceive(e);
    }
}