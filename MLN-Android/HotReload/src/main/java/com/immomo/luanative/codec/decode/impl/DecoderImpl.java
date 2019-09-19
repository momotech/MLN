/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec.decode.impl;

//| MAGIC_SOH (1 byte) | Type (4 byte) | BodyLength (4byte) | ...|
//| MAGIC_SOH (1 byte) | MAGIC_SOH (1 byte) | BodyLength (4byte) | ...|

import com.immomo.luanative.codec.decode.AbstractDecoder;
import com.immomo.luanative.codec.decode.iDecodingListener;
import com.immomo.luanative.codec.proto.PackageConst;
import com.immomo.luanative.codec.protobuf.PBMessageFactory;
import com.immomo.luanative.util.LuaNativeUtil;

public class DecoderImpl extends AbstractDecoder {

    private byte[] rawData;
    private iDecodingListener listener;

    @Override
    public void push(byte[] data) {
        try {
            decode(data);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDecoding(iDecodingListener listener) {
        this.listener = listener;
    }

    public void decode(byte[] data) throws Exception {
        if (rawData != null) {
            rawData = LuaNativeUtil.mergeBytes(rawData, data);
        } else {
            rawData = data;
        }

        rawData = decodeMessage(rawData);
    }

    private byte[] decodeMessage(byte[] data) throws Exception {
        byte pkgType = unpackType(data);
        int headerLength = unpackHeaderLength(pkgType);
        int bodyType = unpackBodyType(data, pkgType);
        int bodyLength = unpackBodyLength(data, pkgType);
        int completedLength = headerLength + bodyLength + 1;
        if (data.length > completedLength) {
            // 多余一个包
            int remainLength = data.length - completedLength;
            byte[] remainData = LuaNativeUtil.getBytes(data, completedLength, remainLength);
            byte[] completedData = LuaNativeUtil.getBytes(data, headerLength, bodyLength);
            Object obj = PBMessageFactory.getInstance(bodyType, completedData);
            if (listener != null) {
                listener.onDecoding(obj);
            }
            return decodeMessage(remainData);
        } else if(data.length == completedLength) {
            // 一个完整的包
            byte[] packageData = LuaNativeUtil.getBytes(data, headerLength, bodyLength);
            Object obj = PBMessageFactory.getInstance(bodyType, packageData);
            if (listener != null) {
                listener.onDecoding(obj);
            }
            return null;
        }
        return data;
    }

    private byte unpackType(byte[] data) throws Exception {
        if (data.length > PackageConst.INDEX_MAGIC) {
            return data[PackageConst.INDEX_MAGIC];
        }
        return -1;
    }

    private int unpackHeaderLength(int pkgType) throws Exception {
        switch (pkgType) {
            case PackageConst.MAGIC_PING:
                return PackageConst.HEADER_LENGTH_PING;
            case PackageConst.MAGIC_PONG:
                return PackageConst.HEADER_LENGTH_PONG;
            case PackageConst.MAGIC_MESSAGE:
                return PackageConst.HEADER_LENGTH_MESSAGE;
                default:
                    return -1;
        }
    }


    private int unpackBodyType(byte[] data, int pkgType) throws Exception {
        switch (pkgType) {
            case PackageConst.MAGIC_PING:
                return PackageConst.HEADER_LENGTH_PING;
            case PackageConst.MAGIC_PONG:
                return PackageConst.HEADER_LENGTH_PONG;
            default:
                return unpackInt(data, PackageConst.INDEX_MESSAGE_BODY_TYPE_START, PackageConst.INDEX_MESSAGE_BODY_TYPE_END);
        }
    }

    private int unpackBodyLength(byte[] data, int pkgType) throws Exception {
        switch (pkgType) {
            case PackageConst.MAGIC_PING:
            case PackageConst.MAGIC_PONG:
                return 0;
            default:
                return unpackInt(data, PackageConst.INDEX_MESSAGE_BODY_LENGTH_START, PackageConst.INDEX_MESSAGE_BODY_LENGTH_END);
        }
    }
}