package com.immomo.mmui.weight.impl;

import android.graphics.Canvas;
import android.graphics.Outline;
import android.graphics.Path;
import android.view.View;
import android.view.ViewOutlineProvider;

import com.immomo.mmui.weight.IClipHelper;

import static com.immomo.mls.fun.constants.RectCorner.ALL_CORNERS;
import static com.immomo.mls.fun.constants.RectCorner.BOTTOM_LEFT;
import static com.immomo.mls.fun.constants.RectCorner.BOTTOM_RIGHT;
import static com.immomo.mls.fun.constants.RectCorner.TOP_LEFT;
import static com.immomo.mls.fun.constants.RectCorner.TOP_RIGHT;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 */
public class ClipHelper extends ViewOutlineProvider implements IClipHelper {

    /**
     * 和radii互斥
     * 当所有radius相同是，使用sameRadius
     * 反之，使用radii，sameRadius设置为NaN
     */
    private float sameRadius = Float.NaN;
    private float[] radii;
    private Path clipPath;
    private int width;
    private int height;

    private void initRadiiAndPath() {
        if (radii == null)
            radii = new float[8];
        if (clipPath == null)
            clipPath = new Path();
    }

    private void fillRadiiWithRadius() {
        if (!Float.isNaN(sameRadius)) {
            for (int i = 0; i < 8; i++) {
                radii[i] = sameRadius;
            }
        }
    }

    @Override
    public void setClipRadius(float r) {
        sameRadius = r;
    }

    @Override
    public void setClipRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        if (topLeft == topRight
                && topRight == bottomLeft
                && bottomLeft == bottomRight) {
            sameRadius = topLeft;
            return;
        }
        initRadiiAndPath();
        radii[0] = radii[1] = topLeft;
        radii[2] = radii[3] = topRight;
        radii[4] = radii[5] = bottomRight;
        radii[6] = radii[7] = bottomLeft;
        clipPath.reset();
    }

    @Override
    public void setClipRadius(int direction, float radius) {
        if ((direction & ALL_CORNERS) == ALL_CORNERS) {
            sameRadius = radius;
        } else {
            initRadiiAndPath();
            fillRadiiWithRadius();
            if ((direction & TOP_LEFT) == TOP_LEFT) {
                radii[0] = radii[1] = radius;
            }
            if ((direction & TOP_RIGHT) == TOP_RIGHT) {
                radii[2] = radii[3] = radius;
            }
            if ((direction & BOTTOM_LEFT) == BOTTOM_LEFT) {
                radii[6] = radii[7] = radius;
            }
            if ((direction & BOTTOM_RIGHT) == BOTTOM_RIGHT) {
                radii[4] = radii[5] = radius;
            }
            clipPath.reset();
        }
    }

    @Override
    public float getClipRadius(int direction) {
        if (!Float.isNaN(sameRadius))
            return sameRadius;
        if (radii == null)
            return 0;
        if ((direction & TOP_LEFT) == TOP_LEFT) {
            return radii[0];
        }
        if ((direction & TOP_RIGHT) == TOP_RIGHT) {
            return radii[2];
        }
        if ((direction & BOTTOM_LEFT) == BOTTOM_LEFT) {
            return radii[6];
        }
        if ((direction & BOTTOM_RIGHT) == BOTTOM_RIGHT) {
            return radii[4];
        }
        return radii[0];
    }

    @Override
    public float[] getClipRadii() {
        if (radii == null)
            radii = new float[8];
        fillRadiiWithRadius();
        return radii;
    }

    @Override
    public void applyClip(View v) {
        v.setOutlineProvider(this);
        v.setClipToOutline(true);
    }

    @Override
    public void revert(View v) {
        if (v.getOutlineProvider() == this) {
            v.setOutlineProvider(null);
            v.setClipToOutline(false);
        }
    }

    @Override
    public boolean needClipCanvas() {
        return Float.isNaN(sameRadius);
    }

    @Override
    public void clip(Canvas c) {
        if (clipPath == null || radii == null)
            return;
        if (clipPath.isEmpty()) {
            clipPath.addRoundRect(0, 0, c.getWidth(), c.getHeight(), radii, Path.Direction.CW);
        }
        c.clipPath(clipPath);
    }

    @Override
    public void onSizeChanged(int w, int h) {
        if (width == w && height == h)
            return;
        if (clipPath != null)
            clipPath.reset();
        width = w;
        height = h;
    }

    @Override
    public void getOutline(View view, Outline outline) {
        if (needClipCanvas()) {
            revert(view);
            return;
        }
        int w = view.getWidth();
        int h = view.getHeight();
        outline.setRoundRect(0, 0, w, h, sameRadius);
    }
}
