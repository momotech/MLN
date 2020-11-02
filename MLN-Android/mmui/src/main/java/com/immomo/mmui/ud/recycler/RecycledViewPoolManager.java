/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.cache.LuaCache;

import org.luaj.vm2.Globals;

import java.lang.reflect.Method;

/**
 * Created by fanqiang on 2018/9/12.
 */
public class RecycledViewPoolManager implements LuaCache.CacheableObject {
    private static Method PoolSizeMethod;

    private final RecyclerView.RecycledViewPool recycledViewPool;
    private final IDGenerator idGenerator;

    public static RecycledViewPoolManager getInstance(@NonNull Globals g) {
        LuaViewManager m = (LuaViewManager) g.getJavaUserdata();
        final LuaCache luaCache = m.luaCache;
        RecycledViewPoolManager ret = luaCache.get(RecycledViewPoolManager.class);
        if (ret != null)
            return ret;
        ret = new RecycledViewPoolManager();
        luaCache.cacheObject(RecycledViewPoolManager.class, ret);
        return ret;
    }

    private RecycledViewPoolManager() {
        idGenerator = new IDGenerator();
        recycledViewPool = new MLSRecyclerViewPool(MLSConfigs.maxRecyclerPoolSize);
    }

    public RecyclerView.RecycledViewPool getRecycleViewPoolInstance() {
        return recycledViewPool;
    }

    public void setMaxRecycledViews(int viewType, int max) {
        recycledViewPool.setMaxRecycledViews(viewType, max);
    }

    public void clearPool() {
        recycledViewPool.clear();
    }

    public int getRecycledViewNum() {
        Method method = getPoolSizeMethod();
        int size = 0;
        if (method != null) {
            try {
                size = (int) method.invoke(recycledViewPool);
            } catch (Throwable e) {
            }
        }
        return size;
    }

    private static Method getPoolSizeMethod() {
        if (PoolSizeMethod != null)
            return PoolSizeMethod;
        try {
            PoolSizeMethod = RecyclerView.RecycledViewPool.class.getDeclaredMethod("size");
            PoolSizeMethod.setAccessible(true);
        } catch (Throwable t) {

        }
        return PoolSizeMethod;
    }

    public IDGenerator getIdGenerator() {
        return idGenerator;
    }

    @Override
    public void onCacheClear() {
        clearPool();
        idGenerator.release();
    }
}