package com.immomo.mls;

import org.junit.Test;

import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.junit.Assert.*;

/**
 * Created by Xiong.Fangyu on 2019-07-26
 */
public class HotReloadTest {

    @Test
    public void testIPPattern() {
        final String[] strs = {
                "123.211.211.111:1",
                "123.211.211.111:1231",
                "001.001.001.001:123145",
                "http://001.001.001.001:123145",
                "001.001.001.001:123145/ab",
                "123.211.211.111",
        };
        final boolean[] ips = {
                true,
                true,
                true,
                false,
                false,
                false,
        };

        for (int i = 0; i < strs.length; i ++) {
            Log.i(i);
            assertEquals(ips[i], HotReloadHelper.isIPPortString(strs[i]));
        }
    }

    @Test
    public void testParamsPattern() {
        final String[] strs = {
                "aa",
                "a=b",
                "aaa=bbb",
                "aaa==bbb",
                "aa&bb",
                "aaa=bbb&cc=dd",
                "aa=bb&&cc=dd",
                "aa=bb&&cc=dd&&ee=ff"
        };

        final HashMap<String, String>[] maps = new HashMap[]{
                null,
                newMap(new String[] {"a"}, new String[] {"b"}),
                newMap(new String[] {"aaa"}, new String[] {"bbb"}),
                null,
                null,
                newMap(new String[] {"aaa", "cc"}, new String[] {"bbb", "dd"}),
                null,
                null,
        };

        for (int i = 0; i < strs.length; i ++) {
            Log.i(i);
            HashMap<String, String> p = HotReloadHelper.parseParams(strs[i]);
            assertEquals(maps[i], p);
        }
    }

    private HashMap<String, String> newMap(String[] ks, String[] vs) {
        HashMap<String, String> ret = new HashMap<>();
        for (int i = 0; i < ks.length; i ++) {
            ret.put(ks[i], vs[i]);
        }
        return ret;
    }

    @Test
    public void testparseErrorString() {
        final String[] strs = {
                "[string \"LuaViewRootTest\"]",
                "[string \"LuaViewRootTest/a/b/c/entry\"]",
                "[string \"LuaViewRootTest\"] \n [string \"LuaViewRootTest/a/b/c/entry\"]"
        };

        final String[] rets = {
                "[string \"LuaViewRootTest.lua\"]",
                "[string \"LuaViewRootTest/a/b/c/entry.lua\"]",
                "[string \"LuaViewRootTest.lua\"] \n [string \"LuaViewRootTest/a/b/c/entry.lua\"]"
        };

        for (int i = 0; i < strs.length; i ++) {
            Log.i(i);
            assertEquals(rets[i], HotReloadHelper.parseErrorString(strs[i]));
        }
    }
}
