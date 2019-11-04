package com.immomo.mls.fun.ud.view.viewpager;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/9/27.
 */
final class ViewPagerRecycler {

    private final Map<String, ViewPagerContent> pools;

    ViewPagerRecycler() {
        pools = new HashMap<>();
    }

    ViewPagerContent getViewFromPoolByReuseId(String id) {
        return pools.remove(id);
    }

    void saveViewToPoolByReuseId(String id, ViewPagerContent v) {
        pools.put(id, v);
    }

    void release() {
        pools.clear();
    }
}
