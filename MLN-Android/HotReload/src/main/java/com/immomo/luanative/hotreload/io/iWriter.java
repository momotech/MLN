/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload.io;

public interface iWriter {
    public void writeData(byte[] data);
    public void writeLog(String log, String entryFilePath);
    public void writeError(String error, String entryFilePath);
    public void writeDevice();

    public byte[] popData();
}