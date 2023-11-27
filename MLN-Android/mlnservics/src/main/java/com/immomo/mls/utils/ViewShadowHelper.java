/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.utils;

import android.graphics.Outline;
import android.view.View;
import android.view.ViewOutlineProvider;

import com.immomo.mls.fun.other.Size;

/**
 * Created by zhang.ke
 * Do not setting corner with method 'setCornerRadiusWithDirection' and setting shadow with method 'addShadow', or shadow will be clipped!
 * on 2019/10/17
 */
public class ViewShadowHelper {

    private float cornerRadius;

    private int color;
    private Size offset;
    private float shadowRadius;
    private float alpha;
    private boolean isError;//禁止与setCornerRadiusWithDirection()、addCornerMask()连用

    public ViewShadowHelper() {
    }

    public void setRadius(float cornerRadius) {
        this.cornerRadius = cornerRadius;
    }

    public void setShadowData(int color, final Size offset, final float shadowRadius, final float alpha) {
        this.color = color;
        this.offset = offset;
        this.shadowRadius = shadowRadius;
        this.alpha = alpha;
    }

    public void setOutlineProvider(View view) {
        if (isError) {
            ErrorUtils.debugUnsupportError("Do not setting corner with method 'setCornerRadiusWithDirection' and setting shadow with method 'setShadow', or shadow will be clipped!");
            return;
        }
        view.setElevation(shadowRadius);

        // 这个是加外边框，通过 setRoundRect 添加
        view.setOutlineProvider(new ViewOutlineProvider() {
            @Override
            public void getOutline(View view, Outline outline) {
                outline.setRoundRect(offset.getWidthPx(),
                        offset.getHeightPx(),
                        view.getWidth() + offset.getWidthPx(),
                        view.getHeight() + offset.getHeightPx(), cornerRadius);
//                if (Build.VERSION.SDK_INT >= 22)
//                    outline.offset(offset.getWidthPx(), offset.getHeightPx());

                if (alpha < 0) {
                    alpha = 0;
                }
                if (alpha > 1) {
                    alpha = 1;
                }
                outline.setAlpha((float) (alpha * 0.99));
            }
        });
        view.setClipToOutline(false);
    }

    public void setError(boolean error) {
        isError = error;
    }
}
