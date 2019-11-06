package com.immomo.mls;

import org.junit.Test;
import org.luaj.vm2.LuaNumber;

/**
 * Created by Xiong.Fangyu on 2019/3/29
 */
public class LuaNumberTest {
    @Test
    public void testValueOf() throws Exception {
        for (int i = -200 ; i < 200; i ++) {
            try {
                LuaNumber.valueOf(i);
            } catch (Throwable t) {
                System.out.println(i);
            }
        }
    }
}
