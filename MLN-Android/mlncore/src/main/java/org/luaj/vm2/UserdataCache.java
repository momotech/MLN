/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import android.util.LongSparseArray;

import com.immomo.mlncore.MLNCore;

import java.lang.ref.SoftReference;

/**
 * Created by Xiong.Fangyu on 2019-08-28
 *
 * 由于userdata也就是java对象保存到native层，需要占用jni的global表，
 * 多虚拟机的情况下，多个页面非常容易造成global表溢出
 *
 * 修改为在java层保存对象
 *
 * 每个对象有个独一无二的long值，native层通过long值拿到java对象，并执行相应函数
 * 假设单个虚拟机中java对象不超过{@link Long#MAX_VALUE}个
 */
class UserdataCache {
    /**
     * 下一个java对象可用id
     */
    private volatile long cacheLong = 1;
    /**
     * 缓存userdata
     */
    private final LongSparseArray<LuaUserdata> cache;
    /**
     * 已被删除缓存的userdata
     */
    private LongSparseArray<SoftReference<LuaUserdata>> removedCache;
    /**
     * 标记销毁状态
     */
    private boolean destroyed = false;

    UserdataCache() {
        cache = new LongSparseArray<LuaUserdata>(100);
    }

    /**
     * userdata在初始化后，需要放入缓存中
     *
     * @see LuaUserdata
     */
    void put(LuaUserdata ud) {
        if (destroyed)
            return;
        if (ud.id != 0)
            return;
        ud.id = cacheLong++;
        cache.put(ud.id, ud);
    }

    /**
     * 获取缓存的userdata
     * 提供给native调用，Java层一般不调用
     *
     * @see Globals#__getUserdata(long, long)
     *
     * @param id id
     * @return 返回缓存的userdata
     */
    LuaUserdata get(long id) {
        LuaUserdata ret = cache.get(id);
        if (ret != null)
            return ret;
        if (MLNCore.UserdataCacheType == MLNCore.TYPE_REMOVE_CACHE) {
            SoftReference<LuaUserdata> ref = removedCache != null ? removedCache.get(id) : null;
            ret = ref != null ? ref.get() : null;
            if (ret != null && MLNCore.DEBUG) {
                return MLNCore.onNullGet(id, ret);
            }
            return ret;
        }
        return null;
    }

    /**
     * 当userdata gc时，清除相应缓存
     * @param ud
     */
    void onUserdataGc(LuaUserdata ud, boolean finalized) {
        if (finalized) {
            cache.remove(ud.id);
            return;
        }
        switch (MLNCore.UserdataCacheType) {
            case MLNCore.TYPE_REMOVE:
                cache.remove(ud.id);
                break;
            case MLNCore.TYPE_REMOVE_CACHE:
                cache.remove(ud.id);
                if (removedCache == null) {
                    removedCache = new LongSparseArray<>(50);
                }
                removedCache.put(ud.id, new SoftReference<LuaUserdata>(ud));
                break;
            default:
                break;
        }
    }

    /**
     * 虚拟机销毁时调用
     * 只会调用一次
     */
    void onDestroy() {
        destroyed = true;
        for (int i = 0, l = cache.size(); i < l; i ++) {
            cache.valueAt(i).__onLuaGc();
        }
        cache.clear();
        if (removedCache != null) {
            removedCache.clear();
        }
    }
}