package com.mln.demo.common;

import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;

/**
 * Created by Xiong.Fangyu on 2019-08-23
 */
@LuaClass
public class GCTest {
    private LuaTable table;

    public GCTest(Globals g) {
        table = LuaTable.create(g);
    }

    public void __onLuaGc() {
        LogUtil.d("GCTest", "__onLuaGc");
        table.destroy();
    }
}
