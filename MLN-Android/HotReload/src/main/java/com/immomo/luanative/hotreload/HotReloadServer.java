/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload;

import com.immomo.luanative.codec.PBCommandFactory;
import com.immomo.luanative.codec.encode.EncoderFactory;
import com.immomo.luanative.codec.encode.iEncoder;
import com.immomo.luanative.codec.protobuf.PBCoverageVisualCommand;
import com.immomo.luanative.codec.protobuf.PBCreateCommand;
import com.immomo.luanative.codec.protobuf.PBEntryFileCommand;
import com.immomo.luanative.codec.protobuf.PBIPAddressCommand;
import com.immomo.luanative.codec.protobuf.PBMoveCommand;
import com.immomo.luanative.codec.protobuf.PBReloadCommand;
import com.immomo.luanative.codec.protobuf.PBRemoveCommand;
import com.immomo.luanative.codec.protobuf.PBRenameCommand;
import com.immomo.luanative.codec.protobuf.PBUpdateCommand;
import com.immomo.luanative.hotreload.client.ClientFactory;
import com.immomo.luanative.hotreload.client.iClient;
import com.immomo.luanative.hotreload.client.iClientListener;
import com.immomo.luanative.hotreload.io.iMessageListener;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * The type Hot reload server.
 */
public class HotReloadServer implements IHotReloadServer {

    //
    //    ---------- 成员变量
    //
    private iClient netClient;
    private iClient usbClient;
    private iClient currentClient;
    private iHotReloadListener listener;
    private boolean isStopped = true;
    private int usbPort = 8176;
    private String entryFilePath;
    private String relativeEntryFilePath;
    private String params;

    //
    //    ---------- 单例
    //
    private static final HotReloadServer ourInstance = new HotReloadServer();

    /**
     * Gets instance.
     *
     * @return the instance
     */
    public static HotReloadServer getInstance() {
        return ourInstance;
    }

    private HotReloadServer() {

    }

    /**
     * 需要改变默认USB端口时候调用.
     *
     * @param usbPort the usb port
     */
    public void setupUSB(int usbPort) {
        this.usbPort = usbPort;
        restartUsbClient();
    }

    @Override
    public void setListener(iHotReloadListener l) {
        this.listener = l;
    }

    @Override
    public void start() {
        if (isStopped) {
            synchronized (this) {
                if (isStopped) {
                    startUsbClient();
                    isStopped = false;
                }
            }
        }
    }

    /**
     * 启动HotReload 服务.
     * @note 如果USB服务未开启，则开启USB服务，如果已开启USB，则不会重复开启。
     *
     * @param listener the listener
     */
    public void start(iHotReloadListener listener) {
        this.listener = listener;
        if (isStopped) {
            synchronized (this) {
                if (isStopped) {
                    startUsbClient();
                    isStopped = false;
                }
            }
        }
    }

    /**
     * 停止HotReload 服务.
     */
    public void stop() {
        if (!isStopped) {
            synchronized (this) {
                if (!isStopped) {
                    isStopped = true;
                }
            }
        }
    }

    /**
     * 打印log到远端控制台.
     *
     * @param log the log
     */
    public void log(String log) {
        if (currentClient != null) {
            currentClient.writeLog(log, getEntryFilePath());
        }
    }

    /**
     * 打印error信息到远端控制台.
     *
     * @param error the error
     */
    public void error(String error) {
        if (currentClient != null) {
            currentClient.writeError(error, getEntryFilePath());
        }
    }

    private iEncoder encoder = EncoderFactory.getInstance();

    private void writeMsg(Object msg) {
        if (currentClient != null) {
            currentClient.writeData(encoder.encode(msg));
        }
    }

    /**
     * 获取入口文件的相对路径.
     *
     * @return the relative entry file path
     */
    public String getRelativeEntryFilePath() {
        synchronized (this) {
            return relativeEntryFilePath;
        }
    }

    /**
     * 获取入口文件的全路径.
     *
     * @return the entry file path
     */
    public String getEntryFilePath() {
        synchronized (this) {
            return entryFilePath;
        }
    }

    /**
     * 获取要传入lua的参数.
     *
     * @return the params
     */
    public String getParams() {
        synchronized (this) {
            return params;
        }
    }

    /**
     * 尝试开启net连接.
     *
     * @param ip   the ip
     * @param port the port
     */
    public void startNetClient(String ip, int port) {
        if (netClient != null && netClient.isRunning()) return;
        netClient = ClientFactory.getInstance(ip, port, new HotReloadClientListener(NET_CONNECTION, ip, port));
        netClient.onMessage(new iMessageListener() {
            @Override
            public <T> void onRecive(T msg) {
                // 重置当前客户端
                currentClient = netClient;
                handleMessage(msg);
            }
        });
        boolean ret = netClient.start();
        if (!ret) {
            if (listener != null) {
                listener.disconnecte(NET_CONNECTION, ip, port, null);
            }
            return;
        }
    }

    private byte[] readFile(File file) {
        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(file);
            byte[] buffer = new byte[2048];
            int bytesRead;
            final ByteArrayOutputStream output = new ByteArrayOutputStream();
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            return output.toByteArray();
        } catch (IOException ignore) {
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (Throwable ignore) {}
            }
        }
        return null;
    }

    @Override
    public void onReport(String summaryPath, String detailPath) {
        if (summaryPath != null) {
            File file = new File(summaryPath);
            if (file.isFile()) {
                byte[] data = readFile(file);
                if (data != null) {
                    writeMsg(PBCommandFactory.getSummaryCommand(summaryPath, data));
                }
            }
        }
        if (detailPath != null) {
            File file = new File(detailPath);
            if (file.isFile()) {
                byte[] data = readFile(file);
                if (data != null)
                    writeMsg(PBCommandFactory.getDetailCommand(detailPath, data));
            }
        }
    }

    @Override
    public void setSerial(String serial) {
        PBCommandFactory.Serial = serial;
    }

    @Override
    public String getSerial() {
        return PBCommandFactory.Serial;
    }

    //
    //    ---------- usb client
    //
    private void startUsbClient() {
        if (usbClient != null && usbClient.isRunning()) return;
        usbClient = ClientFactory.getInstance(usbPort, new HotReloadClientListener(USB_CONNECTION, null, usbPort));
        usbClient.onMessage(new iMessageListener() {
            @Override
            public <T> void onRecive(T msg) {
                // 重置当前客户端
                currentClient = usbClient;
                handleMessage(msg);
            }
        });
        boolean ret = usbClient.start();
        if (!ret) {
            if (listener != null) {
                listener.disconnecte(USB_CONNECTION, null, usbPort, null);
            }
            return;
        }
    }

    private void restartUsbClient() {
        if (usbClient != null)
            usbClient.stop();
        startUsbClient();
    }

    private <T> void handleMessage(T msg) {
        if (listener == null) return;

        if (msg instanceof PBUpdateCommand.pbupdatecommand) {
            // 文件更新
            PBUpdateCommand.pbupdatecommand cmd = (PBUpdateCommand.pbupdatecommand) msg;
            listener.onFileUpdate(cmd.getFilePath(), cmd.getRelativeFilePath(), cmd.getFileData().newInput());
        } else if (msg instanceof PBEntryFileCommand.pbentryfilecommand) {
            // 入口文件
            PBEntryFileCommand.pbentryfilecommand cmd = (PBEntryFileCommand.pbentryfilecommand) msg;
            updateEntryFile(cmd.getEntryFilePath(), cmd.getRelativeEntryFilePath(), cmd.getParams());
        } else if (msg instanceof PBCreateCommand.pbcreatecommand) {
            // 创建文件
            PBCreateCommand.pbcreatecommand cmd = (PBCreateCommand.pbcreatecommand) msg;
            listener.onFileCreate(cmd.getFilePath(), cmd.getRelativeFilePath(), cmd.getFileData().newInput());
        } else if (msg instanceof PBRemoveCommand.pbremovecommand) {
            // 删除文件
            PBRemoveCommand.pbremovecommand cmd = (PBRemoveCommand.pbremovecommand) msg;
            listener.onFileDelete(cmd.getFilePath(), cmd.getRelativeFilePath());
        } else if (msg instanceof PBRenameCommand.pbrenamecommand) {
            // 重命名文件 或 文件夹
            PBRenameCommand.pbrenamecommand cmd = (PBRenameCommand.pbrenamecommand) msg;
            listener.onFileRename(cmd.getOldFilePath(), cmd.getOldRelativeFilePath(), cmd.getNewFilePath(), cmd.getNewRelativeFilePath());
        }  else if (msg instanceof PBMoveCommand.pbmovecommand) {
            // 移动文件 或 文件夹
            PBMoveCommand.pbmovecommand cmd = (PBMoveCommand.pbmovecommand) msg;
            listener.onFileMove(cmd.getOldFilePath(), cmd.getOldRelativeFilePath(), cmd.getNewFilePath(), cmd.getNewRelativeFilePath());
        } else if (msg instanceof PBReloadCommand.pbreloadcommand) {
            // 刷新

            listener.onReload(getEntryFilePath(), getRelativeEntryFilePath(), getParams());
        } else if (msg instanceof PBCoverageVisualCommand.pbcoveragevisualcommand) {
            listener.onGencoveragereport();
        } else if (msg instanceof PBIPAddressCommand.pbipaddresscommand) {
            PBIPAddressCommand.pbipaddresscommand cmd = (PBIPAddressCommand.pbipaddresscommand) msg;
            String ip = cmd.getMacIPAddress();
            listener.onIpChanged(ip);
        }
    }

    private void updateEntryFile(String entryFilePath, String relativeEntryFilePath, String params) {
        synchronized (this) {
            this.entryFilePath = entryFilePath;
            this.relativeEntryFilePath = relativeEntryFilePath;
            this.params = params;
        }
    }

    /**
     * client监听者.
     */
    private class HotReloadClientListener implements iClientListener {

        /**
         * The Connection type.
         */
        int connectionType;
        /**
         * The Ip.
         */
        String ip;
        /**
         * The Port.
         */
        int port;

        /**
         * Instantiates a new Hot reload client listener.
         *
         * @param type the type
         * @param ip   the ip
         * @param port the port
         */
        HotReloadClientListener(int type, String ip, int port) {
            connectionType = type;
            this.ip = ip;
            this.port = port;
        }

        @Override
        public void clientOnConnected(iClient client) {
            if (HotReloadServer.this.listener != null) {
                HotReloadServer.this.listener.onConnected(connectionType, ip, port);
            }
        }

        @Override
        public void clientDisconnectedWithError(iClient client, String msg) {
            client.stop();
            if (HotReloadServer.this.listener != null) {
                HotReloadServer.this.listener.disconnecte(connectionType, ip, port, msg);
            }
        }
    }
}