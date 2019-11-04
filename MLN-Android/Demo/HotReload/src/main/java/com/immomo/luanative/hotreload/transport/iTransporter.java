package com.immomo.luanative.hotreload.transport;

public interface iTransporter {
    public void start(iTransporterListener listener);
    public void stop();
}
