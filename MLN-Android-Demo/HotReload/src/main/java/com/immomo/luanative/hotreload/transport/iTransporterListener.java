package com.immomo.luanative.hotreload.transport;

public interface iTransporterListener {

    public void onConnected();
    public byte[] popSendData();
    public void didReceiveData(byte[] data);
    public void disconnecte(String error);
}
