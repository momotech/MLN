/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import android.ALongSparseArray;
import androidx.collection.LongSparseArray;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.luaj.vm2.utils.IGlobalsUserdata;
import org.luaj.vm2.utils.ILog;
import org.luaj.vm2.utils.NativeLog;
import org.luaj.vm2.utils.PathResourceFinder;
import org.mockito.Mockito;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.junit.MockitoJUnitRunner;
import org.mockito.stubbing.Answer;

import java.io.File;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;

/**
 * Created by Xiong.Fangyu on 2019-06-17
 */
@RunWith(MockitoJUnitRunner.class)
public abstract class BaseLuaTest {

    private List<Globals> globals = new ArrayList<>();

    private static final int CLOSE_ACTION = 0x123;

    @Before
    public void initPath() {
        System.load(new File(CurrentPathUtils.testDir(), "libluajapi.so").getAbsolutePath());
        assertTrue(Globals.isInit());
        mockGlboalsLongSparseArray();
        mockNativeLogLongSparseArray();
        Log.i("Lua vm is " + (Globals.isIs32bit() ? "32" : "64") + " bits");
    }

    private <T> void mockLongSparseArray(LongSparseArray<T> r, final ALongSparseArray<T> m, Class<T> clz) {
        Mockito.doAnswer(new Answer<T>() {
            @Override
            public T answer(InvocationOnMock invocation) throws Throwable {
                long index = invocation.getArgument(0);
                T def = invocation.getArgument(1);
                return m.get(index, def);
            }
        }).when(r).get(anyLong(), any(clz));
        
        Mockito.doAnswer(new Answer<T>() {
            @Override
            public T answer(InvocationOnMock invocation) throws Throwable {
                long index = invocation.getArgument(0);
                return m.get(index);
            }
        }).when(r).get(anyLong());
        
        Mockito.doAnswer(new Answer<Integer>() {
            @Override
            public Integer answer(InvocationOnMock invocation) throws Throwable {
                return m.size();
            }
        }).when(r).size();
        
        Mockito.doAnswer(new Answer<T>() {
            @Override
            public T answer(InvocationOnMock invocation) throws Throwable {
                return m.valueAt((Integer) invocation.getArgument(0));
            }
        }).when(r).valueAt(anyInt());
        
        Mockito.doAnswer(new Answer<Void>() {
            @Override
            public Void answer(InvocationOnMock invocation) throws Throwable {
                long i = invocation.getArgument(0);
                T g = invocation.getArgument(1);
                m.put(i, g);
                return null;
            }
        }).when(r).put(anyLong(), any(clz));
        
        Mockito.doAnswer(new Answer<Integer>() {
            @Override
            public Integer answer(InvocationOnMock invocation) throws Throwable {
                return m.indexOfKey((Long) invocation.getArgument(0));
            }
        }).when(r).indexOfKey(anyLong());

        Mockito.doAnswer(new Answer<Void>() {
            @Override
            public Void answer(InvocationOnMock invocation) throws Throwable {
                m.removeAt((Integer) invocation.getArgument(0));
                return null;
            }
        }).when(r).removeAt(anyInt());

        Mockito.doAnswer(new Answer<Void>() {
            @Override
            public Void answer(InvocationOnMock invocation) throws Throwable {
                m.remove((Long) invocation.getArgument(0));
                return null;
            }
        }).when(r).remove(anyLong());
    }

    private void mockNativeLogLongSparseArray() {
        try {
            Field logBuilder = NativeLog.class.getDeclaredField("logBuilder");
            Field logs = NativeLog.class.getDeclaredField("logs");
            logBuilder.setAccessible(true);
            logs.setAccessible(true);

            LongSparseArray<StringBuilder> arr = Mockito.mock(LongSparseArray.class);
            logBuilder.set(null, arr);
            ALongSparseArray<StringBuilder> ra1 = new ALongSparseArray<>(10);
            mockLongSparseArray(arr, ra1, StringBuilder.class);

            LongSparseArray<ILog> arr2 = Mockito.mock(LongSparseArray.class);
            logs.set(null, arr2);
            ALongSparseArray<ILog> ra2 = new ALongSparseArray<>(10);
            mockLongSparseArray(arr2, ra2, ILog.class);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    private void mockGlboalsLongSparseArray() {
        try {
            Field cacheField = Globals.class.getDeclaredField("cache");
            Field g_cahceField = Globals.class.getDeclaredField("g_cahce");
            cacheField.setAccessible(true);
            g_cahceField.setAccessible(true);

            LongSparseArray<Globals> arr = Mockito.mock(LongSparseArray.class);
            cacheField.set(null, arr);
            ALongSparseArray<Globals> ra1 = new ALongSparseArray<>(10);
            mockLongSparseArray(arr, ra1, Globals.class);

            arr = Mockito.mock(LongSparseArray.class);
            g_cahceField.set(null, arr);
            ra1 = new ALongSparseArray<>(10);
            mockLongSparseArray(arr, ra1, Globals.class);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    /*private void mockLooper() {
        SLooper sLooper = SLooper.myLooper();
        final Handler handler;
        if (sLooper != null) {
            handler = Mockito.mock(Handler.class);
            globals.handler = handler;
            sHandler = new SHandler() {
                @Override
                public void handleMessage(SMessage msg) {
                    if (msg.what == CLOSE_ACTION)
                        looper.quit();
                }
            };
            Mockito.doAnswer(new Answer<Void>() {
                @Override
                public Void answer(InvocationOnMock invocation) throws Throwable {
                    Runnable r = invocation.getArgument(0);
                    sHandler.post(r);
                    return null;
                }
            }).when(handler).post(any(Runnable.class));
        } else {
            handler = null;
            sHandler = null;
            globals.handler = null;
        }
    }*/

    protected Globals initGlobals() {
//        if (withLooper) {
//            SLooper.prepareMainLooper();
//            looper = SLooper.myLooper();
//        }
        Globals globals = Globals.createLState(true);
//        if (withLooper) mockLooper();
        globals.setBasePath(CurrentPathUtils.assetsDir(), false);
        globals.setResourceFinder(new PathResourceFinder(CurrentPathUtils.assetsDir()));
        globals.setJavaUserdata(new IGlobalsUserdata() {
            @Override
            public void onGlobalsDestroy(Globals g) {

            }

            @Override
            public void l(long L, String tag, String log) {
                Log.i(tag + " : " + log);
            }

            @Override
            public void e(long L, String tag, String log) {
                Log.e(tag + " : " + log);
            }
        });
        registerBridge(globals);
        this.globals.add(globals);
        return globals;
    }

    /*protected boolean quitLooperDelay(int ms) {
        if (sHandler != null) {
            SMessage msg = SMessage.obtain();
            msg.what = CLOSE_ACTION;
            return sHandler.sendMessageDelayed(msg, ms);
        }
        return false;
    }*/

    protected void registerBridge(Globals g) { }

    protected void checkStackSize(Globals g, int size) {
        assertEquals(size, g.dump().length);
    }

    @After
    public void onDestroy() {
//        if (looper != null)
//            SLooper.loop();
        Log.i("---------------onDestroy---------------");
        for (Globals g : globals) {
            g.destroy();
        }

        long mem = Globals.getAllLVMMemUse();
        if (mem > 0) {
            onMemoryLeak(mem);
        }
    }

    protected void onMemoryLeak(long mem) {
        Globals.logMemoryLeakInfo();
        Assert.assertEquals(0, mem);
    }
}