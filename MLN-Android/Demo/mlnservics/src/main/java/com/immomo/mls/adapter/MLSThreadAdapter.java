package com.immomo.mls.adapter;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public interface MLSThreadAdapter {
    enum Priority {
        HIGH,
        MEDIUM,
        LOW
    }

    void execute(Priority p, Runnable action);

    void executeTaskByTag(Object tag, Runnable task);

    void cancelTask(Object tag, Runnable task);

    void cancelTaskByTag(Object tag);
}
