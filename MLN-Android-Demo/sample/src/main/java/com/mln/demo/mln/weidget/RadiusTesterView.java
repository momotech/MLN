package com.mln.demo.mln.weidget;

import android.content.Context;
import android.graphics.Canvas;
import android.os.Build;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import android.util.AttributeSet;
import android.view.View;

import com.immomo.mls.utils.RadiusDrawer;

public class RadiusTesterView extends View {

    private final RadiusDrawer radiusDrawer = new RadiusDrawer();

    public RadiusTesterView(Context context) {
        super(context);
    }

    public RadiusTesterView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public RadiusTesterView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public RadiusTesterView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public void setRadiusColor(int c) {
        radiusDrawer.setRadiusColor(c);
    }

    public void setRadius(float r) {
        radiusDrawer.update(r,r,r,r);
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);
        radiusDrawer.clip(canvas);
    }
}
