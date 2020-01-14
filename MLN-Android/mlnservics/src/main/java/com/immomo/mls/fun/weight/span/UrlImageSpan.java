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
import android.text.TextUtils;
import android.webkit.URLUtil;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;

/**
 * Created by XiongFangyu on 2018/8/8.
 */
public class UrlImageSpan extends ImageSpan implements DrawableLoadCallback{
    private Size size;
    private Drawable mDrawable;

    ILoadDrawableResult mILoadDrawableResult;

    public UrlImageSpan(Context context, String url, Size size, ILoadDrawableResult loadDrawableResult) {
        this(context, url, size, loadDrawableResult, ALIGN_CENTERVERTICAL);

    }

    public UrlImageSpan(Context context, String url, Size size, ILoadDrawableResult loadDrawableResult, int verticalAlignment) {
        super(verticalAlignment);

        mILoadDrawableResult = loadDrawableResult;

        this.size = size;
        ImageProvider provider = MLSAdapterContainer.getImageProvider();
        if (provider != null) {
            if (URLUtil.isNetworkUrl(url)) {
                provider.preload(context, url, null, this);
            } else {
                if (TextUtils.isEmpty(url)) {
                    return;
                }
                mDrawable = provider.loadProjectImage(context, url);
                if (mDrawable != null)
                    initSize();
            }
        }
    }

    public Drawable getDrawable() {
        return mDrawable;
    }

    @Override
    public void onLoadResult(Drawable drawable, String errMsg) {
        mDrawable = drawable;
        if (drawable == null)
            return;
        initSize();

        if (mILoadDrawableResult != null)
             mILoadDrawableResult.loadDrawableResult(this);
    }

    private void initSize() {
        int w = size.getWidthPx();
        int h = size.getHeightPx();
        if(w > 0 || h > 0) {
            mDrawable.setBounds(0, 0, w, h);
        } else {
            mDrawable.setBounds(0, 0, mDrawable.getIntrinsicWidth(), mDrawable.getIntrinsicHeight());
        }
        mDrawable.invalidateSelf();
    }

    public interface ILoadDrawableResult {
        void loadDrawableResult(ImageSpan imageSpan);
    }

}