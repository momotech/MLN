/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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