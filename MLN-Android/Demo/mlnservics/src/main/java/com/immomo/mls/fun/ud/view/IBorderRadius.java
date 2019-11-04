package com.immomo.mls.fun.ud.view;

import android.graphics.Canvas;

import com.immomo.mls.fun.constants.RectCorner;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import androidx.annotation.IntDef;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public interface IBorderRadius extends RectCorner{
    int D_LEFT_TOP = TOP_LEFT;
    int D_RIGHT_TOP = TOP_RIGHT;
    int D_RIGHT_BOTTOM = BOTTOM_RIGHT;
    int D_LEFT_BOTTOM = BOTTOM_LEFT;
    int D_ALL_CORNERS = ALL_CORNERS;

    @IntDef({D_LEFT_TOP, D_RIGHT_TOP, D_RIGHT_BOTTOM, D_LEFT_BOTTOM, D_ALL_CORNERS})
    @Retention(RetentionPolicy.SOURCE)
    @interface Direction {}

    void setStrokeWidth(float width);
    void setStrokeColor(int color);
    void setCornerRadius(float radius);//用于cornerRadius
    void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight);
    void setRadius(@Direction int direction, float radius);//用于setCornerRadiusWithDirection
    void setMaskRadius(@Direction int direction, float radius);//用于addCornerMask

    float getStrokeWidth();
    int getStrokeColor();
    float getCornerRadiusWithDirection(@Direction int direction);
    float getRadius(@Direction int direction);
    float[] getRadii();

    void drawBorder(Canvas canvas);
}
