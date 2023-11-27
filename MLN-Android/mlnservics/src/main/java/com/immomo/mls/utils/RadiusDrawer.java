/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import androidx.annotation.NonNull;

import com.immomo.mls.fun.constants.RectCorner;

public class RadiusDrawer {
    @NonNull
    private final Path[] drawRadiusPath;
    @NonNull
    private final RectF[] radius;
    @NonNull
    private final Paint drawRadiusPaint;
    private static final Rect canvasBounds = new Rect();

    public RadiusDrawer() {
        drawRadiusPath = new Path[4];
        radius = new RectF[4];
        drawRadiusPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        drawRadiusPaint.setStyle(Paint.Style.FILL);
    }

    public void setRadiusColor(int color) {
        drawRadiusPaint.setColor(color);
    }

    public void updateOne(@RectCorner.Direction int d, float r) {
        if ((d & RectCorner.TOP_LEFT) == RectCorner.TOP_LEFT) {
            update(0, r);
        }
        if ((d & RectCorner.TOP_RIGHT) == RectCorner.TOP_RIGHT) {
            update(1, r);
        }
        if ((d & RectCorner.BOTTOM_LEFT) == RectCorner.BOTTOM_LEFT) {
            update(2, r);
        }
        if ((d & RectCorner.BOTTOM_RIGHT) == RectCorner.BOTTOM_RIGHT) {
            update(3, r);
        }
    }

    public void update(float tl, float tr, float bl, float br) {
        update(0, tl);
        update(1, tr);
        update(2, bl);
        update(3, br);
    }

    private void update(int pos, float r) {
        if (r >= 0) {
            if (drawRadiusPath[pos] == null) {
                drawRadiusPath[pos] = new Path();
                radius[pos] = new RectF();
            } else {
                drawRadiusPath[pos].reset();
            }
            float d = r * 2;
            boolean left = pos % 2 == 0;
            boolean top = pos / 2 == 0;
            radius[pos].set(0, 0, d, d);
            float degree = pos * 90;
            float start = top ? -180 + degree : 270 - degree;
            float x = left ? 0 : d;
            float y = top ? 0 : d;
            drawRadiusPath[pos].moveTo(x, y);
            drawRadiusPath[pos].arcTo(radius[pos], start, 90);
            drawRadiusPath[pos].close();
        }
    }

    public void clip(Canvas canvas) {
        int w = canvas.getWidth();
        int h = canvas.getHeight();
        int tx, ty;
        canvas.getClipBounds(canvasBounds); /// 某些view(textview且设置了setGravity)，canvas的原点不在(0,0)
        canvas.save();
        canvas.translate(canvasBounds.left, canvasBounds.top);
        for (int i = 0; i < 4; i ++) {
            Path p = drawRadiusPath[i];
            if (p != null) {
                tx = i % 2 == 0 ? 0 : (int) (w - radius[i].right);
                ty = i / 2 == 0 ? 0 : (int) (h - radius[i].bottom);
                canvas.save();
                canvas.translate(tx, ty);
                canvas.drawPath(p, drawRadiusPaint);
                canvas.restore();
            }
        }
        canvas.restore();
    }
}