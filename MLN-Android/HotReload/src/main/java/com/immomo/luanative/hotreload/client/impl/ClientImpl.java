/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.client.impl;

import com.immomo.luanative.hotreload.client.iClient;
import com.immomo.luanative.hotreload.client.iClientListener;
import com.immomo.luanative.hotreload.io.ReaderFactory;
import com.immomo.luanative.hotreload.io.WriterFactory;
import com.immomo.luanative.hotreload.io.iMessageListener;
import com.immomo.luanative.hotreload.io.iReader;
import com.immomo.luanative.hotreload.io.iWriter;
import com.immomo.luanative.hotreload.transport.iTransporter;

public class ClientImpl implements iClient {

    private iReader reader = ReaderFactory.getInstance();
    private iWriter writer = WriterFactory.getInstance();
    private iTransporter transporter;
    private iClientListener listener;
    private boolean running = false;

    public ClientImpl(iTransporter transporter, iClientListener listener) {
        this.transporter = transporter;
        this.listener = listener;
    }

    @Override
    public boolean start() {
        if (running) return true;
        running = true;
        if (this.transporter != null) {
            this.transporter.start(this);
            return true;
        }
        return false;
    }

    @Override
    public void stop() {
        if (!running) return;
        running = false;
        if (this.transporter != null) {
            this.transporter.stop();
        }
    }

    @Override
    public boolean isRunning() {
        return running;
    }

    @Override
    public void read(byte[] data) {
        reader.read(data);
    }

    @Override
    public void onMessage(iMessageListener listener) {
        reader.onMessage(listener);
    }

    @Override
    public void writeData(byte[] data) {
        writer.writeData(data);
    }

    @Override
    public void writeLog(String log, String entryFilePath) {
        writer.writeLog(log, entryFilePath);
    }

    @Override
    public void writeError(String error, String entryFilePath) {
        writer.writeError(error, entryFilePath);
    }

    @Override
    public void writeDevice() {
        writer.writeDevice();
    }

    @Override
    public byte[] popData() {
        return writer.popData();
    }

    @Override
    public void onConnected() {
        if (listener != null) {
            listener.clientOnConnected(this);
        }
    }

    @Override
    public byte[] popSendData() {
        return writer.popData();
    }

    @Override
    public void didReceiveData(byte[] data) {
        reader.read(data);
    }

    @Override
    public void disconnecte(String error) {
        if (listener != null) {
            listener.clientDisconnectedWithError(this, error);
        }
    }
}