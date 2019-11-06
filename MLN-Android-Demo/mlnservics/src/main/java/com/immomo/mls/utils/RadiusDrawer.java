package com.immomo.mls.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import androidx.annotation.NonNull;

public class RadiusDrawer {
    @NonNull
    private final Path[] drawRadiusPath;
    @NonNull
    private final RectF[] radius;
    @NonNull
    private final Paint drawRadiusPaint;

    public RadiusDrawer() {
        drawRadiusPath = new Path[4];
        radius = new RectF[4];
        drawRadiusPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        drawRadiusPaint.setStyle(Paint.Style.FILL);
    }

    public void setRadiusColor(int color) {
        drawRadiusPaint.setColor(color);
    }

    public void update(float tl, float tr, float bl, float br) {
        update(0, tl);
        update(1, tr);
        update(2, bl);
        update(3, br);
    }

    private void update(int pos, float r) {
        if (r > 0) {
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
    }
}
