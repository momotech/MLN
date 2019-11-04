package com.immomo.luanative.hotreload.io;

public interface iWriter {
    public void writeData(byte[] data);
    public void writeLog(String log, String entryFilePath);
    public void writeError(String error, String entryFilePath);
    public void writeDevice();

    public byte[] popData();
}
