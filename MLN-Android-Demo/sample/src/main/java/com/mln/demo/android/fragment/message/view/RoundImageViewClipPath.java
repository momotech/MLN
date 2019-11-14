package com.mln.demo.android.fragment.message.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PaintFlagsDrawFilter;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;


import com.mln.demo.R;

import androidx.appcompat.widget.AppCompatImageView;

public class RoundImageViewClipPath extends AppCompatImageView {
    private Path mPath;
    private RectF mRectF;
    private float mCornerRadius;

    private PaintFlagsDrawFilter mPaintFlagsDrawFilter;

    public RoundImageViewClipPath(Context context) {
        this(context, null);
    }

    public RoundImageViewClipPath(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RoundImageViewClipPath(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        setUpCornerRadius(context, attrs);
        setUpPath();
        setUpPaintFlagsDrawFilter();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        saveCanvas(canvas);

        clipPathToDraw(canvas);
        super.onDraw(canvas);

        restoreCanvas(canvas);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mRectF = new RectF(0, 0, w, h);
    }

    private void setUpPaintFlagsDrawFilter() {
        mPaintFlagsDrawFilter = new PaintFlagsDrawFilter(0, Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
    }

    private void restoreCanvas(Canvas canvas) {
        canvas.restore();
    }

    private void saveCanvas(Canvas canvas) {
        canvas.save();
    }

    private void clipPathToDraw(Canvas canvas) {
        mPath.reset();
        mPath.addRoundRect(mRectF, getRadiusArray(), Path.Direction.CW);
        canvas.setDrawFilter(mPaintFlagsDrawFilter);
        canvas.clipPath(mPath);
    }

    private void setUpPath() {
        mPath = new Path();
    }

    private void setUpCornerRadius(Context context, AttributeSet attrs) {
        TypedArray properties = getRoundImageViewProperties(context, attrs);
        mCornerRadius = getRadiusDimension(properties);
        properties.recycle();
    }

    private float[] getRadiusArray() {
        float[] rids = new float[8];
        rids[0] = mCornerRadius;
        rids[1] = mCornerRadius;
        rids[2] = mCornerRadius;
        rids[3] = mCornerRadius;
        rids[4] = mCornerRadius;
        rids[5] = mCornerRadius;
        rids[6] = mCornerRadius;
        rids[7] = mCornerRadius;

        return rids;
    }

    private TypedArray getRoundImageViewProperties(Context context, AttributeSet attrs) {
        return context.obtainStyledAttributes(attrs, R.styleable.RoundImageViewClipPath);
    }

    private float getRadiusDimension(TypedArray array) {
        return array.getDimension(R.styleable.RoundImageViewClipPath_cornerRadius, 10);
    }
}
