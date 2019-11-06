package com.immomo.luanative.hotreload;

public class HotReloadServer implements IHotReloadServer {

    //
    //    ---------- 单例
    //
    private static final HotReloadServer ourInstance = new HotReloadServer();

    public static HotReloadServer getInstance() {
        return ourInstance;
    }

    private HotReloadServer() {

    }

    //
    //    ---------- 开放接口
    //
    public void setupUSB(int usbPort) {
    }

    public void setListener(iHotReloadListener l) {
    }

    public void start() {

    }

    public void stop() {

    }

    public void log(String log) {

    }

    public void error(String error) {

    }

    public String getEntryFilePath() {
        return null;
    }

    public String getParams() {
        return null;
    }

    public void startNetClient(String ip, int port) {
    }
}
