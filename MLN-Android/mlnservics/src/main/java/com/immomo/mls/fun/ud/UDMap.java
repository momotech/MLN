/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import androidx.collection.ArrayMap;

import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/31.
 * <p>
 * native存储native对象，lua get时转换成lua对象
 * java -jar mlncgen.jar -module mlnservics -class com.immomo.mls.fun.ud.UDMap -jni mln/bridge -name mmmap.c
 */
@LuaApiUsed
public class UDMap extends LuaUserdata<Map> {
    public static final String LUA_CLASS_NAME = "Map";
    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDMap(long L) {
        super(L, null);
        javaUserdata = new HashMap(10);
    }

    @CGenerate
    @LuaApiUsed
    protected UDMap(long L, int init) {
        super(L, null);
        javaUserdata = new HashMap(init);
    }

    public UDMap(Globals g, Object jud) {
        super(g, null);
        if (jud == null) {
            javaUserdata = new ArrayMap(0);
        } else {
            javaUserdata = (Map) jud;
        }
    }

    protected Object toNative(LuaValue v) {
        if (v == null || v.isNil())
            return null;
        if (v instanceof UDView)
            return v;
        if (v.isTable())
            return ConvertUtils.toMap(v.toLuaTable());
        return v.toUserdata().getJavaUserdata();
    }

    protected Object double2Obj(double d) {
        if (d == (int) d) {
            return (int) d;
        }
        if (d == (long) d)
            return (long) d;
        return d;
    }
    //<editor-fold desc="API">

    @LuaApiUsed
    public void put(String k, boolean v) {
        javaUserdata.put(k, v);
    }

    @LuaApiUsed
    public void put(String k, double v) {
        javaUserdata.put(k, double2Obj(v));
    }

    @LuaApiUsed
    public void put(String k, String v) {
        javaUserdata.put(k, v);
    }

    @LuaApiUsed
    public void put(String k, LuaValue v) {
        javaUserdata.put(k, toNative(v));
    }

    @LuaApiUsed
    public void put(double k, boolean v) {
        javaUserdata.put(double2Obj(k), v);
    }

    @LuaApiUsed
    public void put(double k, double v) {
        javaUserdata.put(double2Obj(k), double2Obj(v));
    }

    @LuaApiUsed
    public void put(double k, String v) {
        javaUserdata.put(double2Obj(k), v);
    }

    @LuaApiUsed
    public void put(double k, LuaValue v) {
        javaUserdata.put(double2Obj(k), toNative(v));
    }

    @LuaApiUsed
    public void put(LuaValue k, LuaValue v) {
        javaUserdata.put(k, toNative(v));
    }

    @LuaApiUsed
    public void putAll(UDMap map) {
        javaUserdata.putAll(map.javaUserdata);
    }

    @LuaApiUsed
    public void remove(String k) {
        javaUserdata.remove(k);
    }

    @LuaApiUsed
    public void remove(double k) {
        javaUserdata.remove(double2Obj(k));
    }

    @LuaApiUsed
    public void remove(LuaValue k) {
        javaUserdata.remove(toNative(k));
    }

    @LuaApiUsed
    public void removeAll() {
        javaUserdata.clear();
    }

    @LuaApiUsed
    public LuaValue get(String k) {
        return ConvertUtils.toLuaValue(getGlobals(), javaUserdata.get(k));
    }

    @LuaApiUsed
    public LuaValue get(double k) {
        return ConvertUtils.toLuaValue(getGlobals(), javaUserdata.get(double2Obj(k)));
    }

    @LuaApiUsed
    public LuaValue get(LuaValue k) {
        return ConvertUtils.toLuaValue(getGlobals(), javaUserdata.get(toNative(k)));
    }

    @LuaApiUsed
    public int size() {
        return javaUserdata.size();
    }

    @LuaApiUsed
    public UDArray allKeys() {
        return new UDArray(getGlobals(), javaUserdata.keySet());
    }

    @LuaApiUsed
    public void removeObjects(UDArray arr) {
        List list = arr != null ? arr.getJavaUserdata() : null;
        if (list != null) {
            for (Object key : list) {
                javaUserdata.remove(key);
            }
        }
    }
    //</editor-fold>

    @Override
    public String toString() {
        return javaUserdata.toString();
    }
    //</editor-fold>

    public Map getMap() {
        return javaUserdata;
    }

    public static final ILuaValueGetter<UDMap, Map> G = new ILuaValueGetter<UDMap, Map>() {
        @Override
        public UDMap newInstance(Globals g, Map obj) {
            return new UDMap(g, obj);
        }
    };

    public static final IJavaObjectGetter<LuaValue, Map> J = new IJavaObjectGetter<LuaValue, Map>() {
        @Override
        public Map getJavaObject(LuaValue lv) {
            if (lv.isTable())
                return ConvertUtils.toMap((LuaTable) lv);

            return ((UDMap) lv).getMap();
        }
    };
}