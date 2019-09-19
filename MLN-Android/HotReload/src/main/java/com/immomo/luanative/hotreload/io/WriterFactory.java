/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.io;

import com.immomo.luanative.hotreload.io.impl.WriterImpl;

public class WriterFactory {

    public static iWriter getInstance() {
        return new WriterImpl();
    }
}