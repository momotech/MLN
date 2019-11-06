package org.luaj.vm2.sqlite;

import org.junit.Test;
import org.luaj.vm2.BaseLuaTest;
import org.luaj.vm2.Utils;

import java.io.File;

import static org.junit.Assert.assertTrue;

/**
 * Created by Xiong.Fangyu on 2019-07-09
 */
public class SqliteTest extends BaseLuaTest {
    private static final String Simple = "simple.lua";
    private static final String Smart = "smart.lua";

    @Test
    public void simple() {
//        File f = new File("test.db");
//        if (f.exists()) f.delete();
        initGlobals(false);
        String path = getSqliteTestPath() + Simple;

        assertTrue(globals.loadFile(path, Simple));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);
    }

    @Test
    public void smart() {
        File f = new File("test.db");
        if (f.exists()) f.delete();
        initGlobals(false);
        String path = getSqliteTestPath() + Smart;

        assertTrue(globals.loadFile(path, Smart));
        assertTrue(globals.callLoadedData());

        checkStackSize(1);
    }

    private static String getSqliteTestPath() {
        return Utils.getAssetsPath() + File.separator + "sqlite" + File.separator;
    }
}
