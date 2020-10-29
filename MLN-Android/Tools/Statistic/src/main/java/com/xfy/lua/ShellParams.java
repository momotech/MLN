/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.lua;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public class ShellParams {

    private final Map<String, String> keyValues;
    private final List<String> boolKeys;

    public ShellParams(String[] boolKeys, String[] keys, String[] args) {
        int l = args.length;
        this.keyValues = new HashMap<>(l);
        this.boolKeys = new ArrayList<>(l);

        for (int i = 0; i < l;i ++) {
            String str = args[i];
            if (containKey(boolKeys, str)) {
                this.boolKeys.add(str);
            } else if (containKey(keys, str) && i + 1 < l) {
                this.keyValues.put(str, args[++i]);
            }
        }
    }

    private static boolean containKey(String[] keys, String str) {
        if (keys == null)
            return false;
        for (String s : keys) {
            if (str.equals(s))
                return true;
        }
        return false;
    }

    public boolean containKey(String key) {
        return boolKeys.contains(key);
    }

    public String getValue(String key) {
        return keyValues.get(key);
    }
}
