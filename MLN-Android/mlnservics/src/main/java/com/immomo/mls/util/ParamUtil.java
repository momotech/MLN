/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Created by LuaView.
 * Copyright (c) 2017, Alibaba Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

package com.immomo.mls.util;

/**
 * Param handler
 * @author song
 * @date 15/10/22
 */
public class ParamUtil {

    /**
     * add postfix to given name if no postfix found
     *
     * @param name
     * @param postfix
     * @return
     */
    public static String getFileNameWithPostfix(final String name, final String postfix) {
        if (name != null && name.indexOf('.') == -1) {
            return name + "." + postfix;
        }
        return name;
    }
}