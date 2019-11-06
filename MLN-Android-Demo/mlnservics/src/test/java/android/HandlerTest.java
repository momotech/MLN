package android;

import com.immomo.mls.Log;

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
