/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.ViewGroup;
import android.webkit.URLUtil;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.ud.view.UDImageView;
import com.immomo.mls.fun.weight.BorderRadiusImageView;
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.BitmapUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.MainThreadExecutor;

import org.luaj.vm2.LuaValue;

import java.io.File;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
    private boolean lazyLoad = MLSConfigs.defaultLazyLoadImage;
    private RectF radiusRect;
    private ViewLifeCycleCallback cycleCallback;
    private Bitmap mSourceBitmap;
    private final @NonNull AtomicInteger modiCount;
    private final @NonNull ImageProvider provider;
    private int compatScaleType = -1;

    public LuaImageView(Context context, UDImageView metaTable, LuaValue[] initParams) {
        super(context);
        udImageView = metaTable;
        forceClipLevel(LEVEL_FORCE_CLIP);//ImageView 需要强制切割图片，统一效果
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

    public void setImageUrlEmpty() {
        this.image = "";
    }

    /**
     * 宽（或高）设置固定值，高（或宽）设置为Wrap_Content，则高（或宽）根据宽（或高）等比缩放图片。
     */
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        getUserdata().measureOverLayout(widthMeasureSpec, heightMeasureSpec);

        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        int wm = MeasureSpec.getMode(widthMeasureSpec);
        int hm = MeasureSpec.getMode(heightMeasureSpec);
        /// 其中一边不确定，另一边确定
        if (wm == MeasureSpec.EXACTLY && hm != MeasureSpec.EXACTLY) {
            int mw = getMeasuredWidth();
            int mh = mw * drawable.getIntrinsicHeight() / drawable.getIntrinsicWidth();
            if (hm == MeasureSpec.AT_MOST)
                mh = Math.min(mh, MeasureSpec.getSize(heightMeasureSpec));
            setMeasuredDimension(mw, mh);
        } else if (wm != MeasureSpec.EXACTLY && hm == MeasureSpec.EXACTLY) {
            int mh = getMeasuredHeight();
            int mw = mh * drawable.getIntrinsicWidth() / drawable.getIntrinsicHeight();
            if (wm == MeasureSpec.AT_MOST)
                mw = Math.min(mw, MeasureSpec.getSize(widthMeasureSpec));
            setMeasuredDimension(mw, mh);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        getUserdata().layoutOverLayout(left, top, right, bottom);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.save();
        canvas.clipRect(0, 0, getWidth(), getHeight());
        super.onDraw(canvas);
        canvas.restore();
        getUserdata().drawOverLayout(canvas);
    }

    @Override
    public void setScaleType(ScaleType scaleType) {
        ScaleType st = getScaleType();
        if (st == scaleType)
            return;
        super.setScaleType(scaleType);
        Drawable d = getDrawable();
        if (d != null) {
            setImageDrawable(null);
            setImageDrawable(d);
        }
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

        setImageWithoutCheck(url, null, changed, isNetworkUrl, false, false);
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
            if (TextUtils.isEmpty(url) && udImageView.hasCallback()) {
                udImageView.callback(false, url, getEmtpyMsg(url));
            }
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
        setImageWithoutCheck(url, placeholder, false, isNetworkUrl, true, true);
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

    private String getEmtpyMsg(String url) {
        if (url == null)
            return "Image url is nil";
        return "Image url is empty";
    }

    private void setImageWithoutCheck(String url, String placeHolder, final boolean changed,
                                      final boolean isNetworkUrl, boolean isUsePlaceHolderWhenUrlEmpty,
                                      boolean needCallback) {
        if (changed && isNetworkUrl) {
            setImageDrawable(null);
        }
        if (TextUtils.isEmpty(url)) {
            setPlaceHolderByParams(placeHolder, isUsePlaceHolderWhenUrlEmpty);
            if (needCallback && udImageView.hasCallback()) {
                udImageView.callback(false, url, getEmtpyMsg(url));
            }
            return;
        }
        if (isNetworkUrl) {
            realLoad(url, placeHolder, needCallback);
            return;
        }
        Drawable d = provider.loadProjectImage(getContext(), url);
        if (d != null) {
            setImageDrawable(d);
            return;
        }

        if (RelativePathUtils.isAssetUrl(url)) {
            url = RelativePathUtils.getAbsoluteAssetUrl(url);
            d = provider.loadProjectImage(getContext(), url);
            if (d != null)
                setImageDrawable(d);
            return;
        }

        // 解析file://开头的url
        if (RelativePathUtils.isLocalUrl(url)) {
            url = RelativePathUtils.getAbsoluteUrl(url);
            realLoad(url, placeHolder, needCallback);
            return;
        }

        // 解析lua包中的图片
        String localUrl = getLocalUrl();
        if (!TextUtils.isEmpty(localUrl)) {
            File imgFile = new File(localUrl, url);
            if (imgFile.exists()) {
                url = imgFile.getAbsolutePath();
                realLoad(url, placeHolder, needCallback);
                return;
            }
        }

        // 其他情况，尝试直接load
        realLoad(url, placeHolder, needCallback);
    }

    private void setPlaceHolderByParams(String placeHolder, boolean isUsePlaceHolderWhenUrlEmpty) {
        if (isUsePlaceHolderWhenUrlEmpty) {
            final boolean netUrl = URLUtil.isNetworkUrl(placeHolder);

            if (!netUrl) {
                final ImageProvider provider = MLSAdapterContainer.getImageProvider();
                if (provider != null) {
                    setImageDrawable(provider.loadProjectImage(getContext(), placeHolder));
                }
            }
        } else
            setImageDrawable(null);
    }

    private void realLoad(String url, String placeHolder, boolean needCallback) {
        mSourceBitmap = null;
        modiCount.incrementAndGet();
        if (lazyLoad) {
            provider.load(getContext(), this, url, placeHolder, getRadius(), newCallback(url, needCallback));
        } else {
            provider.loadWithoutInterrupt(getContext(), this, url, placeHolder, getRadius(), newCallback(url, needCallback));
        }
    }

    protected DrawableLoadCallback newCallback(final String url, boolean needCallback) {
        if (needCallback) {
            return new DrawableLoadCallback() {
                @Override
                public void onLoadResult(final Drawable drawable, final String errMsg) {
                    MainThreadExecutor.post(new Runnable() {
                        @Override
                        public void run() {
                            udImageView.callback(drawable != null, url, errMsg);
                        }
                    });
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
        } else if (canBlurImageCondition()) {
            return new DrawableLoadCallback() {
                @Override
                public void onLoadResult(final Drawable drawable, String errMsg) {
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
        }
        return null;
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

    @Override
    public void setImageDrawable(@Nullable Drawable drawable) {
        super.setImageDrawable(drawable);
        configurationScaleMatrix();
    }

    @Override
    public void setCompatScaleType(int type) {
        compatScaleType = type;
        setScaleType(ScaleType.MATRIX);
        configurationScaleMatrix();
    }

    private void configurationScaleMatrix() {
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        ScaleType scaleType = getScaleType();
        if (scaleType != ScaleType.MATRIX) {
            return;
        }
        if (compatScaleType < 0) {
            return;
        }
        if (compatScaleType == ContentMode.TOP) {
            setScaleTypeTop();
        }
        if (compatScaleType == ContentMode.BOTTOM) {
            setScaleTypeBottom();
        }
        if (compatScaleType == ContentMode.LEFT) {
            setScaleTypeLeft();
        }
        if (compatScaleType == ContentMode.RIGHT) {
            setScaleTypeRight();
        }
    }

    private void setScaleTypeRight() {
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams == null) {
            return;
        }
        int width = layoutParams.width;
        int height =layoutParams.height;
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        int intrinsicWidth = drawable.getIntrinsicWidth();
        int intrinsicHeight = drawable.getIntrinsicHeight();

        Matrix matrix = new Matrix();
        matrix.setScale(1F, 1F);
        matrix.setTranslate(width - intrinsicWidth, (height - intrinsicHeight) / 2F);
        setImageMatrix(matrix);
    }

    private void setScaleTypeLeft() {
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams == null) {
            return;
        }
        int width = layoutParams.width;
        int height =layoutParams.height;
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        int intrinsicWidth = drawable.getIntrinsicWidth();
        int intrinsicHeight = drawable.getIntrinsicHeight();

        Matrix matrix = new Matrix();
        matrix.setScale(1F, 1F);
        matrix.setTranslate(0, (height - intrinsicHeight) / 2F);
        setImageMatrix(matrix);
    }

    private void setScaleTypeBottom() {
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams == null) {
            return;
        }
        int width = layoutParams.width;
        int height =layoutParams.height;
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        int intrinsicWidth = drawable.getIntrinsicWidth();
        int intrinsicHeight = drawable.getIntrinsicHeight();

        Matrix matrix = new Matrix();
        matrix.setScale(1F, 1F);
        matrix.setTranslate((width - intrinsicWidth) / 2F, height - intrinsicHeight);
        setImageMatrix(matrix);
    }

    private void setScaleTypeTop() {
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams == null) {
            return;
        }
        int width = layoutParams.width;
        int height =layoutParams.height;
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return;
        }
        int intrinsicWidth = drawable.getIntrinsicWidth();
        int intrinsicHeight = drawable.getIntrinsicHeight();

        Matrix matrix = new Matrix();
        matrix.setScale(1F, 1F);
        matrix.setTranslate((width - intrinsicWidth) / 2F, 0);
        setImageMatrix(matrix);
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
                setImageWithoutCheck(url, null, false, URLUtil.isNetworkUrl(url), true, false);

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

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return isEnabled() && super.dispatchTouchEvent(ev);
    }
}