/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class StringReplaceUtils {
    private static final int UPPER_OFFSET = 'A' - 'a';
    /**
     * 将字符串中所有找到的find字符替换为replacement字符
     */
    public static
    String replaceAllChar(String src, char find, char replacement) {
        int l = src.length();
        char[] chars = new char[l];
        src.getChars(0, l, chars, 0);
        for (int i = 0; i < l; i++) {
            if (chars[i] == find) {
                chars[i] = replacement;
            }
        }
        return new String(chars);
    }

    /**
     * 将字符串中所有找到的find字符替换为replacement字符
     */
    public static void replaceAllChar(StringBuilder src, char find, char replacement) {
        int l = src.length();
        char[] chars = new char[l];
        src.getChars(0, l, chars, 0);
        for (int i = 0; i < l; i++) {
            if (chars[i] == find) {
                chars[i] = replacement;
            }
        }
        src.delete(0, l);
        src.append(chars);
    }

    public static String changeFirstLetterToUpperCase(String s) {
        if (s == null)
            return null;
        char first = s.charAt(0);
        if (first >= 'a' && first <= 'z') {
            return (char) (first + UPPER_OFFSET) + s.substring(1);
        }
        return s;
    }
    public static String changeFirstLetterLow(String s) {
        if (s == null)
            return null;
        char first = s.charAt(0);
        if (first >= 'A' && first <= 'Z') {
            return (char) (first - UPPER_OFFSET) + s.substring(1);
        }
        return s;
    }
}