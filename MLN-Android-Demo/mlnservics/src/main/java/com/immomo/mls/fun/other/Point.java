package com.immomo.mls.fun.other;

import androidx.annotation.NonNull;

import com.immomo.mls.util.DimenUtil;

/**
 * Created by XiongFangyu on 2018/7/26.
 */
public class Point {
    private float x;
    private float y;
    public Point() {

    }

    public Point(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public Point(@NonNull Point p) {
        setPoint(p);
    }

    public void setPoint(@NonNull Point p) {
        this.x = p.x;
        this.y = p.y;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }

    public float getXPx() {
        return DimenUtil.dpiToPx(x);
    }

    public float getYPx() {
        return DimenUtil.dpiToPx(y);
    }

    @Override
    public String toString() {
        return "Point{" +
                "x=" + x +
                ", y=" + y +
                '}';
    }
}
