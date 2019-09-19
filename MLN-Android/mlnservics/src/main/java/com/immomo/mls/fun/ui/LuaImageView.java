/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.RectF;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.webkit.URLUtil;

import androidx.annotation.NonNull;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.ud.view.UDImageView;
import com.immomo.mls.fun.weight.BorderRadiusImageView;
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.BitmapUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.MainThreadExecutor;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;
import org.w3c.dom.Text;

import java.io.File;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaImageView<U extends UDImageView> extends BorderRadiusImageView implements ILView<U>, ILuaImageView {
    private static final int MAX_BLUR_IMAGE_SIZE = 100;

    private UDImageView udImageView;
    private String image;
    private String localUrl;
    float mBlureVaue = -1;
    private AnimationTask task;
    private boolean lazyLoad = true;
    private RectF radiusRect;
    private ViewLifeCycleCallback cycleCallback;
    private Bitmap mSourceBitmap;
    private final @NonNull AtomicInteger modiCount;
    private final @NonNull ImageProvider provider;

    public LuaImageView(Context context, UDImageView metaTable, LuaValue[] initParams) {
        super(context);
        udImageView = metaTable;
        setLocalUrl(udImageView.getLuaViewManager().baseFilePath);
        setViewLifeCycleCallback(udImageView);
        setScaleType(ScaleType.values()[ContentMode.SCALE_ASPECT_FIT]);
        modiCount = new AtomicInteger(0);
        provider = MLSAdapterContainer.getImageProvider();
        AssertUtils.assertNullForce(provider);
    }


    @Override
    public U getUserdata() {
        return (U) udImageView;
    }


    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    //<editor-fold desc="ILuaImageView">
    @Override
    public void setImage(final String url) {
        final boolean isNetworkUrl = URLUtil.isNetworkUrl(url);
        final boolean changed = !TextUtils.equals(url, image);
        if (!changed) {
            return;
        }
        image = url;

        setImageWithoutCheck(url, null, changed, isNetworkUrl);
    }

    @Override
    public String getImage() {
        return image;
    }

    @Override
    public void setLocalUrl(String url) {
        this.localUrl = url;
    }

    @Override
    public String getLocalUrl() {
        return this.localUrl;
    }

    @Override
    public void startAnimImages(List<String> list, long duration, boolean repeat) {
        if (task != null) {
            task.stop();
        }
        task = new AnimationTask(list, duration, repeat);
        task.start();
    }

    @Override
    public void stop() {
        if (task != null) {
            task.stop();
        }
        task = null;
    }

    @Override
    public boolean isRunning() {
        return task != null && task.isRunning();
    }

    @Override
    public boolean isLazyLoad() {
        return lazyLoad;
    }

    @Override
    public void setLazyLoad(boolean lazyLoad) {
        this.lazyLoad = lazyLoad;
    }

    @Override
    public void setImageUrlWithPlaceHolder(final String url, final String placeholder) {
        final boolean changed = !TextUtils.equals(url, image);
        if (!changed) {
            return;
        }
        if (TextUtils.isEmpty(url)) {
            if (placeholder == null) {
                setImageDrawable(null);
            } else {
                final ImageProvider provider = MLSAdapterContainer.getImageProvider();
                if (provider != null) {
                    setImageDrawable(provider.loadProjectImage(getContext(), placeholder));
                } else {
                    setImageDrawable(null);
                }
            }
        }
        image = url;
        final boolean isNetworkUrl = URLUtil.isNetworkUrl(url);
        setImageWithoutCheck(url, placeholder, false, isNetworkUrl);
    }

    //</editor-fold>

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (task != null) {
            task.stop();
        }
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (task != null) {
            task.start();
        }
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    protected RectF getRadius() {
        if (hasSetRadius()) {
            float[] radii = getRadii();
            if (radiusRect == null) {
                radiusRect = new RectF();
            }
            radiusRect.set(radii[0], radii[6], radii[2], radii[4]);
            return radiusRect;
        }
        return null;
    }

    private void setImageWithoutCheck(String url, String placeHolder, final boolean changed, final boolean isNetworkUrl) {
        if (changed && isNetworkUrl) {
            setImageDrawable(null);
        }
        if (TextUtils.isEmpty(url))
            return;
        if (isNetworkUrl) {
            realLoad(url, placeHolder);
            return;
        }
        Drawable d = provider.loadProjectImage(getContext(), url);
        if (d != null) {
            setImageDrawable(d);
            return;
        }

        // 解析file://开头的url
        if (FileUtil.isLocalUrl(url)) {
            url = FileUtil.getAbsoluteUrl(url);
            realLoad(url, placeHolder);
            return;
        }

        // 解析lua包中的图片
        String localUrl = getLocalUrl();
        if (!TextUtils.isEmpty(localUrl)) {
            File imgFile = new File(localUrl, url);
            if (imgFile.exists()) {
                url = imgFile.getAbsolutePath();
                realLoad(url, placeHolder);
                return;
            }
        }

        // 其他情况，尝试直接load
        realLoad(url, placeHolder);
    }

    private void realLoad(String url, String placeHolder) {
        mSourceBitmap = null;
        modiCount.incrementAndGet();
        if (lazyLoad) {
            provider.load(getContext(), this, url, placeHolder, getRadius(), initLoadCallback());
        } else {
            provider.loadWithoutInterrupt(getContext(), this, url, placeHolder, getRadius(), initLoadCallback());
        }
    }

    DrawableLoadCallback drawableLoadCallback;

    private DrawableLoadCallback initLoadCallback() {
        if (drawableLoadCallback != null)
            return drawableLoadCallback;

        drawableLoadCallback = new DrawableLoadCallback() {
            @Override
            public void onLoadResult(final Drawable drawable) {
                LuaFunction function = getUserdata().getImageLoadCallback();
                if (function != null) {
                    function.invoke(LuaValue.varargsOf(drawable != null ? LuaBoolean.True() : LuaBoolean.False(), LuaValue.Nil(), LuaString.valueOf(image)));
                }

                if (canBlurImageCondition() && drawable instanceof BitmapDrawable) {//判断，高斯模糊
                    MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new Runnable() {
                        @Override
                        public void run() {//图片加载回调
                            blur(drawable);
                        }
                    });
                }
            }
        };
        return drawableLoadCallback;
    }

    private void preloadPlaceHolder(String placeHolder, ImageProvider provider) {
        if (!TextUtils.isEmpty(placeHolder)) {
            Drawable holderDrawable = provider.loadProjectImage(getContext(), placeHolder);
            setImageDrawable(holderDrawable);
        }
    }

    private boolean canBlurImageCondition() {
        return mBlureVaue > 0 && mBlureVaue <= 25 && task == null;
    }

    @Override
    public void setBlurImage(final float blurValue) {
        if (blurValue == mBlureVaue)
            return;
        mBlureVaue = blurValue;
        final Drawable d = getDrawable();
        if (!(d instanceof BitmapDrawable))
            return;
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new Runnable() {
            @Override
            public void run() {
                blur(d);
            }
        });
    }

    /**
     * call in thread
     */
    private void blur(Drawable d) {
        if (mBlureVaue == 0 && mSourceBitmap != null) {

            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    setImageBitmap(mSourceBitmap);
                }
            });

            return;
        }
        if (!canBlurImageCondition())
            return;

        Bitmap bitmap = ((BitmapDrawable) d).getBitmap();

        if (mSourceBitmap != null)
            bitmap = mSourceBitmap;

        if (bitmap == null)
            return;

        final int thisModiCount = modiCount.get();
        if (mSourceBitmap == null)
            mSourceBitmap = bitmap;

        try {
            Bitmap.Config c = bitmap.getConfig();
            if (c != Bitmap.Config.ARGB_8888 && c != Bitmap.Config.RGB_565) {
                bitmap = bitmap.copy(Bitmap.Config.RGB_565, true);
            }
            final Bitmap outBitmap = BitmapUtil.blurBitmap(BitmapUtil.scaleBitmap(bitmap, MAX_BLUR_IMAGE_SIZE, MAX_BLUR_IMAGE_SIZE), (int) mBlureVaue);
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    if (thisModiCount != modiCount.get())
                        return;
                    setImageBitmap(outBitmap);
                }
            });
        } catch (Exception e) {
            if (MLSEngine.DEBUG)
                LogUtil.e(e);
        }
    }

    private final class AnimationTask implements Animatable {
        private final List<String> list;
        private final long duration;
        private final boolean repeat;
        private final long each;
        private boolean running = false;
        private int nowIndex;

        AnimationTask(List<String> list, long duration, boolean repeat) {
            this.list = list;
            this.duration = duration;
            this.repeat = repeat;
            each = duration / list.size();
        }

        @Override
        public void start() {
            running = true;
            r.run();
        }

        @Override
        public void stop() {
            running = false;
            MainThreadExecutor.cancelSpecificRunnable(getTaskTag(), r);
        }

        @Override
        public boolean isRunning() {
            return running;
        }

        private Runnable r = new Runnable() {
            @Override
            public void run() {

                if (!running)
                    return;

                if (nowIndex >= list.size()) {
                    if (repeat) {
                        nowIndex = 0;
                    } else {
                        running = false;
                        return;
                    }
                }

                String url = list.get(nowIndex++);
                setImageWithoutCheck(url, null, false, URLUtil.isNetworkUrl(url));

                preloadNextImageUrl();

                MainThreadExecutor.cancelSpecificRunnable(getTaskTag(), this);
                MainThreadExecutor.postDelayed(getTaskTag(), this, each);
            }

            private void preloadNextImageUrl() {
                int next = nowIndex;
                if (next >= list.size())
                    next = 0;

                String nextImageUrl = list.get(next);

                final ImageProvider provider = MLSAdapterContainer.getImageProvider();
                provider.preload(getContext(), nextImageUrl, null, null);
            }

        };
    }

    private Object getTaskTag() {
        return hashCode();
    }
}