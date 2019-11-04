package com.immomo.luanative.hotreload.transport;

import com.immomo.luanative.hotreload.transport.impl.NetTransporter;
import com.immomo.luanative.hotreload.transport.impl.USBTransporter;

public class TransporterFactory {

    public static iTransporter getInstance(int port) {
        return new USBTransporter(port);
    };

    public static iTransporter getInstance(String ip, int port) {
        return new NetTransporter(ip, port);
    };
}
