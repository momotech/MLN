package com.immomo.mls.fun.ud.view.recycler;

import com.immomo.mls.fun.ud.view.UDSwitch;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

@LuaApiUsed
public class UDListAutoFitAdapter extends UDListAdapter {
    public static final String LUA_CLASS_NAME = "TableViewAutoFitAdapter";

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDListAutoFitAdapter.class))
    })
    public UDListAutoFitAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}
