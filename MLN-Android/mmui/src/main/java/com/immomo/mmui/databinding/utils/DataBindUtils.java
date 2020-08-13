/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.utils;


import com.immomo.mmui.databinding.bean.ObservableList;

import java.math.BigDecimal;


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
        try {
            Long.parseLong(str);
        } catch (Exception e) {
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