package com.immomo.mmui.databinding.utils.vmParse;

/**
 * Created by wang.yang on 2020/8/14.
 * 保存字段相关信息
 */
public class BoundField {
    private final Class<?> type;
    // 是否可以序列化
    private final boolean serialized;
    // 是否可以反序列化
    private final boolean deserialized;

    protected BoundField(Class<?> type, boolean serialized, boolean deserialized) {
        this.type = type;
        this.serialized = serialized;
        this.deserialized = deserialized;
    }

    public Class<?> getType() {
        return type;
    }

    public boolean isSerialized() {
        return serialized;
    }

    public boolean isDeserialized() {
        return deserialized;
    }
}
