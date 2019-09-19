/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import android.content.Context;
import android.view.View;

/**
 * Created by XiongFangyu on 2018/7/18.
 */
public interface MLSEmptyViewAdapter {
    /**
     * 创建empty view，一个instance只调用一次
     * @param <T>
     * @param context
     * @return
     */
    <T extends View & EmptyView> T createEmptyView(Context context);

    /**
     * empty view需实现这些接口
     */
    public interface EmptyView {
        /**
         * 设置标题
         * @param title
         */
        void setTitle(CharSequence title);

        /**
         * 设置内容
         * @param msg
         */
        void setMessage(CharSequence msg);
    }
}