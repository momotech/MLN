/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import androidx.annotation.Nullable;


@LuaClass(name = "Clipboard", isSingleton = true)
public class SClipboard {
    public static final String LUA_CLASS_NAME = "Clipboard";

    private Globals globals;
    ClipboardManager mClipboardManager;

    public SClipboard(Globals g, LuaValue[] init) {
        globals = g;
        mClipboardManager = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
    }

    protected @Nullable
    Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    @LuaBridge
    public void setText(String pasteText) {
        if (mClipboardManager != null) {
            if (pasteText == null)
                pasteText = "";
            ClipData clipData = ClipData.newPlainText(null, pasteText);
            mClipboardManager.setPrimaryClip(clipData);
        }
    }

    @LuaBridge
    public String getText() {
        if (mClipboardManager == null)
            return "";

        if (mClipboardManager.hasPrimaryClip()) {
            ClipData clipData = mClipboardManager.getPrimaryClip();
            if (clipData != null && clipData.getItemCount() > 0) {
                return clipData.getItemAt(0).getText().toString();   // 从数据集中获取（已复制）第一条文本数据
            }
        }
        return "";
    }

    @LuaBridge
    public void setTextWithClipboardName(String pasteText, String clipboardName) {
        if (mClipboardManager != null) {

            if (pasteText == null) {
                pasteText = "";
            }

            ClipData clipData = null;
            if (mClipboardManager.hasPrimaryClip()) {
                clipData = mClipboardManager.getPrimaryClip();
                ClipData.Item item = new ClipData.Item(pasteText, clipboardName);
                clipData.addItem(item);
            } else
                clipData = ClipData.newPlainText(null, pasteText);
            mClipboardManager.setPrimaryClip(clipData);
        }
    }


    @LuaBridge
    public String getTextWithClipboardName(String clipboardName) {
        if (mClipboardManager == null || clipboardName == null)
            return "";

        if (mClipboardManager.hasPrimaryClip()) {
            ClipData clipData = mClipboardManager.getPrimaryClip();
            for (int size = clipData.getItemCount(), i = size - 1; i >= 0; i--) {
                ClipData.Item item = clipData.getItemAt(i);

                if (item.getHtmlText() != null && item.getHtmlText().equals(clipboardName)) {
                    return item.getText().toString();
                }
            }
        }
        return "";
    }

    public void __onLuaGc() {
        globals = null;
        mClipboardManager = null;
    }
}