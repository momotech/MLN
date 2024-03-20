package com.immomo.mmui.databinding.utils.vmParse;

import org.luaj.vm2.LuaTable;

import java.util.Map;

/**
 * 包含元数据（数据是否更新）的vm数据
 */
public class AutoFillData {

    public final static int DATA_UPDATE = 1;
    public final static int DATA_DEFAULT = 0;

    /**
     * vm转成的原始数据
     */
    Map<String, Object> data;
    /**
     * 模拟lua元表，针对每个table的生成类（map或者list）关联对应的元表生成类（map或者list）具体见{@link AutoFillConvertUtils#toList(LuaTable, Map)} 和 {@link AutoFillConvertUtils#toMap(LuaTable, Map)} }
     */
    Map<Object, Object> update;

    public Map<String, Object> getData() {
        return data;
    }

    public Map<Object, Object> getUpdate() {
        return update;
    }

    public void setData(Map<String, Object> data) {
        this.data = data;
    }

    public void setUpdate(Map<Object, Object> update) {
        this.update = update;
    }
}
