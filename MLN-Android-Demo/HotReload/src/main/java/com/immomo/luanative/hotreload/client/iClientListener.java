package com.immomo.luanative.hotreload.client;

public interface iClientListener {

    public void clientOnConnected(iClient client);
    public void clientDisconnectedWithError(iClient client, String msg);
}
