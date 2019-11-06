package com.immomo.mls.weight;

import android.graphics.Paint;
import android.text.TextPaint;
import android.text.style.CharacterStyle;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public class WeightStyleSpan extends CharacterStyle {
    private final int mWeight;

    public WeightStyleSpan(int weight) {
        mWeight = weight;
    }

    @Override
    public void updateDrawState(TextPaint paint) {
        final float newStrokeWidth = (mWeight / 400f);
        if (paint.getStyle() == Paint.Style.FILL) {
            paint.setStyle(Paint.Style.FILL_AND_STROKE);
        }
        paint.setStrokeWidth(newStrokeWidth);
    }

    public int getWeight() {
        return mWeight;
    }
}