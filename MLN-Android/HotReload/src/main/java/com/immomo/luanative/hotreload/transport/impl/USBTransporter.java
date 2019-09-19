/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.transport.impl;

import com.immomo.luanative.hotreload.transport.iTransporter;
import com.immomo.luanative.hotreload.transport.iTransporterListener;
import com.immomo.luanative.codec.encode.EncoderFactory;
import com.immomo.luanative.codec.PBCommandFactory;
import com.immomo.luanative.codec.protobuf.PBDeviceCommand;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class USBTransporter implements iTransporter, Runnable {

    private int port;
    private iTransporterListener listener;
    private ExecutorService executorService = Executors.newFixedThreadPool(2);
    private DataOutputStream output;
    private boolean isStopped = true;

    public USBTransporter(int port) {
        this.port = port;
    }

    @Override
    public void start(iTransporterListener listener) {
        this.listener = listener;
        if (isStopped) {
            synchronized (this) {
                if (isStopped) {
                    isStopped = false;
                    executorService.execute(this);
                }
            }
        }
    }

    @Override
    public void stop() {
        if (!isStopped) {
            synchronized (this) {
                if (!isStopped) {
                    isStopped = true;
                }
            }
        }
    }

    @Override
    public void run() {
        try {
            ServerSocket serverSocket = new ServerSocket(port);
            while (!isStopped) {
                Socket client = serverSocket.accept();
                client.setTcpNoDelay(true);
                if (listener != null) {
                    listener.onConnected();
                }
                output = new DataOutputStream(client.getOutputStream());
                // 开启新线程写
                executorService.execute(new Runnable() {
                    @Override
                    public void run() {
                        write();
                        output = null;
                    }
                });
                // 开启读
                read(client);
                // 走到这里就挂了
//                if (listener != null) {
//                    listener.disconnecte(null);
//                }
            }
        }
        catch (Exception e) {
            if (listener != null) {
                listener.disconnecte(e.getMessage());
            }
        }
    }

    private void write() {
        while (!isStopped) {
            if (listener != null) {
                byte[] data = listener.popSendData();
                if (data != null && data.length > 0) {
                    try {
                        output.write(data);
                    } catch (IOException e) {
                        e.printStackTrace();
//                        if (listener != null) {
//                            listener.disconnecte(e.getMessage());
//                        }
                        return;
                    }
                    try {
                        output.flush();
                    } catch (IOException e) {
//                        if (listener != null) {
//                            listener.disconnecte(e.getMessage());
//                        }
                        return;
                    }
                }
            }
        }
    }

    private void read(Socket client) {
        DataInputStream inputStream = null;
        try {
            inputStream = new DataInputStream(client.getInputStream());
        } catch (IOException e) {
//            if (listener != null) {
//                listener.disconnecte(e.getMessage());
//            }
            return;
        }
        byte[] buffer = new byte[1024*1024];
        while (!isStopped) {
            int readSize = 0;
            try {
                readSize = inputStream.read(buffer);
            } catch (IOException e) {
                e.printStackTrace();
//                if (listener != null) {
//                    listener.disconnecte(e.getMessage());
//                }
                return;
            }
            if (readSize < 0) {
//                if (listener != null) {
//                    listener.disconnecte(null);
//                }
                return;
            }
            if (readSize > 0) {
                ByteBuffer bf = ByteBuffer.allocate(readSize);
                bf.put(buffer, 0, readSize);
                if (listener != null) {
                    listener.didReceiveData(bf.array());
                }
                bf.clear();
            }
        }
    }
}