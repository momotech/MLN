/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.net;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
@ConstantClass
public interface CachePolicy {
    @Constant
    int API_ONLY = 0; //不使用缓存,只从网络更新数据
    @Constant
    int CACHE_THEN_API = 1; //先使用缓存，随后请求网络更新请求
    @Constant
    int CACHE_OR_API = 2; //优先使用缓存，无法找到缓存时才连网更新
    @Constant
    int CACHE_ONLY = 3; //只读缓存
    @Constant
    int REFRESH_CACHE_BY_API = 4; //刷新网络后数据加入缓存


    @IntDef({API_ONLY, CACHE_THEN_API, CACHE_OR_API, CACHE_ONLY, REFRESH_CACHE_BY_API})
    @Retention(RetentionPolicy.SOURCE)
    public @interface CacheType {}
}