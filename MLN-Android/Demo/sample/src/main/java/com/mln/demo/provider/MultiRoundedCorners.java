package com.mln.demo.provider;

import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader;
import androidx.annotation.NonNull;
import android.widget.ImageView;

import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.load.resource.bitmap.TransformationUtils;
import com.bumptech.glide.util.Util;

import java.security.MessageDigest;

/**
 * Created by XiongFangyu on 2018/6/20.
 */

public class MultiRoundedCorners extends BitmapTransformation {

    private static final int VERSION = 1;//增加版本信息，如果有bug，改进后升级此Version即可
    private static final String ID = MultiRoundedCorners.class.getName() + "." + VERSION;
    private static final byte[] ID_BYTES = ID.getBytes(CHARSET);

    private int leftTopPx = 0;
    private int leftBottomPx = 0;
    private int rightTopPx = 0;
    private int rightBottomPx = 0;
    private ImageView.ScaleType scaleType = ImageView.ScaleType.FIT_CENTER;

    public MultiRoundedCorners(int radius) {
        this(radius, radius, radius, radius);
    }

    public MultiRoundedCorners(int leftTopPx, int leftBottomPx, int rightTopPx, int rightBottomPx) {
        this(leftTopPx, leftBottomPx, rightTopPx, rightBottomPx, ImageView.ScaleType.FIT_CENTER);
    }

    public MultiRoundedCorners(int leftTopPx, int leftBottomPx, int rightTopPx, int rightBottomPx, ImageView.ScaleType scaleType) {
        this.leftTopPx = leftTopPx;
        this.leftBottomPx = leftBottomPx;
        this.rightTopPx = rightTopPx;
        this.rightBottomPx = rightBottomPx;
        this.scaleType = scaleType;
    }

    @Override
    protected Bitmap transform(@NonNull BitmapPool pool, @NonNull Bitmap toTransform, int outWidth, int outHeight) {
        //scaleType为 CENTER_CROP时，图片圆角不能被正确显示，需要进行处理
        if (scaleType == ImageView.ScaleType.CENTER_CROP) {
            toTransform = TransformationUtils.centerCrop(pool, toTransform, outWidth, outHeight);
        }
        int width = toTransform.getWidth();
        int height = toTransform.getHeight();

        Bitmap bitmap = pool.get(width, height, Bitmap.Config.ARGB_8888);
        bitmap.setHasAlpha(true);

        if (toTransform.isRecycled()) {
            return bitmap;
        }
        transformRoundCorners(bitmap, toTransform);
        return bitmap;
    }

    private void transformRoundCorners(Bitmap source, Bitmap toTransform) {
        Canvas canvas = new Canvas(source);
        float[] mRadii = {
                leftTopPx, leftTopPx,
                rightTopPx, rightTopPx,
                rightBottomPx, rightBottomPx,
                leftBottomPx, leftBottomPx
        };

        RectF bounds = new RectF(0, 0, source.getWidth(), source.getHeight());
        Path path = new Path();
        if (scaleType == ImageView.ScaleType.CENTER_CROP) {
            Rect clipBounds = canvas.getClipBounds();
            applyScaleToRadii(canvas, mRadii);
            bounds.set(clipBounds);
        }
        path.addRoundRect(bounds, mRadii, Path.Direction.CW);

        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setFilterBitmap(true);
        paint.setShader(new BitmapShader(toTransform, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP));

        canvas.drawPath(path, paint);
    }

    private void applyScaleToRadii(Canvas canvas, float[] mRadii) {
        Matrix m = canvas.getMatrix();
        float[] values = new float[9];
        m.getValues(values);
        for (int i = 0; i < mRadii.length; i++) {
            mRadii[i] = mRadii[i] / values[0];
        }
    }

    protected String key() {
        return MultiRoundedCorners.class.getSimpleName() + "(_" + leftTopPx + "_" + leftBottomPx + "_" + rightTopPx + "_" + rightBottomPx + ")";
    }

    @Override
    public void updateDiskCacheKey(MessageDigest messageDigest) {
        messageDigest.update(ID_BYTES);
    }

    @Override
    public int hashCode() {
        int hashCode = Util.hashCode(leftTopPx) + Util.hashCode(leftBottomPx) + Util.hashCode(rightTopPx) + Util.hashCode(rightBottomPx);
        return Util.hashCode(ID.hashCode(), hashCode);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof MultiRoundedCorners) {
            MultiRoundedCorners other = (MultiRoundedCorners) obj;
            return leftTopPx == other.leftTopPx && rightTopPx == other.rightTopPx && leftBottomPx == other.leftBottomPx && rightBottomPx == other.rightBottomPx;
        }
        return false;
    }
}
