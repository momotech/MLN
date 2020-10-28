/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MotionEvent;

import com.immomo.mls.fun.constants.EditTextViewInputMode;
import com.immomo.mls.fun.weight.BorderRadiusEditText;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ud.UDEditText;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaEditText extends BorderRadiusEditText implements ILView<UDEditText> {

    private UDEditText udEditText;
    private ViewLifeCycleCallback cycleCallback;

    public LuaEditText(Context context, UDEditText metaTable) {
        super(context);

        this.udEditText = metaTable;

        setBackgroundDrawable(null);
        setViewLifeCycleCallback(udEditText);
        setTextSize(14);
        // 默认多行模式对应左上起点
        setGravity(Gravity.TOP);
//        setInputType(EditTextViewInputMode.Normal);
//        setSingleLine(false);
        setHintTextColor(Color.rgb(128, 128, 128));
        setTextColor(getResources().getColor(android.R.color.black));
//        setCursorColor(getResources().getColor(android.R.color.black));
        setPadding(0, 0, 0, 0);
        setEllipsize(TextUtils.TruncateAt.END);
        setOnEditorActionListener(getUserdata());
    }


    @Override
    public UDEditText getUserdata() {
        return udEditText;
    }


    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    public void setCursorColor(int color) {
        /// 不同版本cursor drawable名字不同
    }

    /**
     * 回调beginChangingCallback，和IOS统一效果，改为focusChange为true是回调（即回去焦点时回调）
     */
    @Override
    protected void onFocusChanged(boolean focused, int direction, Rect previouslyFocusedRect) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect);
        if (focused) {
            setCursorVisible(true);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!isEnabled())
            return false;
        if (event != null && event.getAction() == MotionEvent.ACTION_DOWN){
            setCursorVisible(true);
            getUserdata().callBeforeTextChanged();
        }
        return super.onTouchEvent(event);
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
}