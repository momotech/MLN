/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.content.Intent;

/**
 * Created by Xiong.Fangyu on 2019-08-21
 *
 * 监听activity 返回事件
 */
public interface OnActivityResultListener {
    /**
     * 处理activity返回结果
     * @param resultCode 返回码
     * @param data       数据
     * @return true：将从缓存中删除此Listener，false: 不删除
     *          建议返回true
     */
    boolean onActivityResult(int resultCode, Intent data);
}