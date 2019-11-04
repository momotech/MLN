package com.immomo.mls.fun.ud;


import com.immomo.mls.MLSEngine;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/7/31.
 * <p>
 * native存储native对象，lua get时转换成lua对象
 */
@LuaApiUsed
public class UDArray extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "Array";
    public static final String[] methods = new String[]{
            "add",
            "addAll",
            "remove",
            "removeObjects",
            "removeObject",
            "removeAll",
            "get",
            "insert",
            "replace",
            "size",
            "contains",
            "insertObjects",
            "exchange",
            "removeObjectsAtRange",
            "replaceObjects",
            "subArray",
            "copyArray",
    };

    private final List array;

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
            return ((UDArray) lv).array;
        }
    };

    /**
     * 由java层创建
     *
     * @param g   虚拟机信息
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDArray(Globals g, Collection jud) {
        super(g, jud);
        if (jud instanceof List) {
            this.array = (List) jud;
        } else if (jud != null) {
            this.array = new ArrayList(jud);
        } else {
            this.array = new ArrayList(0);
        }
        javaUserdata = this.array;
    }

    /**
     * 必须有传入long和LuaValue[]的构造方法，且不可混淆
     * 由native创建
     * <p>
     * 子类可在此构造函数中初始化{@link #javaUserdata}
     * <p>
     * 必须有此构造方法！！！！！！！！
     *
     * @param L 虚拟机地址
     * @param v lua脚本传入的构造参数
     */
    @LuaApiUsed
    protected UDArray(long L, LuaValue[] v) {
        super(L, null);
        int init = 10;
        if (v != null && v.length >= 1) {
            if (v[0].isNumber()) {
                init = v[0].toInt();
            }
        }
        array = new ArrayList<>(init);
        javaUserdata = array;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] add(LuaValue[] v) {
        array.add(ConvertUtils.toNativeValue(v[0]));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] addAll(LuaValue[] v) {
        this.array.addAll(((UDArray) v[0]).array);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] remove(LuaValue[] v) {
        this.array.remove(v[0].toInt() - 1);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeObjects(LuaValue[] v) {
        this.array.removeAll(((UDArray) v[0]).array);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeObject(LuaValue[] v) {
        Object object = ConvertUtils.toNativeValue(v[0]);
        if (array.contains(object)) {
            this.array.remove(object);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeAll(LuaValue[] v) {
        array.clear();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] get(LuaValue[] v) {
        int index = v[0].toInt() - 1;
        if (index < 0 || index >= array.size()) {
            ErrorUtils.debugLuaError("The index out of range!",globals);
            return rNil();
        }
        return varargsOf(ConvertUtils.toLuaValue(getGlobals(), array.get(index)));
    }

    @LuaApiUsed
    public LuaValue[] insert(LuaValue[] var) {
        int index = var[0].toInt() - 1;
        array.add(index, ConvertUtils.toNativeValue(var[1]));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] replace(LuaValue[] var) {
        int index = var[0].toInt() - 1;
        array.set(index, ConvertUtils.toNativeValue(var[1]));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] size(LuaValue[] v) {
        return varargsOf(LuaNumber.valueOf(array.size()));
    }

    @LuaApiUsed
    public LuaValue[] contains(LuaValue[] v) {
        return array.contains(ConvertUtils.toNativeValue(v[0])) ? rTrue() : rFalse();
    }

    @LuaApiUsed
    public LuaValue[] insertObjects(LuaValue[] v) {
        int index = v[0].toInt() - 1;
        UDArray arr = (UDArray) v[1];
        array.addAll(index, arr.array);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] exchange(LuaValue[] v) {
        int aindex = v[0].toInt() - 1;
        int bindex = v[1].toInt() - 1;
        Object aobj = array.get(aindex);
        Object bobj = array.get(bindex);
        array.set(aindex, bobj);
        array.set(bindex, aobj);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeObjectsAtRange(LuaValue[] v) {
        int fromIdx = v[0].toInt() - 1;
        int toIdx = v[1].toInt() - 1;

        if ((fromIdx >= array.size() || toIdx >= array.size()) && MLSEngine.DEBUG)
            throw new IndexOutOfBoundsException("removeObjectsAtRange from = " + fromIdx + "  to =" + toIdx + " , more than source array length: " + array.size());

        int index = fromIdx;
        while (index <= toIdx) {
            array.remove(fromIdx);
            index++;
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] replaceObjects(LuaValue[] v) {
        int fromIdx = v[0].toInt() - 1;
        UDArray arr = (UDArray) v[1];
        List src = arr.array;
        int len = src.size();
        if (fromIdx + len > array.size()) {
            throw new IndexOutOfBoundsException("replace from " + fromIdx + " and length " + len + ", more than source array length: " + array.size());
        }
        for (int i = 0; i < len ;i ++) {
            array.set(i + fromIdx, src.get(i));
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] subArray(LuaValue[] v) {
        int from = v[0].toInt() - 1;
        int to = v[1].toInt();

        if (((from > to) || (to > array.size() || from < 0)) && MLSEngine.DEBUG)
            throw new IndexOutOfBoundsException("subArray from = " + from + "  to =" + to + " ,  illegal arguments ");

        List subArray = array.subList(from, to);
        return varargsOf(new UDArray(getGlobals(), subArray));
    }

    @LuaApiUsed
    public LuaValue[] copyArray(LuaValue[] v) {
        List copyArray = new ArrayList(array);
        return varargsOf(new UDArray(getGlobals(), copyArray));
    }

    //</editor-fold>

    //<editor-fold desc="override">
    @Override
    @LuaApiUsed
    public String toString() {
        return array.toString();
    }
    //</editor-fold>

    public List getArray() {
        return array;
    }
}
