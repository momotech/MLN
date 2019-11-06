package com.immomo.luanative.codec.decode;

import com.immomo.luanative.codec.decode.impl.DecoderImpl;

public class DecoderFactory {

    public static iDecoder getInstance(iDecodingListener listener) {
        iDecoder decoder = new DecoderImpl();
        decoder.onDecoding(listener);
        return decoder;
    }
}
