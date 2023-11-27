package com.immomo.mls.wrapper;

import android.graphics.Color;
import android.text.TextPaint;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.TextView;

import com.immomo.mls.utils.LVCallback;

import androidx.annotation.NonNull;

public class CustomClickableSpan extends ClickableSpan {

    private LVCallback callback;
    private boolean underline = false;
    private int color;

    public CustomClickableSpan(LVCallback callback, boolean underline, int color) {
        this.underline = underline;
        this.callback = callback;
        this.color = color;
    }

    @Override
    public void onClick(View widget) {
        // 在这里可以做任何自己想要的处理
        if (widget instanceof TextView) {
            ((TextView) widget).setHighlightColor(Color.TRANSPARENT);
        }
        this.callback.call();

    }

    @Override
    public void updateDrawState(@NonNull TextPaint ds) {
        super.updateDrawState(ds);
        ds.setUnderlineText(this.underline);
        if (color != -1) {
            ds.setColor(color);
        }
    }
}

