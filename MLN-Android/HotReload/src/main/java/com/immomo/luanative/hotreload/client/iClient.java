/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.client;

import com.immomo.luanative.hotreload.io.iReader;
import com.immomo.luanative.hotreload.io.iWriter;
import com.immomo.luanative.hotreload.transport.iTransporterListener;

public interface iClient extends iWriter, iReader, iTransporterListener {
    public boolean start();
    public void stop();
    public boolean isRunning();
}