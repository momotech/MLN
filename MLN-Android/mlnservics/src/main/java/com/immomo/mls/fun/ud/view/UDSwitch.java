/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.widget.CompoundButton;
import android.widget.Switch;

import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDStyleString;
import com.immomo.mls.fun.ui.LuaSwitch;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by zhang.ke
 * on 2018/12/18
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDSwitch<L extends CompoundButton> extends UDView<L> implements CompoundButton.OnCheckedChangeListener {

    public static final String LUA_CLASS_NAME = "Switch";

    public static final String[] methods = {
            "on",
            "setSwitchChangedCallback",
            "setThumbColor",
            "setNormalColor",
            "setSelectedColor"
    };

    private LuaFunction switchChangedCallback;

    private static final int[] CHECKED_STATE_SET = {
            android.R.attr.state_checked
    };

    private int defaultColor = Color.BLACK;
    private int selectColor = Color.RED;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public UDSwitch(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected L newView(LuaValue[] init) {
        return (L) new LuaSwitch(getContext(), this, init);
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Boolean.class)
            }, returns = @LuaApiUsed.Type(UDSwitch.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public LuaValue[] on(LuaValue[] on) {
        if (on.length == 0) {
            return varargsOf(LuaBoolean.valueOf((getView()).isChecked()));
        }
        getView().setChecked(on[0].toBoolean());
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = Function1.class, typeArgs = {
                            Boolean.class, Unit.class
                    })
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public LuaValue[] setSwitchChangedCallback(LuaValue[] fun) {
        switchChangedCallback = fun[0].toLuaFunction();
        if (switchChangedCallback != null) {
            getView().setOnCheckedChangeListener(this);
        } else {
            getView().setOnCheckedChangeListener(null);
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = UDColor.class)
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public LuaValue[] setThumbColor(LuaValue[] args) {
        int color = ((UDColor)args[0]).getColor();
        setThumbColor(color);
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = UDColor.class)
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public LuaValue[] setNormalColor(LuaValue[] args) {
        defaultColor = ((UDColor)args[0]).getColor();
        setTrickColor();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(value = UDColor.class)
            }, returns = @LuaApiUsed.Type(UDSwitch.class))
    })
    public LuaValue[] setSelectedColor(LuaValue[] args) {
        selectColor = ((UDColor)args[0]).getColor();
        setTrickColor();
        return null;
    }

    protected void setThumbColor(int color) {
        if (getView() instanceof Switch) {
            Switch s = (Switch) getView();
            Drawable thumb = s.getThumbDrawable();
            thumb.setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
        }
    }

    protected void setTrickColor() {
        if (!(getView() instanceof Switch))
            return;

        Switch s = (Switch) getView();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            ColorStateList stateList = new ColorStateList(
                    new int[][]{CHECKED_STATE_SET, new int[0]},
                    new int[] {selectColor, defaultColor});
            s.setTrackTintList(stateList);
            s.setTrackTintMode(PorterDuff.Mode.SRC);
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (switchChangedCallback != null) {
            switchChangedCallback.invoke(varargsOf(LuaBoolean.valueOf(isChecked)));
        }
    }
}