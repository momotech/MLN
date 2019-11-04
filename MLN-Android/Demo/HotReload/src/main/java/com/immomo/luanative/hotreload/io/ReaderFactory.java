package com.immomo.luanative.hotreload.io;

import com.immomo.luanative.hotreload.io.impl.ReaderImpl;

public class ReaderFactory {


    public static iReader getInstance() {
        return new ReaderImpl();
    }
}
