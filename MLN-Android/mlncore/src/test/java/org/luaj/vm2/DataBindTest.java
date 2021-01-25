/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import org.junit.Assert;
import org.junit.Test;

import java.io.File;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class DataBindTest extends BaseLuaTest {

    private static final String lua1 = "lua1.lua";
    private static final String lua2 = "lua2.lua";

    @Test
    public void test() {
        Globals g1 = initGlobals();
        File f = new File(CurrentPathUtils.assetsDir(), lua1);
        boolean ret = g1.loadFile(f.getAbsolutePath(), "lua1");
        if (!ret) {
            g1.getError().printStackTrace();
        }
        Assert.assertTrue(ret);
        ret = g1.callLoadedData();
        if (!ret) {
            g1.getError().printStackTrace();
        }
        Assert.assertTrue(ret);

        Globals g2 = initGlobals();
        f = new File(CurrentPathUtils.assetsDir(), lua2);
        Assert.assertTrue(g2.loadFile(f.getAbsolutePath(), "lua2"));
        Assert.assertTrue(g2.callLoadedData());
    }

    @Override
    protected void onMemoryLeak(long mem) {

    }
}