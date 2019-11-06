package com.immomo.luanative.codec.encode;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public abstract class AbstractEncoder implements iEncoder{

    public byte[] packInt(int value) {
        ByteBuffer b = ByteBuffer.allocate(4);
        b.order(ByteOrder.BIG_ENDIAN);
        b.putInt(value);
        return b.array();
    }

    public byte[] packInt2Bit(int value) {
        short sv = (short) value;
        ByteBuffer b = ByteBuffer.allocate(2);
        b.order(ByteOrder.BIG_ENDIAN);
        b.putShort(sv);
        return b.array();
    }
}
