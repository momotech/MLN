package com.immomo.mls.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.os.Build;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.fun.ud.view.IBorderRadius;
import com.immomo.mls.fun.ud.view.IClipRadius.ClipLevel;
import com.immomo.mls.fun.ud.view.IClipRadius.CornerType;

import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_NORMAL_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_DIRECTION;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_MASK;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_NONE;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
public class ViewClipHelper {
    private float topLeftRadius = 0;
    private float topRightRadius = 0;
    private float bottomLeftRadius = 0;
    private float bottomRightRadius = 0;

    private int lastWidth;
    private int lastHeight;
    private float lastExtraRadius;

    private boolean radiusChanged = false;

    @NonNull
    private final Path clipPath = new Path();
    @NonNull
    private final RectF clipRect = new RectF();
    @NonNull
    private final float[] radii = new float[8];
    @NonNull
    private final RadiusDrawer radiusDrawer;

    private final Paint clipPaint;
    private final PorterDuffXfermode duffXfermode;

    private boolean doNotClip = MLSConfigs.defaultNotClip;
    /**
     * 方案WIKI：{@link com.immomo.mls.fun.lt.SICornerRadiusManager}
     * {@link com.immomo.mls.LuaViewManager#defaltCornerClip}
     */
    private boolean openCornerManager = false;//新属性，替代doNotClip，默认切割：false
    private boolean hasRadius = false;//是否设置了圆角，默认false
    private int forceClipLevel = LEVEL_NORMAL_CLIP;//切割等级
    private int cornerType = TYPE_CORNER_NONE;//圆角类型

    public ViewClipHelper() {
        this(null);
    }

    public ViewClipHelper(@Nullable View view) {
        radiusDrawer = new RadiusDrawer();
        //先绘制imageView本身，后绘制clipPath,所以选择DST_IN模式
        duffXfermode = new PorterDuffXfermode(PorterDuff.Mode.DST_IN);
        clipPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        clipPaint.setAntiAlias(true);
        clipPaint.setStyle(Paint.Style.FILL);
        clipPaint.setXfermode(duffXfermode);//DST_IN模式
        if (view != null)
            view.setLayerType(View.LAYER_TYPE_HARDWARE, clipPaint);

    }

    public void setDrawRadiusBackground(boolean draw) {
        doNotClip = draw;
    }

    public void openDefaultClip(boolean open) {
        this.openCornerManager = open;
    }

    public void setForceClipLevel(@ClipLevel int clipLevel) {
        this.forceClipLevel = clipLevel;
    }

    public void setRadius(float radius) {
        setRadius(radius, radius, radius, radius);
    }

    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        hasRadius = true;
        radiusChanged = topLeftRadius != topLeft || topRightRadius != topRight || bottomLeft != bottomLeftRadius || bottomRight != bottomRightRadius;
        topLeftRadius = topLeft;
        topRightRadius = topRight;
        bottomLeftRadius = bottomLeft;
        bottomRightRadius = bottomRight;
        updatePath(lastWidth, lastHeight, lastExtraRadius);
    }

    public void setRadius(IBorderRadius borderRadius) {
        float[] radii = borderRadius.getRadii();
        setRadius(radii[0], radii[2], radii[6], radii[4]);
    }

    public void setRadiusColor(int color) {
        radiusDrawer.setRadiusColor(color);
        setCornerType(TYPE_CORNER_MASK);
    }

    public void setCornerType(@CornerType int cornerType) {
        this.cornerType = cornerType;
    }

    public void updatePath(int w, int h, float extraRadius) {
        if (!radiusChanged && lastWidth == w && lastHeight == h && lastExtraRadius == extraRadius)
            return;
        lastWidth = w;
        lastHeight = h;
        lastExtraRadius = extraRadius;
        if (lastWidth == 0 || lastHeight == 0) {
            clipPath.reset();
            return;
        }
        float clipTLRadius = topLeftRadius;
        float clipTRRadius = topRightRadius;
        float clipBLRadius = bottomLeftRadius;
        float clipBRRadius = bottomRightRadius;
        if (cornerType == TYPE_CORNER_MASK) {
            radiusDrawer.update(clipTLRadius, clipTRRadius, clipBLRadius, clipBRRadius);
            return;
        }
        clipPath.reset();
        clipRect.set(0, 0, w, h);
        radii[0] = radii[1] = clipTLRadius;
        radii[2] = radii[3] = clipTRRadius;
        radii[4] = radii[5] = clipBRRadius;
        radii[6] = radii[7] = clipBLRadius;
        clipPath.addRoundRect(clipRect, radii, Path.Direction.CW);
    }

    public boolean needClicp() {
        return topLeftRadius != 0 || topRightRadius != 0
                || bottomLeftRadius != 0 || bottomRightRadius != 0;
    }

    public void clip(@NonNull Canvas canvas, SuperDrawAction action) {
        if (cornerType == TYPE_CORNER_MASK) {
            action.innerDraw(canvas);
            radiusDrawer.clip(canvas);
            return;
        }

        //新版统一方案
        boolean needClip = false;
        switch (this.forceClipLevel) {
            case LEVEL_NORMAL_CLIP:
                needClip = openCornerManager && hasRadius;
                break;
            case LEVEL_FORCE_CLIP:
                needClip = true;
                break;
            case LEVEL_FORCE_NOTCLIP:
                needClip = false;
                break;
        }
        needClip = needClip || cornerType == TYPE_CORNER_DIRECTION;//统一：CORNER_DIRECTION，强制图层切割

        //doNotClip 已废弃，保留兼容老版本
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP || (doNotClip && !needClip)) {
            action.innerDraw(canvas);
            return;
        }
        // 使用离屏缓存，新建一个srcRectF区域大小的图层
        int sc = canvas.saveLayer(clipRect, null, Canvas.ALL_SAVE_FLAG);
        action.innerDraw(canvas);
        canvas.drawPath(clipPath, clipPaint);
        canvas.restoreToCount(sc);//将图层合并
        return;
    }

    public interface SuperDrawAction {
        void innerDraw(Canvas canvas);
    }
}
