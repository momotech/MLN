/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec.encode.impl;

import com.immomo.luanative.codec.PBCommandConvert;
import com.immomo.luanative.codec.encode.AbstractEncoder;
import com.immomo.luanative.codec.proto.PackageConst;
import com.immomo.luanative.codec.protobuf.PBPingCommand;
import com.immomo.luanative.codec.protobuf.PBPongCommand;

import java.nio.ByteBuffer;

public class EncoderImpl extends AbstractEncoder {
    @Override
    public byte[] encode(Object msg) {
        byte pkgType = PBCommandConvert.getPackageType(msg);
        switch (pkgType) {
            case PackageConst.MAGIC_PING: {
                return packPing((PBPingCommand.pbpingcommand)msg);
            }
            case PackageConst.MAGIC_PONG: {
                return packPong((PBPongCommand.pbpongcommand)msg);
            }
            case PackageConst.MAGIC_MESSAGE: {
                return packMessage(msg);
            }
            default: {
                System.out.println("未知类型消息");
            }
        }

        return null;
    }

    private byte[] packPing(PBPingCommand.pbpingcommand msg) {
        ByteBuffer b = ByteBuffer.allocate(PackageConst.HEADER_LENGTH_PONG + 1);
        // magic
        b.put(PackageConst.MAGIC_PONG);
        // ip
        b.put(packInt(msg.getIp()));
        // port
        b.put(packInt2Bit(msg.getIp()));
        // end
        b.put(PackageConst.MAGIC_END);
        return b.array();
    }

    private byte[] packPong(PBPongCommand.pbpongcommand msg) {
        ByteBuffer b = ByteBuffer.allocate(PackageConst.HEADER_LENGTH_PING + 1);
        // magic
        b.put(PackageConst.MAGIC_PING);
        // ip
        b.put(packInt(msg.getIp()));
        // port
        b.put(packInt2Bit(msg.getIp()));
        // end
        b.put(PackageConst.MAGIC_END);
        return b.array();
    }

    private byte[] packMessage(Object msg) {
        int bodyType = PBCommandConvert.getBodyType(msg);
        byte[] body = PBCommandConvert.convertFrom(msg);
        if (body!=null && body.length > 0) {
            ByteBuffer b = ByteBuffer.allocate(PackageConst.HEADER_LENGTH_MESSAGE + body.length + 1);
            // magic
            b.put(PackageConst.MAGIC_MESSAGE);
            // type
            b.put(packInt(bodyType));
            // body length
            b.put(packInt(body.length));
            // body
            b.put(body);
            // end
            b.put(PackageConst.MAGIC_END);
            return b.array();
        }
        return null;
    }
}