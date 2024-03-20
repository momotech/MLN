package com.immomo.mmui.weight.impl;

import android.graphics.Outline;
import android.view.View;
import android.view.ViewOutlineProvider;

import com.immomo.mmui.weight.IShadowHelper;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 */
public class ShadowHelper extends ViewOutlineProvider implements IShadowHelper {

    private float cornerRadius;
    private int color;
    private int width;
    private int height;
    private float shadowRadius;
    private float alpha;

    private float lastElevation = Float.NaN;

    @Override
    public void setShadow(int color, int w, int h, float shadowRadius, float alpha) {
        this.color = color;
        this.width = w;
        this.height = h;
        this.shadowRadius = shadowRadius;
        if (alpha < 0)
            alpha = 0;
        if (alpha > 1)
            alpha = 1;
        this.alpha = alpha;
    }

    @Override
    public void setRoundRadiusForShadow(float roundRadius) {
        this.cornerRadius = roundRadius;
    }

    @Override
    public void applyShadow(View v) {
        if (Float.isNaN(lastElevation))
            lastElevation = v.getElevation();
        v.setElevation(shadowRadius);
        v.setOutlineProvider(this);
        v.setClipToOutline(false);
    }

    @Override
    public void revert(View v) {
        v.setElevation(lastElevation);
        if (v.getOutlineProvider() == this) {
            v.setOutlineProvider(null);
        }
    }

    @Override
    public void getOutline(View view, Outline outline) {
        outline.setRoundRect(width, height,
                view.getWidth() + width,
                view.getHeight() + height, cornerRadius);
        outline.setAlpha(alpha * 0.99f);
    }
}
