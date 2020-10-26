/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020/9/3
 * java -jar mlncgen.jar -module mlnservics -class com.immomo.mls.fun.ud.UDArray -jni mln/bridge -name mmarray.c
 */
@LuaApiUsed
public class UDArray extends LuaUserdata<List> {
    public static final String LUA_CLASS_NAME = "Array";

    public UDArray(Globals g, List jud) {
        super(g, jud);
    }

    public UDArray(Globals g, Collection jud) {
        super(g, null);
        if (jud instanceof List) {
            javaUserdata = (List) jud;
        } else if (jud != null) {
            javaUserdata = new ArrayList<>(jud);
        } else {
            javaUserdata = new ArrayList<>(0);
        }
    }

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDArray(long L) {
        super(L, null);
        javaUserdata = new ArrayList(10);
    }

    @CGenerate
    @LuaApiUsed
    protected UDArray(long L, int init) {
        super(L, null);
        javaUserdata = new ArrayList<>(init);
    }
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

    public List getArray() {
        return javaUserdata;
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

    @LuaApiUsed
    public void add(boolean b) {
        javaUserdata.add(b);
    }

    @LuaApiUsed
    public void add(double num) {
        javaUserdata.add(double2Obj(num));
    }

    @LuaApiUsed
    public void add(String s) {
        javaUserdata.add(s);
    }

    @LuaApiUsed
    public void add(LuaValue v) {
        javaUserdata.add(toNative(v));
    }

    @LuaApiUsed
    public void addAll(UDArray arr) {
        javaUserdata.addAll(arr.javaUserdata);
    }

    @LuaApiUsed
    public void remove(int index) {
        javaUserdata.remove(index - 1);
    }

    @LuaApiUsed
    public void removeObject(double n) {
        javaUserdata.remove(double2Obj(n));
    }

    @LuaApiUsed
    public void removeObject(boolean b) {
        javaUserdata.remove(b);
    }

    @LuaApiUsed
    public void removeObject(String s) {
        javaUserdata.remove(s);
    }

    @LuaApiUsed
    public void removeObject(LuaValue v) {
        javaUserdata.remove(toNative(v));
    }

    @LuaApiUsed
    public void removeObjects(UDArray arr) {
        javaUserdata.removeAll(arr.javaUserdata);
    }

    @LuaApiUsed
    public void removeObjectsAtRange(int from, int to) {
        from--;
        to--;

        if ((from >= javaUserdata.size() || to >= javaUserdata.size()) && MLSEngine.DEBUG)
            throw new IndexOutOfBoundsException("removeObjectsAtRange from = " + from + "  to =" + to +
                    " , more than source array length: " + javaUserdata.size());

        int index = from;
        while (index <= to) {
            javaUserdata.remove(from);
            index++;
        }
    }

    @LuaApiUsed
    public void removeAll() {
        javaUserdata.clear();
    }

    @LuaApiUsed
    public LuaValue get(int index) {
        index--;
        if (index < 0 || index >= javaUserdata.size()) {
            ErrorUtils.debugLuaError("The index out of range!", globals);
            return null;
        }
        return ConvertUtils.toLuaValue(getGlobals(), javaUserdata.get(index));
    }

    @LuaApiUsed
    public int size() {
        return javaUserdata.size();
    }

    @LuaApiUsed
    public boolean contains(double n) {
        return javaUserdata.contains(double2Obj(n));
    }

    @LuaApiUsed
    public boolean contains(boolean b) {
        return javaUserdata.contains(b);
    }

    @LuaApiUsed
    public boolean contains(String s) {
        return javaUserdata.contains(s);
    }

    @LuaApiUsed
    public boolean contains(LuaValue v) {
        return javaUserdata.contains(toNative(v));
    }

    @LuaApiUsed
    public void insert(int idx, double n) {
        javaUserdata.add(idx - 1, double2Obj(n));
    }

    @LuaApiUsed
    public void insert(int idx, boolean b) {
        javaUserdata.add(idx - 1, b);
    }

    @LuaApiUsed
    public void insert(int idx, String s) {
        javaUserdata.add(idx - 1, s);
    }

    @LuaApiUsed
    public void insert(int idx, LuaValue v) {
        javaUserdata.add(idx - 1, toNative(v));
    }

    @LuaApiUsed
    public void insertObjects(int idx, UDArray arr) {
        idx --;
        javaUserdata.addAll(idx, arr.javaUserdata);
    }

    @LuaApiUsed
    public void replace(int idx, double n) {
        javaUserdata.set(idx - 1, double2Obj(n));
    }

    @LuaApiUsed
    public void replace(int idx, boolean n) {
        javaUserdata.set(idx - 1, n);
    }

    @LuaApiUsed
    public void replace(int idx, String s) {
        javaUserdata.set(idx - 1, s);
    }

    @LuaApiUsed
    public void replace(int idx, LuaValue v) {
        javaUserdata.set(idx - 1, toNative(v));
    }

    @LuaApiUsed
    public void replaceObjects(int idx, UDArray arr) {
        idx --;
        List src = arr.javaUserdata;
        int len = src.size();
        if (idx + len > javaUserdata.size()) {
            throw new IndexOutOfBoundsException("replace from " + idx + " and length " + len +
                    ", more than source array length: " + javaUserdata.size());
        }
        for (int i = 0; i < len ;i ++) {
            javaUserdata.set(i + idx, src.get(i));
        }
    }

    protected Object double2Obj(double d) {
        if (d == (int) d) {
            return (int) d;
        }
        if (d == (long) d)
            return (long) d;
        return d;
    }

    @LuaApiUsed
    public void exchange(int idx, int idx2) {
        idx --;
        idx2 --;
        Object aobj = javaUserdata.get(idx);
        Object bobj = javaUserdata.get(idx2);
        javaUserdata.set(idx, bobj);
        javaUserdata.set(idx2, aobj);
    }

    @LuaApiUsed
    public UDArray subArray(int from, int to) {
        from --;

        if (((from > to) || (to > javaUserdata.size() || from < 0)) && MLSEngine.DEBUG)
            throw new IndexOutOfBoundsException("subArray from = " + from + "  to =" + to + " ,  illegal arguments ");

        List subArray = javaUserdata.subList(from, to);
        return new UDArray(getGlobals(), subArray);
    }

    @LuaApiUsed
    public UDArray copyArray() {
        return new UDArray(getGlobals(), new ArrayList(javaUserdata));
    }

    @Override
    public String toString() {
        return javaUserdata.toString();
    }

    public static final ILuaValueGetter<UDArray, List> G = new ILuaValueGetter<UDArray, List>() {
        @Override
        public UDArray newInstance(Globals g, List obj) {
            return new UDArray(g, obj);
        }
    };

    public static final IJavaObjectGetter<LuaValue, List> J = new IJavaObjectGetter<LuaValue, List>() {
        @Override
        public List getJavaObject(LuaValue lv) {
            if (lv.isTable())
                return ConvertUtils.toList(lv.toLuaTable());
            return ((UDArray) lv).javaUserdata;
        }
    };
}