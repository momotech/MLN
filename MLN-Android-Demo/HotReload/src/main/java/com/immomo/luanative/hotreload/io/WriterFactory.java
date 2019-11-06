package com.immomo.luanative.hotreload.io;

import com.immomo.luanative.hotreload.io.impl.WriterImpl;

public class WriterFactory {

    public static iWriter getInstance() {
        return new WriterImpl();
    }
}
