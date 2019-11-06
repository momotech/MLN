package com.immomo.mls.fun.ud.view;

import android.widget.CompoundButton;

import com.immomo.mls.fun.ui.LuaSwitch;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by zhang.ke
 * on 2018/12/18
 */
@LuaApiUsed
public class UDSwitch<L extends CompoundButton> extends UDView<L> implements CompoundButton.OnCheckedChangeListener {

    public static final String LUA_CLASS_NAME = "Switch";

    public static final String[] methods = {
            "on",
            "setSwitchChangedCallback",
    };

    private LuaFunction switchChangedCallback;

    @LuaApiUsed
    public UDSwitch(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected L newView(LuaValue[] init) {
        return (L) new LuaSwitch(getContext(), this, init);
    }

    @LuaApiUsed
    public LuaValue[] on(LuaValue[] on) {
        if (on.length == 0) {
            return varargsOf(LuaBoolean.valueOf((getView()).isChecked()));
        }
        getView().setChecked(on[0].toBoolean());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setSwitchChangedCallback(LuaValue[] fun) {
        switchChangedCallback = fun[0].toLuaFunction();
        if (fun != null) {
            getView().setOnCheckedChangeListener(this);
        } else {
            getView().setOnCheckedChangeListener(null);
        }
        return null;
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (switchChangedCallback != null) {
            switchChangedCallback.invoke(varargsOf(LuaBoolean.valueOf(isChecked)));
        }
    }
}
