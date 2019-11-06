package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.InsetDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.EditText;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.constants.EditTextViewInputMode;
import com.immomo.mls.fun.ud.view.UDEditText;
import com.immomo.mls.fun.weight.BorderRadiusEditText;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LogUtil;

import java.lang.reflect.Field;

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
        setInputType(EditTextViewInputMode.Normal);
        setSingleLine(false);
        setHintTextColor(Color.rgb(128, 128, 128));
        setTextColor(getResources().getColor(android.R.color.black));
        setCursorColor(getResources().getColor(android.R.color.black));
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
        try {
            ShapeDrawable drawableS = new ShapeDrawable();
            drawableS.setIntrinsicWidth(DimenUtil.dpiToPx(1));
            drawableS.getPaint().setColor(color);
            InsetDrawable colorDrawable = new InsetDrawable(drawableS, 0);

            int width = colorDrawable.getIntrinsicWidth();
            int height = colorDrawable.getIntrinsicHeight();
            colorDrawable.setBounds(new Rect(0, 0, width, height));

            Class<?> clazz = EditText.class;
            clazz = clazz.getSuperclass();

            Field editor = clazz.getDeclaredField("mEditor");
            editor.setAccessible(true);
            Object mEditor = editor.get(this);
            Class<?> editorClazz = Class.forName("android.widget.Editor");
            Field drawables = editorClazz.getDeclaredField("mCursorDrawable");
            drawables.setAccessible(true);
            Drawable[] drawable = (Drawable[]) drawables.get(mEditor);
            if (drawable != null && drawable.length > 1) {
                if (drawable[0] == null) {
                    drawable[0] = colorDrawable;
                } else {
                    colorDrawable.setBounds(drawable[0].getBounds());
                    drawable[0] = colorDrawable;
                }
            }
        } catch (Exception e) {
            if (MLSEngine.DEBUG)//有的机型，没有这个属性。不需要上报。
                LogUtil.e(e);
        }
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
