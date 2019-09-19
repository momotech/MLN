/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import com.immomo.mls.fun.constants.MeasurementType;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
public class Rect {
    private final Size size;
    private final Point point;

    public Rect() {
        this(0, 0, 0, 0);
    }

    public Rect(float x, float y, float width, float height) {
        size = new Size(width, height);
        point = new Point(x, y);
    }

    public Rect(Point point, Size size) {
        this.point = point;
        this.size = size;
    }

    public Rect(Rect src) {
        this.size = new Size(src.size);
        this.point = new Point(src.point);
    }

    //<editor-fold desc="API">
    public void setX(float x) {
        point.setX(x);
    }

    public float getX() {
        return point.getX();
    }

    public void setY(float y) {
        point.setY(y);
    }

    public float getY() {
        return point.getY();
    }

    public void setWidth(float w) {
        if (w == MeasurementType.MATCH_PARENT) {
            w = Size.MATCH_PARENT;
        }
        if (w == MeasurementType.WRAP_CONTENT) {
            w = Size.WRAP_CONTENT;
        }
        size.setWidth(w);
    }

    public float getWidth() {
        return size.getWidth();
    }

    public void setHeight(float h) {
        if (h == MeasurementType.MATCH_PARENT) {
            h = Size.MATCH_PARENT;
        }
        if (h == MeasurementType.WRAP_CONTENT) {
            h = Size.WRAP_CONTENT;
        }
        size.setHeight(h);
    }

    public float getHeight() {
        return (int) size.getHeight();
    }

    public void setPoint(@NonNull Point point) {
        this.point.setPoint(point);
    }

    public void setSize(@NonNull Size size) {
        this.size.setSize(size);
    }
    //</editor-fold>

    public Point getPoint() {
        return point;
    }

    public Size getSize() {
        return size;
    }

    @Override
    public String toString() {
        return size.toString() + " " + point.toString();
    }
}