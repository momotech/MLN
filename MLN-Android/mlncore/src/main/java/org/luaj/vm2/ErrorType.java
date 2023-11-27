package org.luaj.vm2;

import androidx.annotation.NonNull;

/**
 * Created by Xiong.Fangyu on 2021/3/3
 */
public enum ErrorType {
    /**
     * 没有错误或其他未知错误
     */
    no,
    /**
     * 调用bridge报错，一般由java层bridge引起
     */
    bridge,
    /**
     * require报错
     */
    require,
    /**
     * lua代码异常
     */
    lua;

    @NonNull
    @Override
    public String toString() {
        final String name = name();
        if (name.equals("no"))
            return "unknown";
        return name;
    }
}
