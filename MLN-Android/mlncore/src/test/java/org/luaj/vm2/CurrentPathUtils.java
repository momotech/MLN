/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2020/6/5
 */
class CurrentPathUtils {

    public static String pwd() {
        return System.getenv("PWD");
    }

    public static String testDir() {
        return pwd() + File.separatorChar + "src" + File.separatorChar + "test";
    }

    public static String assetsDir() {
        return testDir() + File.separatorChar + "assets";
    }
}