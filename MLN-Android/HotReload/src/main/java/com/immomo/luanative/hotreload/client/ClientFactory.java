/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.client;

import com.immomo.luanative.hotreload.client.impl.ClientImpl;
import com.immomo.luanative.hotreload.transport.TransporterFactory;

public class ClientFactory {

    public static iClient getInstance(int port, iClientListener listener) {
        return new ClientImpl(TransporterFactory.getInstance(port), listener);
    }

    public static iClient getInstance(String ip, int port, iClientListener listener) {
        return new ClientImpl(TransporterFactory.getInstance(ip, port), listener);
    }
}