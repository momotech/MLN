/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.transport;

import com.immomo.luanative.hotreload.transport.impl.NetTransporter;
import com.immomo.luanative.hotreload.transport.impl.USBTransporter;

public class TransporterFactory {

    public static iTransporter getInstance(int port) {
        return new USBTransporter(port);
    };

    public static iTransporter getInstance(String ip, int port) {
        return new NetTransporter(ip, port);
    };
}