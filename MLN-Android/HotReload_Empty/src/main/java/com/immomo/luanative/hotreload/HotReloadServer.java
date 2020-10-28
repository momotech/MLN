/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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

    @Override
    public void onReport(String summaryPath, String detailPath) {

    }

    public void setSerial(String serial) {}

    public String getSerial() {
        return null;
    }
}