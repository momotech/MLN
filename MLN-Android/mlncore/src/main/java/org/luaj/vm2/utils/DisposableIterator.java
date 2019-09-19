/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import java.util.Iterator;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 可结束的迭代器
 * @see org.luaj.vm2.LuaTable
 */
public interface DisposableIterator<E> extends Iterator<E> {
    /**
     * 必须调用结束语句
     */
    void dispose();
}