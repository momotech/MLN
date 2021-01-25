/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.java;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.R;
import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.List;

/**
 * Created by XiongFangyu on 2018/8/9.
 */
@LuaClass
public class Alert {
    public static final String LUA_CLASS_NAME = "Alert";

    private static final String OK_TEXT = "确认";
    private static final String CANCEL_TEXT = "取消";
    private static final byte STATE_SINGLE = 1;
    private static final byte STATE_DOUBLE = 1 << 1;
    private static final byte STATE_LIST = 1 << 2;

    protected Globals globals;
    private String title;
    private String message;
    private String cancelText;
    private String okText;
    private String singleText;
    private List buttonList;
    private LVCallback singleCallback;
    private LVCallback cancelCallback;
    private LVCallback okCallback;
    private LVCallback buttonListCallback;

    private byte state;

    private AlertDialog mAlertDialog;
    private Context context;

    public Alert(Globals g, LuaValue[] init) {
        globals = g;
    }

    public Alert(Globals globals) {
        this.globals = globals;
    }

    public Alert(Context context) {
        this.context = context;
    }

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaBridge(alias = "title", type = BridgeType.GETTER)
    public String getTitle() {
        return title;
    }

    @LuaBridge(alias = "title", type = BridgeType.SETTER)
    public void setTitle(String title) {
        this.title = title;
    }

    @LuaBridge(alias = "message", type = BridgeType.GETTER)
    public String getMessage() {
        return message;
    }

    @LuaBridge(alias = "message", type = BridgeType.SETTER)
    public void setMessage(String message) {
        this.message = message;
    }

    //</editor-fold>
    //<editor-fold desc="METHOD">
    @LuaBridge
    public void setCancel(String text, LVCallback callback) {
        state |= STATE_DOUBLE;
        cancelText = text;
        cancelCallback = callback;
        check();
    }

    @LuaBridge
    public void setOk(String text, LVCallback callback) {
        state |= STATE_DOUBLE;
        okText = text;
        okCallback = callback;
        check();
    }

    @LuaBridge
    public void setButtonList(List text, LVCallback callback) {
        state |= STATE_LIST;
        this.buttonList = text;
        buttonListCallback = callback;
        check();
    }

    @LuaBridge
    public void setSingleButton(String text, LVCallback callback) {
        state |= STATE_SINGLE;
        singleCallback = callback;
        singleText = text;
        check();
    }

    @LuaBridge
    public void show() {
        Context context = this.context;
        if (context == null) {
            LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
            context = (m != null ? m.context : null);
        }

        if (context == null)
            return;

        switch (state) {
            case STATE_SINGLE:
                showSingle(context, getSingleText(), title, message, singleCallback);
                break;
            case STATE_DOUBLE:
                showDouble(context, getOkText(), getCancelText(), title, message, okCallback, cancelCallback);
                break;
            case STATE_LIST:
                showList(context, buttonList, title, message, buttonListCallback);
                break;
        }
    }

    @LuaBridge
    public void dismiss() {
        if (mAlertDialog != null)
            mAlertDialog.dismiss();
    }

    //</editor-fold>
    //</editor-fold>
    protected void showSingle(Context context, String text, String title, String msg, final LVCallback callback) {

        mAlertDialog = new AlertDialog.Builder(context)
                .setCancelable(false)
                .setTitle(title)
                .setMessage(msg)
                .setPositiveButton(text, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (callback != null)
                            callback.call();
                        dialog.dismiss();
                    }
                }).create();

        mAlertDialog.show();
    }

    protected void showDouble(Context context, String ok, String cancel, String title, String msg, final LVCallback okCallback, final LVCallback cancelCallback) {

        mAlertDialog = new AlertDialog.Builder(context)
                .setCancelable(false)
                .setTitle(title)
                .setMessage(msg)
                .setPositiveButton(ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (okCallback != null)
                            okCallback.call();
                        dialog.dismiss();
                    }
                })
                .setNegativeButton(cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (cancelCallback != null)
                            cancelCallback.call();
                        dialog.dismiss();
                    }
                }).create();

        mAlertDialog.show();
    }

    protected void showList(Context context, List list, String title, String msg, final LVCallback callback) {
        mAlertDialog = new AlertDialog.Builder(context)
                .setCancelable(false)
                .setTitle(title)
                .setMessage(msg)
                .create();
        ListView listView = new ListView(context);
        mAlertDialog.setView(listView);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (callback != null)
                    callback.call(position + 1);
                mAlertDialog.dismiss();
            }
        });
        listView.setAdapter(new ArrayAdapter<String>(context, R.layout.lv_default_list_alert, list));
        mAlertDialog.show();
    }

    protected String getSingleText() {
        return notEmpty(singleText) ? singleText : OK_TEXT;
    }

    protected String getOkText() {
        return notEmpty(okText) ? okText : OK_TEXT;
    }

    protected String getCancelText() {
        return notEmpty(cancelText) ? cancelText : CANCEL_TEXT;
    }

    protected void check() {
        if (state != STATE_SINGLE && state != STATE_DOUBLE && state != STATE_LIST)
            throw new IllegalArgumentException("cannot set ok(cancel) text and button list on same instance!");
    }

    private static boolean notEmpty(String s) {
        return s != null && s.length() > 0;
    }
}