/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.utils;


import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-02-29 15:01
 */
public class DataBindUtils {

    /**
     * 首字幕变成大写
     *
     * @param str
     * @return
     */
    public static String captureStr(String str) {
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }


    /**
     * 判断是否为空
     *
     * @param str
     * @return
     */
    public static boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }


    /**
     * 判断是否为数字
     * @param str
     * @return
     */
    public static boolean isNumber(String str) {
        Pattern pattern = Pattern.compile("[0-9]*");
        Matcher isNum = pattern.matcher(str);
        if (!isNum.matches()) {
            return false;
        }
        return true;
    }


    /**
     * 是否为二维数组
     * @param observableList
     * @return
     */
    public static boolean isDoubleList(ObservableList observableList) {
        if(observableList !=null && observableList.size()>0 && observableList.get(0) instanceof ObservableList) {
            return true;
        }
        return false;
    }
}