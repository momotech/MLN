package com.mln.demo.mln;

import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.utils.LVCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public class MLSGlobalEventImpl implements MLSGlobalEventAdapter {
    private static final String TAG = "MLSGlobalEventImpl";
    private SubscriberImpl subscriber;

    public MLSGlobalEventImpl() {
        subscriber = new SubscriberImpl();
        GlobalEventManager.getInstance().register(subscriber, "lua");
    }

    @Override
    public void addEventListener(String event, LVCallback callback) {
        subscriber.add(event, callback);
    }

    @Override
    public void addListener(String event, LVCallback callback) {
        subscriber.addNew(event, callback);
    }

    @Override
    public void postEvent(String event, String[] env, Map msg) {
        try {
            GlobalEventManager.getInstance().sendEvent(new GlobalEventManager.Event(event).src("lua").dst(env).msg(msg));
        } catch (Exception e) {
        }
    }

    @Override
    public void removeEventListener(String event, LVCallback... callback) {
        if (callback == null || callback.length == 0) {
            subscriber.remove(event);
            return;
        }
        for (LVCallback c : callback) {
            if (c == null)
                continue;
            subscriber.remove(event, c);
        }
    }

    @Override
    public void clearEventListener() {
        subscriber.clear();
    }

    private static class SubscriberImpl implements GlobalEventManager.Subscriber {
        final HashMap<String, List<LVCallback>> events = new HashMap<>();
        final HashMap<String, List<LVCallback>> newEvents = new HashMap<>();

        @Override
        public void onGlobalEventReceived(GlobalEventManager.Event event) {
            String name = event.getName();
            List<LVCallback> callbacks = events.get(name);
            if (callbacks != null) {
                Map<String, Object> msg = event.getMsg();
                for (LVCallback c : callbacks) {
                    c.call(msg);
                }
            }
            callbacks = newEvents.get(name);
            if (callbacks != null) {
                Map<String, Object> m = event.toMap();
                for (LVCallback c : callbacks) {
                    c.call(m);
                }
            }
        }

        void add(String event, LVCallback callback) {
            List<LVCallback> cs = events.get(event);
            if (cs == null) {
                cs = new ArrayList<>();
                events.put(event, cs);
                cs.add(callback);
                return;
            }
            if (!cs.contains(callback))
                cs.add(callback);
        }

        void addNew(String event, LVCallback callback) {
            List<LVCallback> cs = newEvents.get(event);
            if (cs == null) {
                cs = new ArrayList<>();
                newEvents.put(event, cs);
                cs.add(callback);
                return;
            }
            if (!cs.contains(callback))
                cs.add(callback);
        }

        void remove(String event) {
            events.remove(event);
            newEvents.remove(event);
        }

        void remove(String event, LVCallback c) {
            List<LVCallback> callbacks = events.get(event);
            if (callbacks != null) {
                callbacks.remove(c);
                if (callbacks.isEmpty())
                    events.remove(event);
            }
            callbacks = newEvents.get(event);
            if (callbacks != null) {
                callbacks.remove(c);
                if (callbacks.isEmpty())
                    newEvents.remove(event);
            }
        }

        void clear() {
            events.clear();
            newEvents.clear();
        }
    }
}
