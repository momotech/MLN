/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019/4/4
 * lua 二进制码工具
 */
public class LuaBinaryUtils {

    private static final byte[] LUA_BIN_SIGNATURE = {
            0x1b, 'L', 'u', 'a'
    };

    private static final char[] LUAC_DATA = {
            0x19, 0x93, '\r', '\n', 0x1a, '\n'
    };

    private static final int signatureLength = LUA_BIN_SIGNATURE.length;

    private static final int dataLength = LUAC_DATA.length;

    /**
     * 简单检查，数据前4字节是否是二进制签名
     * @param data 数据，不可为空
     * @return true，是二进制签名
     */
    public static boolean isBinaryData(byte[] data) {
        final int len = data.length;
        if (len <= signatureLength)
            return false;
        for (int i = 0; i < signatureLength; i ++) {
            if (data[i] != LUA_BIN_SIGNATURE[i])
                return false;
        }
        return true;
    }

    /**
     * 详细检查数据头部
     * @param data 数据，不可为空
     * @return true，有效数据
     */
    public static boolean checkBinaryData(byte[] data) {
        if (!isBinaryData(data))
            return false;
        int i = signatureLength;
        if (data[i++] != Globals.LUAC_VERSION)
            return false;
        if (data[i++] != 0)
            return false;
        for (int j = 0; j < dataLength; j ++) {
            if (data[j + i] != LUAC_DATA[j])
                return false;
        }
        // maybe more check
        return true;
    }
}