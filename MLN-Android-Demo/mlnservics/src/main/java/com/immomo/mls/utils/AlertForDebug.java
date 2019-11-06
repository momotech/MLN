package com.immomo.mls.utils;

/**
 * Created by Xiong.Fangyu on 2019-09-17
 */
public class AlertForDebug extends Exception {

    public static AlertForDebug showInDebug(String s) {
        return new AlertForDebug("show in Debug Mode: " + s);
    }

    public AlertForDebug(String s) {
        super(s);
    }
}
