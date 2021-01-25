/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.xfy.shell;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class ClearCommentUtils {

    public static String clearComment(String filecontent) {
        // 1、清除单行的注释，如： //某某，正则为 ：\/\/.*
        // 2、清除单行的注释，如：/** 某某 */，正则为：\/\*\*.*\*\/
        // 3、清除单行的注释，如：/* 某某 */，正则为：\/\*.*\*\/
        // 4、清除多行的注释，如:
        // /* 某某1
        // 某某2
        // */
        // 正则为：.*/\*(.*)\*/.*
        // 5、清除多行的注释，如：
        // /** 某某1
        // 某某2
        // */
        // 正则为：/\*\*(\s*\*\s*.*\s*?)*
        Map<String, String> patterns = new HashMap<>();
        patterns.put("([^:])\\/\\/.*", "$1");// 匹配在非冒号后面的注释，此时就不到再遇到http://
        patterns.put("\\s+\\/\\/.*", "");// 匹配“//”前是空白符的注释
        patterns.put("^\\/\\/.*", "");
        patterns.put("^\\/\\*\\*.*\\*\\/$", "");
        patterns.put("\\/\\*.*\\*\\/", "");
        patterns.put("/\\*(\\s*\\*\\s*.*\\s*?)*\\*\\/", "");
        //patterns.put("/\\*(\\s*\\*?\\s*.*\\s*?)*", "");
        Iterator<String> keys = patterns.keySet().iterator();
        String key, value;
        while (keys.hasNext()) {
            // 经过多次替换
            key = keys.next();
            value = patterns.get(key);
            filecontent = replaceAll(filecontent, key, value);
        }
        return clearBlankLine(filecontent);
    }

    public static String clearBlankLine(String str) {
        return str.replaceAll("((\r\n)|\n)[\\s\t ]*(\\1)+", "$1");
    }

    /**
     * @param fileContent   内容
     * @param patternString 匹配的正则表达式
     * @param replace       替换的内容
     */
    private static String replaceAll(String fileContent, String patternString, String replace) {
        String str = "";
        Matcher m;
        Pattern p;
        try {
            p = Pattern.compile(patternString);
            m = p.matcher(fileContent);
            str = m.replaceAll(replace);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return str;
    }
}