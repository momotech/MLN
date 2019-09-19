/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight.span;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.style.ReplacementSpan;

import java.lang.ref.WeakReference;

/**
 * Created by XiongFangyu on 2018/8/8.
 */
public abstract class DynamicDrawableSpan extends ReplacementSpan {
    private static final String TAG = "DynamicDrawableSpan";

    /**
     * A constant indicating that the bottom of this span should be aligned
     * with the bottom of the surrounding text, i.e., at the same level as the
     * lowest descender in the text.
     */
    public static final int ALIGN_BOTTOM = 0;

    /**
     * A constant indicating that the bottom of this span should be aligned
     * with the baseline of the surrounding text.
     */
    public static final int ALIGN_BASELINE = 1;

    public static final int ALIGN_TOPLINE = 2;

    public static final int ALIGN_CENTERVERTICAL = 3;

    protected final int mVerticalAlignment;

    public DynamicDrawableSpan() {
        mVerticalAlignment = ALIGN_BOTTOM;
    }

    /**
     * @param verticalAlignment one of {@link #ALIGN_BOTTOM} or {@link #ALIGN_BASELINE}.
     */
    protected DynamicDrawableSpan(int verticalAlignment) {
        mVerticalAlignment = verticalAlignment;
    }

    /**
     * Returns the vertical alignment of this span, one of {@link #ALIGN_BOTTOM} or
     * {@link #ALIGN_BASELINE}.
     */
    public int getVerticalAlignment() {
        return mVerticalAlignment;
    }

    /**
     * Your subclass must implement this method to provide the bitmap
     * to be drawn.  The dimensions of the bitmap must be the same
     * from each call to the next.
     */
    public abstract Drawable getDrawable();

    @Override
    public int getSize(Paint paint, CharSequence text,
                       int start, int end,
                       Paint.FontMetricsInt fm) {
        Drawable d = getCachedDrawable();

        int result = 0;

        if(d != null) {
            Rect rect = d.getBounds();
            if(rect != null) {
                if (fm != null) {
                    fm.ascent = -rect.bottom;
                }
                result = rect.right;
            }
        }

        if (fm != null) {
            fm.descent = 0;
            fm.top = fm.ascent;
            fm.bottom = 0;
        }

        return result;
    }

    @Override
    public void draw(Canvas canvas, CharSequence text,
                     int start, int end, float x,
                     int top, int y, int bottom, Paint paint) {
        Drawable b = getCachedDrawable();
        if(b != null) {
            canvas.save();
            int transY = bottom - b.getBounds().bottom;
            if (mVerticalAlignment == ALIGN_BASELINE) {
                transY -= paint.getFontMetricsInt().descent;
            } else if(mVerticalAlignment == ALIGN_TOPLINE){
                transY = (int) (top + paint.getFontMetrics().ascent - paint.getFontMetricsInt().top + 3);
            } else if(mVerticalAlignment == ALIGN_CENTERVERTICAL) {
                int tmp = bottom - top - b.getBounds().bottom;
                if(tmp >= 0) {
                    transY = top + tmp/2;
                }
            }

            canvas.translate(x, transY);
            b.draw(canvas);
            canvas.restore();
        }
    }

    protected Drawable getCachedDrawable() {
        WeakReference<Drawable> wr = mDrawableRef;
        Drawable d = null;

        if (wr != null)
            d = wr.get();

        if (d == null) {
            d = getDrawable();
            mDrawableRef = new WeakReference<Drawable>(d);
        }

        return d;
    }

    protected void resetCache() {
        mDrawableRef = null;
    }

    private WeakReference<Drawable> mDrawableRef;
}