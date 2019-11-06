package com.immomo.luanative.hotreload.client;

import com.immomo.luanative.hotreload.io.iReader;
import com.immomo.luanative.hotreload.io.iWriter;
import com.immomo.luanative.hotreload.transport.iTransporterListener;

public interface iClient extends iWriter, iReader, iTransporterListener {
    public boolean start();
    public void stop();
    public boolean isRunning();
}
