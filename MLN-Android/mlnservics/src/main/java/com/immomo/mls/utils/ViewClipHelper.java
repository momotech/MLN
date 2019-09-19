/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;
import android.os.Build;
import androidx.annotation.NonNull;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.fun.ud.view.IBorderRadius;

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

    private boolean drawRadius = false;
    private boolean doNotClip = MLSConfigs.defaultNotClip;

    public ViewClipHelper() {
        radiusDrawer = new RadiusDrawer();
    }

    public void setDrawRadiusBackground(boolean draw) {
        doNotClip = draw;
    }

    public void setRadius(float radius) {
        setRadius(radius, radius, radius, radius);
    }

    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
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
        drawRadius = true;
    }

    public void donotDrawRadius() {
        drawRadius = false;
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
        float clipTLRadius = topLeftRadius > 0 ?         topLeftRadius + extraRadius : 0;
        float clipTRRadius = topRightRadius > 0 ?       topRightRadius + extraRadius : 0;
        float clipBLRadius = bottomLeftRadius > 0 ?   bottomLeftRadius + extraRadius : 0;
        float clipBRRadius = bottomRightRadius > 0 ? bottomRightRadius + extraRadius : 0;
        if (drawRadius) {
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
        if (drawRadius) {
            action.innerDraw(canvas);
            radiusDrawer.clip(canvas);
            return;
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP || doNotClip) {
            action.innerDraw(canvas);
            return;
        }
        canvas.save();
        canvas.clipPath(clipPath);
        action.innerDraw(canvas);
        canvas.restore();
        return;
    }

    public interface SuperDrawAction {
        void innerDraw(Canvas canvas);
    }
}