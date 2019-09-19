/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec.decode;

import com.immomo.luanative.codec.decode.impl.DecoderImpl;

public class DecoderFactory {

    public static iDecoder getInstance(iDecodingListener listener) {
        iDecoder decoder = new DecoderImpl();
        decoder.onDecoding(listener);
        return decoder;
    }
}