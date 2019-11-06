package com.immomo.mls.log;

/**
 * Created by XiongFangyu on 2018/9/6.
 */
public interface IPrinter {

    void print(String s);

    void println();

    void error(String s);

    void clear();
}
