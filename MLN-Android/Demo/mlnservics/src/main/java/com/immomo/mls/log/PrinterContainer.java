package com.immomo.mls.log;

/**
 * Created by XiongFangyu on 2018/9/6.
 */
public interface PrinterContainer {
    void showPrinter(boolean show);

    boolean isShowPrinter();

    boolean hasClosePrinter();

    IPrinter getSTDPrinter();

    void onSTDPrinterCreated(IPrinter p);
}
