/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.utils.convert;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by Xiong.Fangyu on 2020/7/29
 */
class ArrayUtils {

    static Object[] increase(Object[] src, int to) {
        return Arrays.copyOf(src, to);
    }

    static Object[] set(Object[] src, Object value, int index) {
        if (index < 0)
            throw new IllegalArgumentException("index < 0");
        int len = src.length;
        if (index >= len) {
            int newLen = (int) (len * 1.7f);
            newLen = newLen <= len ? len + 1 : newLen;
            src = Arrays.copyOf(src, newLen);
        }
        src[index] = value;
        return src;
    }

    static ArrayList<Object> toList(Object[] src, int max) {
        Object[] arr = src.length != max ? Arrays.copyOf(src, max) : src;
        return new ArrayList<>(Arrays.asList(arr));
    }
}
