package com.immomo.mls.fun.ui;

import android.content.Context;
import android.view.Window;
import android.view.WindowManager;

import com.immomo.mls.fun.ud.view.UDView;

import androidx.appcompat.app.AppCompatDialog;

/**
 * Created by zhang.ke
 * on 2018/12/13
 */
public class LuaDialog extends AppCompatDialog {
    private LuaDialogCallback dialogCallback;

    private LuaDialog(Context context) {
        super(context);
    }

    public void setDialogCallback(LuaDialogCallback dialogCallback) {
        this.dialogCallback = dialogCallback;
    }

    private void build(WindowManager.LayoutParams dialogLayoutParam,int gravity) {
        Window window = getWindow();

        if (dialogLayoutParam != null && window != null) {
            window.setLayout(dialogLayoutParam.width, dialogLayoutParam.height);
        }

        if (window != null)
            window.setGravity(gravity);
    }

    @Override
    public void show() {
        super.show();
        if (dialogCallback != null) {
            dialogCallback.onShow();
        }
    }

    @Override
    public void dismiss() {
        super.dismiss();
        if (dialogCallback != null) {
            dialogCallback.onDismiss();
        }
    }


    public static class Builder {
        private Context context;
        private WindowManager.LayoutParams dialogLayoutParam;
        private UDView contentView;
        private boolean cancelable;
        private float mAmount = 0.5f;
        private int gravity;
        private LuaDialogCallback dialogCallback;

        public Builder(Context context) {
            this.context = context;
        }

        public Builder setContentView(UDView contentView) {
            this.contentView = contentView;
            return this;
        }

        public Builder setLayoutParams(WindowManager.LayoutParams dialogLayoutParam) {
            this.dialogLayoutParam = dialogLayoutParam;
            return this;
        }

        public Builder setAmount(float mAmount) {
            this.mAmount = mAmount;
            return this;
        }

        public Builder setGravity(int gravity) {
            this.gravity = gravity;
            return this;
        }

        public Builder setCancelable(boolean cancelable) {
            this.cancelable = cancelable;
            return this;
        }

        public Builder setCallback(LuaDialogCallback dialogCallback) {
            this.dialogCallback = dialogCallback;
            return this;
        }

        public LuaDialog build() {
            LuaDialog luaDialog = new LuaDialog(context);
            luaDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
            luaDialog.setCancelable(cancelable);
            luaDialog.setCanceledOnTouchOutside(cancelable);

             //luaDialog.getWindow().setBackgroundDrawable(null);
            luaDialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);

            if (mAmount < 0)
                mAmount = 0;
            if (mAmount > 1)
                mAmount = 1;
            luaDialog.getWindow().setDimAmount(mAmount);

            luaDialog.setDialogCallback(dialogCallback);
            luaDialog.build(dialogLayoutParam,gravity);
            luaDialog.setContentView(contentView.getView());

            return luaDialog;
        }
    }

    public interface LuaDialogCallback {
        void onShow();

        void onDismiss();
    }
}
