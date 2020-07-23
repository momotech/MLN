/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package android;

import org.luaj.vm2.Log;

import org.junit.Assert;
import org.junit.Test;

/**
 * Created by Xiong.Fangyu on 2019-06-24
 */
public class HandlerTest {

    @Test
    public void createHandler() {
        SLooper.prepare();
        final SHandler handler = new SHandler();

        new Thread(new Runnable() {
            @Override
            public void run() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        Log.i("in thread");
                        Assert.assertEquals(handler.mLooper, SLooper.myLooper());
                        Log.i("after test");
                    }
                });
            }
        }).start();
        SLooper.loop();
    }

    @Test
    public void quit() {
        SLooper.prepare();
        final SHandler handler = new SHandler();

        new Thread(new Runnable() {
            @Override
            public void run() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        SLooper.myLooper().quit();
                    }
                });
            }
        }).start();
        SLooper.loop();
        Log.i("after looper");
    }
}