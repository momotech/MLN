/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.MemoryMonitor;

/**
 * Created by Xiong.Fangyu on 2019-05-17
 */
public class MemoryListener implements MemoryMonitor.GlobalMemoryListener {
    @Override
    public void onInfo(long memSize) {
        if (memSize <= 0)
            return;
        MLSAdapterContainer.getConsoleLoggerAdapter().e("MemoryListener",
                "%d lua VMs use memory: %s",
                Globals.getLuaVmSize(),
                MemoryMonitor.getMemorySizeString(memSize));
        if (Globals.getLuaVmSize() == 0) {
            Globals.logMemoryLeakInfo();
        }
    }
}