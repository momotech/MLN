/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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