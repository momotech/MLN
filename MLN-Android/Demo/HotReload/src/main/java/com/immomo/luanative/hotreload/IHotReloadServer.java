package com.immomo.luanative.hotreload;

/**
 * Created by Xiong.Fangyu on 2019-07-30
 */
public interface IHotReloadServer {

    /**
     * 网络连接类型为USB连接.
     */
    public static final int USB_CONNECTION = 1;

    /**
     * 网咯连接类型为NET连接.
     */
    public static final int NET_CONNECTION = 2;

    public void setupUSB(int usbPort);

    public void setListener(iHotReloadListener l);

    public void start();

    public void stop();

    public void log(String log);

    public void error(String error);

    public String getEntryFilePath();

    public String getParams();

    public void startNetClient(String ip, int port);
}
