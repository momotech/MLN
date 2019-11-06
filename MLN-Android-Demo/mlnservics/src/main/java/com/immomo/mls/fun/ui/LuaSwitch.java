package com.immomo.mls.fun.ui;

import android.content.Context;
import android.widget.Switch;

import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.ud.view.UDSwitch;

import org.luaj.vm2.LuaValue;

/**
 * Created by zhang.ke
 * on 2018/12/18
 */
public class LuaSwitch extends Switch implements ILView<UDSwitch> {
    private UDSwitch udSwitch;
    private ViewLifeCycleCallback cycleCallback;

    public LuaSwitch(Context context, UDSwitch metaTable, LuaValue[] initParams) {
        super(context);

        udSwitch = metaTable;
        setViewLifeCycleCallback(udSwitch);

    }

    //<editor-fold desc="ILView">
    @Override
    public UDSwitch getUserdata() {
        return udSwitch;
    }


    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }
    }
    //</editor-fold>
}
