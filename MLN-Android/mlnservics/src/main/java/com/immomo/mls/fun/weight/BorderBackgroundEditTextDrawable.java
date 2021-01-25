/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.weight;

import android.graphics.Canvas;
import android.graphics.Rect;
import android.os.Build;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class BorderBackgroundEditTextDrawable extends BorderBackgroundDrawable  {

    private static final Rect canvasBounds = new Rect();
    @Override
    public void drawBorder(Canvas canvas) {
        if (borderWidth > 0 && !borderPath.isEmpty()) {
            canvas.getClipBounds(canvasBounds); /// 某些view(editText且设置了setGravity)，canvas的原点不在(0,0)
            if ( Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                canvas.save();
                canvas.translate(canvasBounds.left, canvasBounds.top);
                canvas.drawPath(borderPath, borderPathPaint);
                canvas.translate(-canvasBounds.left, -canvasBounds.top);
                canvas.restore();
                return;
            }
            borderPathRect.offset(canvasBounds.left, canvasBounds.top);
            int sc = canvas.saveLayer(borderPathRect, null, Canvas.ALL_SAVE_FLAG);
            borderPathRect.offset(-canvasBounds.left, - canvasBounds.top);
            canvas.drawPath(borderPath, borderPathPaint);
            canvas.restoreToCount(sc);//将图层合并
        }
    }
}
