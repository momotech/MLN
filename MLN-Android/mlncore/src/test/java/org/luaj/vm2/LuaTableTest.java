package org.luaj.vm2;


import com.immomo.mlncore.Log;

import org.junit.Before;
import org.junit.Test;
import org.luaj.vm2.utils.DisposableIterator;

import static org.junit.Assert.*;

/**
 * Created by Xiong.Fangyu on 2019-06-14
 */
public class LuaTableTest extends BaseLuaTest {
    private LuaTable baseTable;

    @Before
    public void initBaseTable() {
        initGlobals(false);
        baseTable = LuaTable.create(globals);
    }

    @Test
    public void BaseTest() {

        baseTable.set(1, "string");
        baseTable.set(2, true);
        baseTable.set(3, 1);
        baseTable.set("1", "string1");
        baseTable.set("2", false);
        baseTable.set("3", 3);
        assertEquals(6, baseTable.size());

        checkStackSize(1);

        assertTrue(baseTable.get(1).isString());
        assertEquals("string", baseTable.get(1).toJavaString());
        assertTrue(baseTable.get(2).isBoolean());
        assertTrue(baseTable.get(2).toBoolean());
        assertTrue(baseTable.get(3).isNumber());
        assertEquals(1, baseTable.get(3).toInt());

        checkStackSize(1);

        assertTrue(baseTable.get("1").isString());
        assertEquals("string1", baseTable.get("1").toJavaString());
        assertTrue(baseTable.get("2").isBoolean());
        assertTrue(!baseTable.get("2").toBoolean());
        assertTrue(baseTable.get(3).isNumber());
        assertEquals(3, baseTable.get("3").toInt());

        checkStackSize(1);
    }

    @Test
    public void TestTraverse() {
        BaseTest();
        testKVs(6);
        testIterator(6);
    }

    private void testKVs(int len) {
        LuaTable.Entrys entrys = baseTable.newEntry();
        assertEquals(len, entrys.length());

        for (LuaTable.KV kv : entrys) {
            Log.f("%s", kv);
        }

        checkStackSize(1);
    }

    private void testIterator(int len) {
        int index = 0;
        DisposableIterator<LuaTable.KV> iterator = baseTable.iterator();
        while (iterator.hasNext()) {
            LuaTable.KV kv = iterator.next();
            index ++;
            Log.f("%s", kv);
        }
        iterator.dispose();
        assertEquals(len, index);

        checkStackSize(1);
    }
}
