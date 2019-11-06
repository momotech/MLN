package org.luaj.vm2;

import com.immomo.mls.UDTest;
import com.immomo.mls.wrapper.Register;

import org.junit.Test;

import java.io.File;

import static org.junit.Assert.*;

/**
 * Created by Xiong.Fangyu on 2019-06-18
 */
public class IsolateTest extends BaseLuaTest {

    private static final String IsolateLua = "test_isolate.lua";

    protected void registerBridge() {
        register.registerUserdata(Register.newUDHolder("UDTest", UDTest.class, false, "test"));
    }

    @Test
    public void loadIsolateLua() throws InterruptedException {
        initGlobals(true);
        String path = Utils.getAssetsPath() + File.separator + IsolateLua;

        assertTrue(globals.loadFile(path, IsolateLua));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);

        assertTrue(quitLooperDelay(1000));
    }
}
