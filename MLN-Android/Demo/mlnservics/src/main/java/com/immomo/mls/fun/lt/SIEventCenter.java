package com.immomo.mls.fun.lt;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.java.Event;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.event.EventCenter;
import com.immomo.mls.utils.event.EventListener;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
@LuaClass
public class SIEventCenter {
    public static final String LUA_CLASS_NAME = "EventCenter";

    private Globals globals;

    public SIEventCenter(Globals globals, LuaValue[] init) {
        this.globals = globals;
    }

    public void __onLuaGc() {
        EventCenter.getInstance().clear(globals);
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void addEventListener(String eventKey, LVCallback callback) {
        addEventImpl(eventKey, callback);
    }

    @Deprecated
    @LuaBridge
    public void reomoveEventListener(String eventKey) {
        removeEventImpl(eventKey);
    }

    @LuaBridge
    public void removeEventListener(String eventKey) {
        removeEventImpl(eventKey);
    }

    @LuaBridge
    public void postEvent(Event e) {
        sendEventImpl(e);
    }
    //</editor-fold>

    private void sendEventImpl(Event e) {
        EventCenter.getInstance().postEvent(globals, e);
    }

    private void removeEventImpl(String key) {
        EventListener l = EventCenter.getInstance().removeEventListener(globals, key);
        if (l instanceof EventListenerAdapter) {
            ((EventListenerAdapter) l).callback.destroy();
        }
    }

    private void addEventImpl(String key, LVCallback callback) {
        EventListener l = EventCenter.getInstance().addEventListener(globals, key, new EventListenerAdapter(callback));
        if (l instanceof EventListenerAdapter) {
            ((EventListenerAdapter) l).callback.destroy();
        }
    }

    private static final class EventListenerAdapter implements EventListener {
        final LVCallback callback;

        EventListenerAdapter(LVCallback callback) {
            this.callback = callback;
        }

        @Override
        public void onEventReceive(Event event) {
            callback.call(event);
        }
    }
}
