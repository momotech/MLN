/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.java.Event;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.event.EventCenter;
import com.immomo.mls.utils.event.EventListener;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
@LuaClass(name = "EventCenter", isSingleton = true)
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
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "eventKey", value = String.class),
                    @LuaBridge.Type(value = Function1.class, typeArgs = {Map.class, Unit.class})})
    })
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