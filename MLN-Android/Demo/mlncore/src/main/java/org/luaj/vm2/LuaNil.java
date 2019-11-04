package org.luaj.vm2;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/2/21
 * <p>
 * Lua nil封装类
 * 使用{@link LuaValue#Nil()}获取
 * <p>
 * 不要随意修改！see luajapi.c
 */
@LuaApiUsed
class LuaNil extends LuaValue {
    private static volatile LuaNil NIL;

    @LuaApiUsed
    static LuaNil NIL() {
        if (NIL == null) {
            synchronized (LuaNil.class) {
                if (NIL == null) {
                    NIL = new LuaNil();
                }
            }
        }
        return NIL;
    }

    private LuaNil() {

    }

    @Override
    public int type() {
        return LUA_TNIL;
    }

    @Override
    public String toJavaString() {
        return null;
    }

    @Override
    public String toString() {
        return "nil";
    }

    @Override
    public boolean toBoolean() {
        return false;
    }
}
