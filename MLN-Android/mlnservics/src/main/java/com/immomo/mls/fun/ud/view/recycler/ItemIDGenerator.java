/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;


import com.immomo.mls.utils.sparse.SparseLongArray;

/**
 * Created by Xiong.Fangyu on 2019/1/22
 */
class ItemIDGenerator {
//    private final SparseIntArray positionTypeCache;
    private final SparseLongArray itemId;
//    private final SparseLongArray itemIdCache;
    private long itemIdUsed = 0;
    ItemIDGenerator() {
        itemId = new SparseLongArray();
//        itemIdCache = new SparseLongArray();
//        positionTypeCache = new SparseIntArray();
    }

    long getIdBy(int pos, int viewType) {
        int index = itemId.indexOfKey(pos);

        if (index < 0) {
//            int oldType = positionTypeCache.get(pos, Integer.MIN_VALUE);

            // 相同位置type没变，返回之前的id
            // 如果id 不变，则 adapter 的 cellAppear  cellDisappear 不会被调用
            /*if (oldType == viewType) {
                long id = itemIdCache.get(pos, Long.MIN_VALUE);
                if (id != Long.MIN_VALUE) {
                    itemId.put(pos, id);
                    return id;
                }
            }*/

            long id = itemIdUsed++;
            itemId.put(pos, id);
//            itemIdCache.put(pos, id);
//            positionTypeCache.put(pos, viewType);

            return id;
        }

        return itemId.valueAt(index);
    }

    void removeIdBy(int position) {
        int index = itemId.indexOfKey(position);
        if (index >= 0)
            itemId.removeFrom(index);
//        index = positionTypeCache.indexOfKey(position);
//        if (index >= 0)
//            positionTypeCache.removeFrom(position);
//        index = itemIdCache.indexOfKey(position);
//        if (index >= 0)
//            itemIdCache.removeFrom(position);
    }

    void clear() {
        itemId.clear();
    }

}