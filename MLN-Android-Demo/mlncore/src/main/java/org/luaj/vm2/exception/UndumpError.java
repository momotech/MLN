package org.luaj.vm2.exception;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/3/14
 *
 * for native
 */
@LuaApiUsed
public class UndumpError extends RuntimeException {

    @LuaApiUsed
    public UndumpError(String msg) {
        super(msg);
    }
}
