package com.immomo.luanative.codec.decode;

public interface iDecoder {
    void push(byte[] data);
    void onDecoding(iDecodingListener listener);
}
