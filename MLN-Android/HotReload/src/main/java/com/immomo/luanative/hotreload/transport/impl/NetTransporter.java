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
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class NetTransporter implements iTransporter, Runnable {

    private String ip;
    private int port;
    private iTransporterListener listener;
    private ExecutorService executorService = Executors.newFixedThreadPool(2);
    private SocketChannel channel;
    private boolean isStopped = true;


    public NetTransporter(String ip, int port) {
        this.ip = ip;
        this.port = port;
    }

    @Override
    public void start(iTransporterListener listener) {
        this.listener = listener;
        if (isStopped) {
            synchronized (this) {
                if (isStopped) {
                    executorService.execute(this);
                    isStopped = false;
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
            channel = SocketChannel.open();
            channel.configureBlocking(true);
            if (!channel.connect(new InetSocketAddress(this.ip, this.port))) {
                while (!channel.finishConnect()) {
                    System.out.print("连接中。。。");
                }
            }
            // 发送设备信息通过验证
            check();
            if (listener != null) {
                listener.onConnected();
            }
            // 开启新线程写
            executorService.execute(new Runnable() {
                @Override
                public void run() {
                    write();
                }
            });
            // 开启读
            read();
            // 走到这里就挂了
            if (listener != null) {
                listener.disconnecte(null);
            }
            channel.close();
            channel = null;
        } catch (Exception e) {
            if (listener != null) {
                listener.disconnecte(e.getMessage());
            }
        }
    }

    private void check() throws IOException {
        PBDeviceCommand.pbdevicecommand cmd = (PBDeviceCommand.pbdevicecommand) PBCommandFactory.getDeviceCommand();
        byte[] wdata = EncoderFactory.getInstance().encode(cmd);
        ByteBuffer wbf = ByteBuffer.wrap(wdata);
        while (wbf.remaining() > 0) {
            int len = channel.write(wbf);
            if (len < 0) {
                throw new IOException("写入失败");
            }
        }
        wbf.clear();
    }

    private void write() {
        while (!isStopped) {
            if (listener != null) {
                byte[] data = listener.popSendData();
                if (data != null) {
                    try {
                        ByteBuffer bf = ByteBuffer.wrap(data);
                        boolean isEnable = channel != null && channel.isConnected();
                        if (!isEnable) {
                            if (listener != null) {
                                stop();
                                listener.disconnecte("连接断开");
                                return;
                            }
                        }
                        while (bf.remaining() > 0 && isEnable) {
                            int len = channel.write(bf);
                            if (len < 0) {
                                if (listener != null) {
                                    stop();
                                    listener.disconnecte("连接断开");
                                    return;
                                }
                            }
                            System.out.println("+++ 总共" + data.length + " 发送了："+len);
                        }
                        bf.clear();
                    } catch (IOException e) {
                        if (listener != null) {
                            listener.disconnecte(e.getMessage());
                        }
                        return;
                    }
                }
            }
            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                if (listener != null) {
                    listener.disconnecte(e.getMessage());
                }
                return;
            }
        }
    }

    private void read() {
        ByteBuffer bf = ByteBuffer.allocate(1024*1024);
        while (!isStopped) {
            int readSize = 0;
            try {
                readSize = channel.read(bf);
            } catch (IOException e) {
                if (listener != null) {
                    listener.disconnecte(e.getMessage());
                }
                return;
            }
            if (readSize < 0) {
                if (listener != null) {
                    listener.disconnecte(null);
                }
                return;
            }

            if (readSize > 0) {
                byte[] data = new byte[readSize];
                bf.flip();
                bf.get(data);
                bf.clear();
                if (listener != null) {
                    listener.didReceiveData(data);
                }
                bf.clear();
            }
        }
    }
}