package com.mln.demo.mln.anr;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import java.util.Arrays;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Created by Xiong.Fangyu on 2019/3/27
 * <p>
 * ANR检测工具
 *
 * @see #startWatch()                  开始检测
 * @see #setAnrListener(AnrListener)   设置anr监听
 * @see #setTimeout(long)              设置超时时长，默认5S
 * @see #setNeedSleepTimeout(long)     设置超时时长过小时，检测增加间隔时间
 * @see #setSleepTime(long)            设置检测间隔
 */
public class AnrWatchDog extends Thread {
    private static final String TAG = "AnrWatchDog";
    private static final long DEFAULT_TIMEOUT = 5000;
    private static final long DEFAULT_SLEEP_TIMEOUT = 100;
    private static final long DEFAULT_SLEEP_TIME = 1000;
    private static final int MSG_CHECK = 1;

    private long timeout;           //ms
    private long needSleepTimeout;  //ms
    private long sleepTime;         //ms

    private AnrListener anrListener;
    private final H anrChecker;
    private final Lock lock;
    private final Condition condition;
    private volatile long mainThreadTime = 0;

    private static volatile AnrWatchDog anrWatchDog;

    /**
     * 开始检测
     *
     * @return 返回单例
     */
    public static AnrWatchDog startWatch() {
        if (anrWatchDog == null) {
            synchronized (AnrWatchDog.class) {
                if (anrWatchDog == null) {
                    anrWatchDog = new AnrWatchDog(DEFAULT_TIMEOUT, DEFAULT_SLEEP_TIMEOUT, DEFAULT_SLEEP_TIME);
                    anrWatchDog.start();
                }
            }
        }
        return anrWatchDog;
    }

    /**
     * 设置anr监听
     */
    public AnrWatchDog setAnrListener(AnrListener listener) {
        this.anrListener = listener;
        return this;
    }

    /**
     * 设置超时时长
     *
     * @param timeout 单位ms
     */
    public AnrWatchDog setTimeout(long timeout) {
        this.timeout = timeout;
        return this;
    }

    /**
     * 设置超时时长过小时，检测增加间隔时间
     *
     * @param timeout 单位ms
     */
    public AnrWatchDog setNeedSleepTimeout(long timeout) {
        this.needSleepTimeout = timeout;
        return this;
    }

    /**
     * 设置间隔时间
     *
     * @param sleepTime 单位ms
     */
    public AnrWatchDog setSleepTime(long sleepTime) {
        this.sleepTime = sleepTime;
        return this;
    }

    private AnrWatchDog(long timeout, long needSleepTimeout, long sleepTime) {
        super(TAG);
        lock = new ReentrantLock();
        condition = lock.newCondition();
        anrChecker = new H();
        this.timeout = timeout;
        this.needSleepTimeout = needSleepTimeout;
        this.sleepTime = sleepTime;
    }

    @Override
    public void run() {
        while (true) {
            try {
                lock.lock();
                long now = now();
                mainThreadTime = 0;
                anrChecker.sendEmptyMessage(MSG_CHECK);
                condition.await(timeout, TimeUnit.MILLISECONDS);
                long cast = mainThreadTime == 0 ? (now() - now) : (mainThreadTime - now);
                if (cast >= timeout) {
                    anrHappened(cast);
                } else if (cast < needSleepTimeout) {
                    Thread.sleep(sleepTime);
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
                threadInterrupted();
                return;
            } finally {
                lock.unlock();
            }
        }
    }

    private void threadInterrupted() {
        Thread main = Looper.getMainLooper().getThread();
        StackTraceElement[] stacks = main.getStackTrace();
        Log.d(TAG, "threadInterrupted: " + Arrays.toString(stacks));
    }

    private void anrHappened(long cast) {
        Thread main = Looper.getMainLooper().getThread();
        StackTraceElement[] stacks = main.getStackTrace();
        if (anrListener != null) {
            anrListener.anrMaybeHappened(cast, stacks);
            return;
        }
        Log.d(TAG, getLogString(cast, stacks));
    }

    public static String getLogString(long timeout, StackTraceElement[] stacks) {
        final StringBuilder sb = new StringBuilder("ANR may happened, main thread timeout: ").append(timeout).append("ms.\n");
        for (StackTraceElement s : stacks) {
            sb.append(s).append('\n');
        }
        return sb.toString();
    }

    private static long now() {
        return System.currentTimeMillis();
    }

    private final class H extends Handler {
        private H() {
            super(Looper.getMainLooper());
        }

        @Override
        public void handleMessage(Message msg) {
            try {
                lock.lock();
                mainThreadTime = now();
                condition.signalAll();
            } finally {
                lock.unlock();
            }
        }
    }

    public interface AnrListener {
        void anrMaybeHappened(long timeout, StackTraceElement[] stacks);
    }
}
