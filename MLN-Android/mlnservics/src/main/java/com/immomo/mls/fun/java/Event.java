/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.java;

import android.text.TextUtils;

import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
@LuaClass
public class Event {
    public static final String LUA_CLASS_NAME = "Event";

    private int type;
    private String producerId;
    private Map info;
    private String key;

    public Event() {}

    public Event(Globals g, LuaValue[] init) {

    }

    //<editor-fold desc="API">
    @LuaBridge(alias = "type", type = BridgeType.GETTER)
    public int getType() {
        return type;
    }

    @LuaBridge(alias = "type", type = BridgeType.SETTER)
    public void setType(int type) {
        this.type = type;
    }

    @LuaBridge(alias = "producerId", type = BridgeType.GETTER)
    public String getProducerId() {
        return producerId;
    }

    @LuaBridge(alias = "producerId", type = BridgeType.SETTER)
    public void setProducerId(String producerId) {
        this.producerId = producerId;
    }

    @LuaBridge(alias = "info", type = BridgeType.GETTER)
    public Map getInfo() {
        return info;
    }

    @LuaBridge(alias = "info", type = BridgeType.SETTER)
    public void setInfo(Map info) {
        this.info = info;
    }

    @LuaBridge(alias = "key", type = BridgeType.GETTER)
    public String getKey() {
        return key;
    }

    @LuaBridge(alias = "key", type = BridgeType.SETTER)
    public void setKey(String key) {
        this.key = key;
    }
    //</editor-fold>

    public boolean valid() {
        return !TextUtils.isEmpty(key);
    }

    @Override
    public String toString() {
        return "Event{" +
                "type=" + type +
                ", producerId=" + producerId +
                ", info=" + info +
                ", key='" + key + '\'' +
                '}';
    }
}