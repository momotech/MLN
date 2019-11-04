package com.immomo.luanative.hotreload.io;

import java.util.concurrent.Callable;

public interface iReader {
    public void read(byte[] data);
    public void onMessage(iMessageListener listener);
}
