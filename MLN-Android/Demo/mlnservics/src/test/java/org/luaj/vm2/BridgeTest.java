package org.luaj.vm2;

import org.junit.Test;
import org.luaj.vm2.bridge.E1;
import org.luaj.vm2.bridge.E2;

import java.io.File;

import static org.junit.Assert.assertTrue;

/**
 * Created by Xiong.Fangyu on 2019-07-03
 */
public class BridgeTest extends BaseLuaTest {

    private static final String EnumPath = "test_enum.lua";
    private static final String MBitPath = "test_bit.lua";

    protected void registerBridge() {
        register.registerEnum(E1.class);
        register.registerEnum(E2.class);
    }

    @Test
    public void testEnum() {
        initGlobals(false);
        String path = Utils.getAssetsPath() + File.separator + EnumPath;

        assertTrue(globals.loadFile(path, EnumPath));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);
    }

    @Test
    public void testMBit() {
        initGlobals(false);
        String path = Utils.getAssetsPath() + File.separator + MBitPath;

        assertTrue(globals.loadFile(path, MBitPath));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);
    }
}
