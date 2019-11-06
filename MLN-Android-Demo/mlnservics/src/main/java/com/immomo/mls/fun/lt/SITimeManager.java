package com.immomo.mls.fun.lt;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaClass
public class SITimeManager {
    public static final String KEY = "TimeManager";

    private List<IntervalTask> tasks;
    private final Object tag;

    public SITimeManager(Globals globals, LuaValue[] init) {
        tag = new Object();
    }

    public void __onLuaGc() {
        clearInterval();
    }

    @LuaBridge
    public void setTimeOut(final IVoidCallback fun, float delay) {
        MainThreadExecutor.postDelayed(getTag(), new Runnable() {
            @Override
            public void run() {
                fun.callback();
            }
        }, (long) (delay * 1000));
    }

    @LuaBridge
    public void setInterval(final LuaFunction fun, float timeInterval) {
        long t = (long) (timeInterval * 1000);
        IntervalTask task = new IntervalTask(fun, t);
        if (tasks == null) {
            tasks = new ArrayList<>();
        }
        tasks.add(task);
        MainThreadExecutor.postDelayed(getTag(), task, t);
    }

    @LuaBridge
    public void clearInterval() {
        if (tasks != null) {
            for (IntervalTask t : tasks) {
                t.destroy();
            }
            tasks.clear();
        }
        MainThreadExecutor.cancelAllRunnable(getTag());
    }

    private final class IntervalTask implements Runnable {
        LuaFunction fun;
        long timeInterval;

        IntervalTask(LuaFunction fun, long timeInterval) {
            this.fun = fun;
            this.timeInterval = timeInterval;
        }

        @Override
        public void run() {
            fun.invoke(null);
            MainThreadExecutor.postDelayed(getTag(), this, timeInterval);
        }

        void destroy() {
            if (fun != null)
                fun.destroy();
        }
    }

    private Object getTag() {
        return tag;
    }
}
