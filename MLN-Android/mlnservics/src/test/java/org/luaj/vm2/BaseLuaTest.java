package org.luaj.vm2;

import android.SHandler;
import android.SLooper;
import android.SMessage;
import android.os.Handler;

import com.immomo.mls.Log;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.ConsoleLoggerAdapter;
import com.immomo.mls.wrapper.Register;

import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.luaj.vm2.utils.IGlobalsUserdata;
import org.luaj.vm2.utils.PathResourceFinder;
import org.mockito.Mockito;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.junit.MockitoJUnitRunner;
import org.mockito.stubbing.Answer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;

/**
 * Created by Xiong.Fangyu on 2019-06-17
 */
@RunWith(MockitoJUnitRunner.class)
public abstract class BaseLuaTest {
    protected Globals globals;

    private static final int CLOSE_ACTION = 0x123;
    private SLooper looper;
    private SHandler sHandler;
    protected Register register;

    @Before
    public void initPath() {
        Utils.loadLibrary();
        assertTrue(Globals.isInit());
        MLSAdapterContainer.setConsoleLoggerAdapter(new LogImpl());
        register = new Register();
        Log.i("Lua vm is " + (Globals.is32bit() ? "32" : "64") + " bits");
    }

    private void mockLooper() {
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
    }

    protected void initGlobals(boolean withLooper) {
        if (withLooper) {
            SLooper.prepareMainLooper();
            looper = SLooper.myLooper();
        }
        globals = Globals.createLState(true);
        if (withLooper) mockLooper();
        globals.setBasePath(Utils.getAssetsPath(), false);
        globals.setResourceFinder(new PathResourceFinder(Utils.getAssetsPath()));
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
        Log.i("---------------on Start---------------");
        registerBridge();
        register.install(globals);
    }

    protected boolean quitLooperDelay(int ms) {
        if (sHandler != null) {
            SMessage msg = SMessage.obtain();
            msg.what = CLOSE_ACTION;
            return sHandler.sendMessageDelayed(msg, ms);
        }
        return false;
    }

    protected void registerBridge() { }

    protected void checkStackSize(int size) {
        assertEquals(size, globals.dump().length);
    }

    @After
    public void onDestroy() {
        if (looper != null)
            SLooper.loop();
        Log.i("---------------onDestroy---------------");
        if (globals != null)
        globals.destroy();
        Utils.onGlobalsDestroy();
    }

    private static class LogImpl implements ConsoleLoggerAdapter {

        @Override
        public void v(String tag, String formatLog, Object... format) {
            Log.f(tag + " - " + formatLog, format);
        }

        @Override
        public void i(String tag, String formatLog, Object... format) {
            Log.f(tag + " - " + formatLog, format);

        }

        @Override
        public void d(String tag, String formatLog, Object... format) {
            Log.f(tag + " - " + formatLog, format);

        }

        @Override
        public void w(String tag, String formatLog, Object... format) {
            Log.f(tag + " - " + formatLog, format);

        }

        @Override
        public void e(String tag, String formatLog, Object... format) {
            Log.ef(tag + " - " + formatLog, format);

        }

        @Override
        public void e(String tag, Throwable t, String formatLog, Object... format) {
            Log.ef(tag + " - " + formatLog, format);
            t.printStackTrace();
        }

        @Override
        public void e(String tag, Throwable t) {
            Log.e(tag);
            t.printStackTrace();
        }
    }
}
