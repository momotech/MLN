/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight.span;

import android.content.Context;
import android.graphics.drawable.Drawable;

import com.immomo.mls.fun.other.Size;

/**
 * Created by XiongFangyu on 2018/8/8.
 */
public class ResouceImageSpan extends ImageSpan {

    private int resourceId;
    private Size size;
    private Drawable mDrawable;
    private Context mContext;

    public ResouceImageSpan(Context context, int res, Size size) {
        super(ALIGN_CENTERVERTICAL);
        this.mContext = context;
        this.resourceId = res;
        this.size = size;
    }

    public Drawable getDrawable() {
        if (mDrawable == null) {
            try {
                mDrawable = mContext.getResources().getDrawable(resourceId);
                int w = size.getWidthPx();
                int h = size.getHeightPx();
                if(w > 0 || h > 0) {
                    mDrawable.setBounds(0, 0, w, h);
                } else {
                    mDrawable.setBounds(0, 0, mDrawable.getIntrinsicWidth(), mDrawable.getIntrinsicHeight());
                }
            } catch (Exception e) {
            }
        }
        return mDrawable;
    }
}