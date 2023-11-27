package com.immomo.mls.lite;

import androidx.annotation.NonNull;

import com.immomo.mls.Environment;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.fun.ud.view.VisibilityType;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/**
 * @author jidongdong
 * @date 2022-01-07 18:48:32
 * 请求分发器 管理请求
 */
public class Dispatcher {
    private static final String TAG = "LUA_Dispatcher";
    List<Call> runningSyncCalls = new ArrayList<>();

    synchronized void executed(RealCall call) {
        runningSyncCalls.add(call);
    }

    public synchronized void finished(Call call) {
        call.recycle();
        finished(runningSyncCalls, call);
    }

    private <T> void finished(List<T> calls, T call) {
        synchronized (this) {
            if (!calls.remove(call)) throw new AssertionError("Call wasn't in-flight!");
        }
    }

    public synchronized void cancelAll() {
        for (Call call : runningSyncCalls) {
            call.recycle();
        }
        runningSyncCalls.clear();
    }


    public synchronized List<Call> runningCalls() {
        List<Call> result = new ArrayList<>();
        result.addAll(runningSyncCalls);
        return Collections.unmodifiableList(result);
    }

    public synchronized int runningCallsCount() {
        return runningSyncCalls.size();
    }

    public synchronized void cancelAll(@NonNull Object tag) {
        MLSAdapterContainer.getConsoleLoggerAdapter().i(TAG, String.valueOf(runningCallsCount()));
        final Iterator<Call> each = runningSyncCalls.iterator();
        while (each.hasNext()) {
            MLSAdapterContainer.getConsoleLoggerAdapter().i(TAG, runningCallsCount() + "cancelAll");
            Call call = each.next();
            if (call.request() != null && tag.equals(call.request().tag())) {
                try {
                    if (call.window() != null && call.window().get() != null) {
                        call.window().get().onDestroy();
                    }
                } catch (Exception e) {
                    try {
                        Environment.hook(e, call.window().get().getUserdata().getGlobals());
                    } catch (Exception ignore) {
                    }
                }
                call.recycle();
                each.remove();
            }
        }
    }

    public synchronized void resume(Object tag) {
        MLSAdapterContainer.getConsoleLoggerAdapter().i(TAG, runningCallsCount() + "call.resume()");
        for (Call call : runningCalls()) {
            if (call.request() != null && tag.equals(call.request().tag())) {
                if (call.window() != null && call.window().get() != null) {
                    call.window().get().viewAppear(VisibilityType.LifeCycle);
                }
            }
        }
    }

    public synchronized void pause(Object tag) {
        MLSAdapterContainer.getConsoleLoggerAdapter().i(TAG, runningCallsCount() + "call.pause()");
        for (Call call : runningCalls()) {
            if (call.request() != null && tag.equals(call.request().tag())) {
                if (call.window() != null && call.window().get() != null) {
                    call.window().get().viewDisappear(VisibilityType.LifeCycle);
                }
            }
        }
    }
}
