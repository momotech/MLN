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

    /**
     * 从i下标开始往前查找，返回非k字符在chars中第一次出现的下标
     * @param i 开始查找下标，往前查找，包含
     * @param min 结束下标，不包含
     */
    public static int findNotCharBefore(char[] chars, char k, int i, int min) {
        while (i > min) {
            if (k != chars[i])
                return i;
            i--;
        }
        return -1;
    }

    /**
     * 从i下标开始往前查找，返回非keys字符在chars中第一次出现的下标
     * @param i 开始查找下标，往前查找，包含
     * @param min 结束下标，不包含
     */
    public static int findNotCharsBefore(char[] chars, char[] keys, int i, int min) {
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

    /**
     * 从i下标开始往后查找，返回非k字符在chars中第一次出现的下标
     * @param i 开始查找下标，往后查找，包含
     * @param max 结束下标，不包含
     */
    public static int findNotCharAfter(char[] chars, char k, int i, int max) {
        while (i < max) {
            if (k != chars[i])
                return i;
            i++;
        }
        return -1;
    }

    /**
     * 从i下标开始往后查找，返回非keys字符在chars中第一次出现的下标
     * @param i 开始查找下标，往后查找，包含
     * @param max 结束下标，不包含
     */
    public static int findNotCharsAfter(char[] chars, char[] keys, int i, int max) {
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

    /**
     * 从i下标开始往前查找，返回keys中字符在chars中第一次出现的下标
     * @param i 开始查找下标，往前查找，包含
     * @param min 结束下标，不包含，一般情况下min<i
     * @return 查找到的下标，或-1
     */
    public static int findBefore(char[] chars, char[] keys, int i, int min) {
        while (i > min) {
            for (char k : keys) {
                if (k == chars[i])
                    return i;
            }
            i--;
        }
        return -1;
    }

    /**
     * 从i下标开始往前查找，返回k中字符在chars中第一次出现的下标
     * @param i 开始查找下标，往前查找，包含
     * @param min 结束下标，不包含，一般情况下min<i
     * @return 查找到的下标，或-1
     */
    public static int findBefore(char[] chars, char k, int i, int min) {
        while (i > min) {
            if (k == chars[i])
                return i;
            i--;
        }
        return -1;
    }

    /**
     * 从i下标开始往后查找，返回keys中字符在chars中第一次出现的下标
     * @param i 开始查找下标，往后查找，包含
     * @param max 结束下标，不包含
     * @return 查找到的下标，或-1
     */
    public static int findAfter(char[] chars, char[] keys, int i, int max) {
        while (i < max) {
            for (char k : keys) {
                if (k == chars[i])
                    return i;
            }
            i++;
        }
        return -1;
    }

    /**
     * 从i下标开始往后查找，返回k中字符在chars中第一次出现的下标
     * @param i 开始查找下标，往后查找，包含
     * @param max 结束下标，不包含
     * @return 查找到的下标，或-1
     */
    public static int findAfter(char[] chars, char k, int i, int max) {
        while (i < max) {
            if (k == chars[i])
                return i;
            i++;
        }
        return -1;
    }

    public static int afterBlank(char[] chars, int i, int max) {
        return findNotCharsAfter(chars, Blank, i, max);
    }

    public static int beforeBlank(char[] chars, int i, int min) {
        return findNotCharsBefore(chars, Blank, i, min);
    }

    public static int afterBlank(char[] chars, int i) {
        return afterBlank(chars, i, chars.length);
    }

    public static int beforeBlank(char[] chars, int i) {
        return beforeBlank(chars, i, -1);
    }

    public static int findBlankBefore(char[] chars, int i, int min) {
        return findBefore(chars, Blank, i, min);
    }

    public static int findBlankAfter(char[] chars, int i, int max) {
        return findAfter(chars, Blank, i, max);
    }

    public static int findBlankBefore(char[] chars, int i) {
        return findBlankBefore(chars, i, -1);
    }

    public static int findBlankAfter(char[] chars, int i) {
        return findBlankAfter(chars, i, chars.length);
    }
}
