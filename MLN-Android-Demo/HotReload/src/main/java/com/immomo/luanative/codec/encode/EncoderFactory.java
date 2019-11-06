package com.immomo.luanative.codec.encode;

import com.immomo.luanative.codec.encode.impl.EncoderImpl;

public class EncoderFactory {
    public static iEncoder getInstance() {
        return new EncoderImpl();
    }
}
