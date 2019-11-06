package com.immomo.mls.utils;

import com.immomo.mls.wrapper.callback.Destroyable;

import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public interface LVCallback extends Destroyable{
    /**
     * callback to lua
     * @param params
     * @return true if call success
     */
    boolean call(@Nullable Object... params);
}
