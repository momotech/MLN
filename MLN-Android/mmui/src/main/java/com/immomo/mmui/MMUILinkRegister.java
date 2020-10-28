/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import android.app.Activity;
import android.util.ArrayMap;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-06-07 17:16
 */
public class MMUILinkRegister {

    private static ArrayMap<String, Class<? extends Activity>> linkActivities;

    /**
     * 注册页面
     * @param name
     * @param activity
     */
    public static void register(String name, Class<? extends Activity> activity) {
        if(linkActivities == null) {
            linkActivities = new ArrayMap<>();
        }
        if(linkActivities.containsKey(name)) {
            throw new RuntimeException(name + "is registered,please change other name");
        }
        linkActivities.put(name,activity);
    }


    /**
     * 查找目标Activity
     * @param name
     * @return
     */
    public static Class<? extends Activity> findActivity(String name) {
        if(linkActivities.containsKey(name)) {
            return linkActivities.get(name);
        }
        throw new RuntimeException(name + "is unRegistered,please register activity");
    }
}