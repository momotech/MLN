package com.immomo.luanative.hotreload.client;

import com.immomo.luanative.hotreload.client.impl.ClientImpl;
import com.immomo.luanative.hotreload.transport.TransporterFactory;

public class ClientFactory {

    public static iClient getInstance(int port, iClientListener listener) {
        return new ClientImpl(TransporterFactory.getInstance(port), listener);
    }

    public static iClient getInstance(String ip, int port, iClientListener listener) {
        return new ClientImpl(TransporterFactory.getInstance(ip, port), listener);
    }
}
