/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.client;

public interface iClientListener {

    public void clientOnConnected(iClient client);
    public void clientDisconnectedWithError(iClient client, String msg);
}