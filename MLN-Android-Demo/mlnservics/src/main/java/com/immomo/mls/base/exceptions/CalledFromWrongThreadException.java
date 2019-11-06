package com.immomo.mls.base.exceptions;

/**
 * Created by XiongFangyu on 2018/8/8.
 */
public class CalledFromWrongThreadException extends RuntimeException {
    public CalledFromWrongThreadException(String msg) {
        super(msg);
    }
}
