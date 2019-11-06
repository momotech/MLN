package com.immomo.luanative.codec.decode;

public abstract class AbstractDecoder implements iDecoder {

    public int unpackInt(byte[] data, int start, int end) throws Exception {
        if (data.length < start || data.length < end) {
            throw new RuntimeException("PACK_LENGTH_ERROR");
        }
        int retval = 0;
        for (int i = start; i <= end; i++) {
            retval<<=8;
            retval |=(data[(i)] & 0xFF);
        }
        return retval;
    }

}
