package org.luaj.vm2.jse;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-10-15
 *
 * 注册jse相关对象
 */
public class JSERegister {

    public static void registerLuaJava(Globals g) {
        g.registerJavaMetatable(Luajava.class, Luajava.NAME);
        g.registerUserdataSimple(JavaInstance.LUA_CLASS_NAME, JavaInstance.class);
        g.registerUserdataSimple(JavaClass.LUA_CLASS_NAME, JavaClass.class);
    }
}
