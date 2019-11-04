package com.immomo.mls;

/**
 * Created by XiongFangyu on 2018/8/15.
 */
public interface ScriptStateListener {
    enum Reason{
        LOAD_FAILED,
        EXCUTE_FAILED,
    }

    void onSuccess();

    void onFailed(Reason reason);
}
