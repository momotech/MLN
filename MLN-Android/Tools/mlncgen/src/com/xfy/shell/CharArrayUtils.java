/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public class CharArrayUtils {
    public static final char[] Blank = {
            ' ', '\t', '\n'
    };

    public static boolean isBlank(char c) {
        for (char b : Blank) {
            if (c == b)
                return true;
        }
        return false;
    }

    public static char[] combine(char[] a, char b) {
        char[] ret = new char[a.length + 1];
        System.arraycopy(a, 0, ret, 0, a.length);
        ret[a.length] = b;
        return ret;
    }

    public static int beforeChar(char[] chars, char k, int i, int min) {
        while (i > min) {
            if (k != chars[i])
                return i;
            i--;
        }
        return -1;
    }

    public static int beforeChars(char[] chars, char[] keys, int i, int min) {
        boolean find = false;
        while (i > min) {
            for (char k : keys) {
                find = k == chars[i];
                if (find)
                    break;
            }
            if (!find)
                return i;
            i--;
        }
        return -1;
    }

    public static int afterChar(char[] chars, char k, int i, int max) {
        while (i < max) {
            if (k == chars[i])
                return i;
            i++;
        }
        return -1;
    }

    public static int afterChars(char[] chars, char[] keys, int i, int max) {
        boolean find = false;
        while (i < max) {
            for (char k : keys) {
                find = k == chars[i];
                if (find)
                    break;
            }
            if (!find)
                return i;
            i++;
        }
        return -1;
    }

    public static int beforeNotChars(char[] chars, char[] keys, int i, int min) {
        boolean find = false;
        while (i > min) {
            for (char k : keys) {
                find = k == chars[i];
                if (find)
                    break;
            }
            if (find)
                return i;
            i--;
        }
        return -1;
    }

    public static int beforeNotChar(char[] chars, char k, int i, int min) {
        while (i > min) {
            if (k == chars[i])
                return i;
            i--;
        }
        return -1;
    }

    public static int afterNotChars(char[] chars, char[] keys, int i, int max) {
        boolean find = false;
        while (i < max) {
            for (char k : keys) {
                find = k == chars[i];
                if (find)
                    break;
            }
            if (find)
                return i;
            i++;
        }
        return -1;
    }

    public static int afterNotChar(char[] chars, char k, int i, int max) {
        while (i < max) {
            if (k == chars[i])
                return i;
            i++;
        }
        return -1;
    }

    public static int afterBlank(char[] chars, int i, int max) {
        return afterChars(chars, Blank, i, max);
    }

    public static int beforeBlank(char[] chars, int i, int min) {
        return beforeChars(chars, Blank, i, min);
    }

    public static int afterBlank(char[] chars, int i) {
        return afterBlank(chars, i, chars.length);
    }

    public static int beforeBlank(char[] chars, int i) {
        return beforeBlank(chars, i, 0);
    }

    public static int beforeNotBlank(char[] chars, int i, int min) {
        return beforeNotChars(chars, Blank, i, min);
    }

    public static int afterNotBlank(char[] chars, int i, int max) {
        return afterNotChars(chars, Blank, i, max);
    }

    public static int beforeNotBlank(char[] chars, int i) {
        return beforeNotBlank(chars, i, 0);
    }

    public static int afterNotBlank(char[] chars, int i) {
        return afterNotBlank(chars, i, chars.length);
    }
}
