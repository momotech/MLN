/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.util;

import java.net.InetAddress;
import java.net.UnknownHostException;

public class LuaNativeUtil {

    public static byte[] mergeBytes(byte[] data_1, byte[] data_2) {
        byte[] data = new byte[data_1.length + data_2.length];
        System.arraycopy(data_1, 0, data, 0, data_1.length);
        System.arraycopy(data_2, 0, data, data_1.length, data_2.length);
        return data;
    }

    public static byte[] getBytes(byte[] data, int start, int length) {
        byte[] data_dst = new byte[length];
        System.arraycopy(data, start, data_dst, 0, length);
        return data_dst;
    }

    public static  String getIp() {
        InetAddress addr = null;
        try {
            addr = InetAddress.getLocalHost();
            return addr.getHostAddress();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static  boolean isLuaFile(String filePath) {
        String suffix = filePath.substring(filePath.lastIndexOf(".") + 1);
        if (suffix.equals(new String("lua"))) {
            return true;
        }
        return false;
    }

    public static String getLineInfo()
    {
        StackTraceElement ste = new Throwable().getStackTrace()[1];
        return ste.getFileName() + ": Line " + ste.getLineNumber();
    }
}