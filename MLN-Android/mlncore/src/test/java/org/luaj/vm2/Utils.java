package org.luaj.vm2;

import org.junit.Assert;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019-06-17
 */
public class Utils {
    private static final String TEST_DIR = "src/test";
    private static final String ASSETS_PATH = "assets";
    private static final String LIB_PATH = "src/test/lib";
    private static final String LIBNAME = "libluajapi.so";

    static void loadLibrary() {
        loadLibrary(LIBNAME);
    }

    public static void loadLibrary(String lib) {
        final String SO_PATH = getLibPath() + File.separator + lib;
        System.load(SO_PATH);
    }

    static void onGlobalsDestroy() {
        long mem = Globals.getAllLVMMemUse();
        if (mem > 0) {
            Globals.logMemoryLeakInfo();
        }
        Assert.assertEquals(0, mem);
    }

    static String getTestDir() {
        return System.getProperty("user.dir") /*+ File.separator + TEST_DIR*/;
    }

    public static String getAssetsPath() {
        return getTestDir() + File.separator + ASSETS_PATH;
    }

    static String getLibPath() {
        return getTestDir() + File.separator + LIB_PATH;
    }
}
