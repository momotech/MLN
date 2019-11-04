package com.immomo.mls.utils;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class ScriptLoadException extends Exception {

    private int code;
    private String msg;
    public ScriptLoadException(int code, String msg, Throwable cause) {
        super(cause);
        this.code = code;
        this.msg = msg;
    }

    public ScriptLoadException(ERROR e, Throwable cause) {
        this(e.code, e.msg, cause);
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }
}
