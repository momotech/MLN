package com.immomo.mls.fun.java;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ui.LuaDialog;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/8/9.
 */
@LuaClass
public class Dialog implements LuaDialog.LuaDialogCallback {
    public static final String LUA_CLASS_NAME = "Dialog";

    protected Globals globals;
    private LVCallback dialogDisAppear;
    private LVCallback dialogAppear;
    private UDView contentView;
    private LuaDialog dialog;
    private float mAmount = 0.5f;
    private boolean cancelable = true;

    private int gravity = Gravity.CENTER;

    public Dialog(Globals g, LuaValue[] init) {
        globals = g;
    }

    public Dialog(Globals globals) {
        this.globals = globals;
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
            contentView = null;
        }
    }

    //<editor-fold desc="Property">
    @LuaBridge(alias = "setContent")
    public void setContentView(UDView contentView) {
        this.contentView = contentView;
    }

    @LuaBridge(alias = "cancelable", type = BridgeType.SETTER)
    public void setCancelable(boolean cancelable) {
            this.cancelable = cancelable;
    }

    @LuaBridge(alias = "cancelable", type = BridgeType.GETTER)
    public boolean getCancelable() {
        return this.cancelable;
    }

    //<editor-fold desc="API">
    @LuaBridge(alias = "dialogAppear")
    public void setDialogAppear(LVCallback dialogAppear) {
        this.dialogAppear = dialogAppear;
    }

    @LuaBridge(alias = "dialogDisAppear")
    public void setDialogDisAppear(LVCallback dialogDisAppear) {
        this.dialogDisAppear = dialogDisAppear;
    }

    @LuaBridge
    public void setDimAmount(float amount) {
            this.mAmount = amount;
    }

    @LuaBridge
    public LuaValue[] setContentGravity(LuaValue[] var) {
        gravity = var[0].toInt();
        return null;
    }

    //</editor-fold>
    //<editor-fold desc="METHOD">
    @LuaBridge
    public void show() {
        if (contentView == null) {
            return;
        } else if (contentView.getView().getParent() instanceof ViewGroup) {
            View view = contentView.getView();
            final ViewGroup parent = (ViewGroup) view.getParent();
            LuaViewUtil.removeView(parent, view);
        }
        if (dialog != null) {
            dialog.dismiss();
            dialog = null;
        }

        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        Context context = (m != null ? m.context : null);

        if (context == null)
            return;

        dialog = new LuaDialog.Builder(context)
                .setCancelable(cancelable)
                .setAmount(mAmount)
                .setContentView(contentView)
                .setCallback(this)
                .setGravity(gravity)
                .build();
        dialog.show();
    }

    @LuaBridge
    public void dismiss() {
        if (dialog != null) {
            if (dialog.isShowing()) {
                dialog.dismiss();
            }
            dialog = null;
        }
    }

    //</editor-fold>
    //</editor-fold>

    @Override
    public void onShow() {
        if (dialogAppear != null) {
            dialogAppear.call();
        }
    }

    @Override
    public void onDismiss() {
        if (dialogDisAppear != null) {
            dialogDisAppear.call();
        }
    }
}
