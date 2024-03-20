/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.util.SparseArray;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/9/20.
 */
class IDGenerator {
    private int typeId;
    /**
     * viewtype 对应的id
     */
    private final SparseArray<String> viewTypeIdCache;
    /**
     * 所有viewtype缓存，reload时清除
     */
    private final Map<String, Integer> viewTypeCache;
    IDGenerator() {
        typeId = 0;
        viewTypeIdCache = new SparseArray<>(20);
        viewTypeCache = new HashMap<>(20);
    }

    public int getViewTypeForReuseId(String id) {
        Integer type = viewTypeCache.get(id);
        if (type != null)
            return type;
        if (typeId == Integer.MAX_VALUE) {
            typeId = 0;
        }
        int result = typeId ++;
        viewTypeCache.put(id, result);
        viewTypeIdCache.put(result, id);
        return result;
    }

    public String getReuseIdByType(int type) {
        return viewTypeIdCache.get(type);
    }

    public void release() {
        viewTypeIdCache.clear();
        viewTypeCache.clear();
    }
}