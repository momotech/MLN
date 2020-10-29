/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;


import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.databinding.utils.BindingConvertUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/8/13 下午7:18
 */
public class FieldCacheHelper {
    private ArrayList<LuaTable> luaValueCache;

    /**
     * 操作缓存luaTable
     * 适用于{@link ObservableMap,ObservableField}
     *
     * @param fieldName
     * @param newer
     */
    public void putField(String fieldName, Object newer) {
        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                luaTable.set(fieldName, BindingConvertUtils.toLuaValue(luaTable.getGlobals(), newer));
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable,针对于ObservableList改变item
     * 使用于{@link ObservableList#set(int, Object)
     *
     * @param index
     * @param newer
     */
    public void setField(int index, Object newer) {
        if (luaValueCache == null) {
            return;
        }
        index++; //LuaTable index 从1开始
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                luaTable.set(index, BindingConvertUtils.toLuaValue(luaTable.getGlobals(), newer));
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList添加
     * 使用于{@link ObservableList#add(Object),ObservableList#add(int, Object)}
     *
     * @param index
     * @param newer
     */
    public void addField(int index, Object newer) {
        if (luaValueCache == null) {
            return;
        }
        index++; //LuaTable index 从1开始
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                LuaTable copy = LuaTable.create(luaTable.getGlobals());
                int size = luaTable.getn();
                for (int i = index; i <= size; i++) {
                    copy.set(i + 1, luaTable.get(i));
                }
                luaTable.set(index, BindingConvertUtils.toLuaValue(luaTable.getGlobals(), newer));
                DisposableIterator<LuaTable.KV> iterator = copy.iterator();
                if (iterator != null) {
                    while (iterator.hasNext()) {
                        LuaTable.KV kv = iterator.next();
                        luaTable.set(kv.key.toInt(), kv.value);
                    }
                    iterator.dispose();
                }
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList添加
     * 使用于{@link ObservableList#addAll(Collection)}
     *
     * @param observableList
     */
    public void addFields(ObservableList observableList) {
        if (observableList == null || observableList.size() == 0) {
            return;
        }

        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (Object object : observableList) {
            for (LuaTable luaTable : luaTables) {
                if (!luaTable.isDestroyed()) {
                    int size = luaTable.getn();
                    luaTable.set(size + 1, BindingConvertUtils.toLuaValue(luaTable.getGlobals(), object));
                } else {
                    luaValueCache.remove(luaTable);
                }
            }
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList添加
     * 使用于{@link ObservableList#addAll(int, Collection)}
     *
     * @param index
     * @param observableList
     */
    public void addFields(int index, ObservableList observableList) {
        if (observableList == null || observableList.size() == 0) {
            return;
        }

        if (luaValueCache == null) {
            return;
        }
        for (Object object : observableList) {
            addField(index, object);
            index++;
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList移除
     * 使用于{@link ObservableList#remove(int),ObservableList#remove(Object)}
     *
     * @param index
     */
    public void removeField(int index) {
        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                luaTable.remove(index +1);
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList移除
     * 适用于{@link ObservableMap#remove(Object)}
     *
     * @param field
     */
    public void removeField(String field) {
        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                luaTable.set(field, LuaValue.Nil());
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable，针对于ObservableList移除
     * 适用于{@link ObservableList#clear(),ObservableMap#clear()}
     */
    public void clearFields() {
        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (LuaTable luaTable : luaTables) {
            if (!luaTable.isDestroyed()) {
                luaTable.clear();
            } else {
                luaValueCache.remove(luaTable);
            }
        }
    }


    /**
     * 操作缓存luaTable,针对于observableMap
     * 适用于{@link ObservableMap#putAll(Map)}
     *
     * @param observableMap
     */
    public void putAllField(ObservableMap observableMap) {
        if (luaValueCache == null) {
            return;
        }
        List<LuaTable> luaTables = (List<LuaTable>) luaValueCache.clone();
        for (Object key : observableMap.keySet()) {
            for (LuaTable luaTable : luaTables) {
                if (!luaTable.isDestroyed()) {
                    luaTable.set((String) key, BindingConvertUtils.toLuaValue(luaTable.getGlobals(), observableMap.get(key)));
                } else {
                    luaValueCache.remove(luaTable);
                }
            }
        }
    }


    /**
     * 添加缓存
     * 首次获取转化之后添加给{@link ObservableMap,ObservableField,ObservableList}
     *
     * @param luaTable
     */
    public void addFieldCache(LuaTable luaTable) {
        if (luaValueCache == null) {
            luaValueCache = new ArrayList<>();
        }

        for (LuaTable luaValue : luaValueCache) {
            if (luaValue.getGlobals() == luaTable.getGlobals()) {
                luaValueCache.remove(luaValue);
                break;
            }
        }
        luaValueCache.add(luaTable);
    }

    /**
     * 从缓存中获取luaTable
     *
     * @param globals
     * @return
     */
    public LuaTable getFieldCache(Globals globals) {
        if (luaValueCache == null) {
            return null;
        }

        for (LuaTable luaTable : luaValueCache) {
            if (luaTable.getGlobals() == globals && !luaTable.isDestroyed()) {
                return luaTable;
            }
        }
        return null;
    }
}
