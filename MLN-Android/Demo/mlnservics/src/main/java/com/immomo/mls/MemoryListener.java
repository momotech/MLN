package com.immomo.mls;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.MemoryMonitor;

/**
 * Created by Xiong.Fangyu on 2019-05-17
 */
public class MemoryListener implements MemoryMonitor.GlobalMemoryListener {
    @Override
    public void onInfo(long memSize, long globalObjSize) {
        if (memSize <= 0 && globalObjSize <= 0)
            return;
        MLSAdapterContainer.getConsoleLoggerAdapter().e("MemoryListener",
                "%d lua VMs use memory: %s, and have %d global java objects.",
                Globals.getLuaVmSize(),
                MemoryMonitor.getMemorySizeString(memSize),
                globalObjSize);
        if (Globals.getLuaVmSize() == 0 && memSize > 0) {
            Globals.logMemoryLeakInfo();
        }
    }
}
