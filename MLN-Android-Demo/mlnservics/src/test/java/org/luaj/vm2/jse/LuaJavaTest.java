package org.luaj.vm2.jse;

import org.junit.Test;
import org.luaj.vm2.BaseLuaTest;
import org.luaj.vm2.LuaTable;

import java.io.File;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/**
 * Created by Xiong.Fangyu on 2019-07-01
 */
public class LuaJavaTest extends BaseLuaTest {
    private static final String LuaJavaLua = "test_luajava.lua";
    @Test
    public void testLuaJava() {
        initGlobals(false);
        globals.registerLuaJava();

        String path = org.luaj.vm2.Utils.getAssetsPath() + File.separator + LuaJavaLua;

        assertTrue(globals.loadFile(path, LuaJavaLua));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);
    }


    @Test
    public void testUtilsToArray() {
        initGlobals(false);
        LuaTable table = LuaTable.create(globals);
        for (int i = 1; i <= 10; i ++) {
            table.set(i, i);
        }

        Object[] ret = Utils.toNativeArray(table, int.class);
        assertNotNull(ret);
        assertEquals(10, ret.length);
        for (int i = 0; i < 10; i ++) {
            assertEquals(i + 1, (int) ret[i]);
        }
    }
}
