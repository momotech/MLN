/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.cache;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 所有LuaView级别的cache管理
 *
 * @author song
 * @date 16/4/11
 * 主要功能描述
 * 修改描述
 * 上午11:32 song XXX
 */
public class LuaCache {
    //缓存的数据，需要在退出的时候清空
    private Map<Object, CacheableObject> mCachedObjects;

    //缓存数据管理器
    public interface CacheableObject {
        void onCacheClear();
    }

    /**
     * 缓存对象
     */
    public void cacheObject(Object key, CacheableObject obj) {
        if (obj == null)
            return;
        if (mCachedObjects == null) {
            mCachedObjects = new ConcurrentHashMap<>();
        }
        mCachedObjects.put(key, obj);
    }

    public <T extends CacheableObject> T get(Object type) {
        if (mCachedObjects == null)
            return null;
        return (T) mCachedObjects.get(type);
    }

    /**
     * 清理所有缓存的对象
     */
    public void clear() {
        if (mCachedObjects != null && mCachedObjects.size() > 0) {
            for (Map.Entry<Object, CacheableObject> entry : mCachedObjects.entrySet()) {
                entry.getValue().onCacheClear();
            }
            mCachedObjects.clear();
        }
        mCachedObjects = null;
    }
}