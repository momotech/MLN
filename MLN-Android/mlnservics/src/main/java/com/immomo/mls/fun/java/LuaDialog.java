/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.java;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

import androidx.appcompat.app.AppCompatDialog;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.LVCallback;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;
import org.luaj.vm2.Globals;

/**
 * Created by zhang.ke
 * on 2018/12/13
 */
@LuaClass
public class LuaDialog extends AppCompatDialog {
    public static final String LUA_CLASS_NAME = "Dialog";

    private Globals globals;
    private LVCallback dialogDisAppear;
    private LVCallback dialogAppear;
    private boolean mCancelable = true;
    private View contentView;

    public LuaDialog(Globals globals) {
        super(((LuaViewManager) globals.getJavaUserdata()).context);
        this.globals = globals;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        Window window = getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(android.R.color.transparent);
            window.setGravity(Gravity.CENTER);
            window.setDimAmount(0.5f);
        }
    }

    public void __onLuaGc() {
        if (globals.isDestroyed()) {
            dismiss();
            if (dialogDisAppear != null) {
                dialogDisAppear.destroy();
            }
            if (dialogAppear != null) {
                dialogAppear.destroy();
            }
        }
        contentView = null;
    }

    //<editor-fold desc="API">
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = UDView.class)})
    })
    public void setContent(View v) {
        contentView = v;
    }

    @LuaBridge(alias = "cancelable", type = BridgeType.SETTER)
    public void setCancelable(boolean cancelable) {
        mCancelable = cancelable;
        super.setCancelable(cancelable);
        super.setCanceledOnTouchOutside(cancelable);
    }

    @LuaBridge(alias = "cancelable", type = BridgeType.GETTER)
    public boolean getCancelable() {
        return mCancelable;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void dialogAppear(LVCallback dialogAppear) {
        this.dialogAppear = dialogAppear;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void dialogDisAppear(LVCallback dialogDisAppear) {
        this.dialogDisAppear = dialogDisAppear;
    }

    @LuaBridge
    public void setDimAmount(float amount) {
        if (amount < 0)
            amount = 0;
        if (amount > 1)
            amount = 1;
        if (getWindow() != null)
            getWindow().setDimAmount(amount);
    }

    @LuaBridge
    public void setContentGravity(int g) {
        if (getWindow() != null)
            getWindow().setGravity(g);
    }

    @LuaBridge
    @Override
    public void show() {
        if (isShowing())
            return;
        if (contentView != null) {
            final ViewGroup parent = (ViewGroup) contentView.getParent();
            LuaViewUtil.removeView(parent, contentView);
            setContentView(contentView);
        }
        super.show();
        if (dialogAppear != null) {
            dialogAppear.call();
        }
    }

    @LuaBridge
    @Override
    public void dismiss() {
        if (!isShowing())
            return;
        super.dismiss();
        if (dialogDisAppear != null) {
            dialogDisAppear.call();
        }
    }
    //</editor-fold>
}
