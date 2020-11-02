/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.utils;

import com.immomo.mmui.databinding.bean.MMUIColor;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/8/5 上午11:10
 */
public class ViewModelUtil {
    public static Object convertType(Object value,String type) {
        switch (type) {
            case "int":
            case "long":
            case "short":
            case "byte":
                return value == null?0:value;
            case "float":
            case "double":
                return value == null?0.0:value;
            case "boolean":
                return value == null?false:value;
            case "char":
                return value == null?' ':value;
            case "MMUIColor":
                return value ==null ? -1:((MMUIColor)value).getColor();
            default:
                return value;
        }
    }
}
