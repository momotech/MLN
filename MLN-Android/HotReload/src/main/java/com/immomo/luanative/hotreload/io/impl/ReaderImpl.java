/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.io.impl;

import com.immomo.luanative.hotreload.io.iMessageListener;
import com.immomo.luanative.hotreload.io.iReader;
import com.immomo.luanative.codec.decode.DecoderFactory;
import com.immomo.luanative.codec.decode.iDecoder;
import com.immomo.luanative.codec.decode.iDecodingListener;

public class ReaderImpl implements iReader, iDecodingListener {

    private iDecoder decoder = DecoderFactory.getInstance(this);
    private iMessageListener listener;

    @Override
    public void read(byte[] data) {
        decoder.push(data);
    }

    @Override
    public void onMessage(iMessageListener listener) {
        this.listener = listener;
    }

    @Override
    public void onDecoding(Object obj) {
        if (listener != null) {
            listener.onRecive(obj);
        }
    }
}