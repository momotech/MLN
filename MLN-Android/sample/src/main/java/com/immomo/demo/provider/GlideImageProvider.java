/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Created by LuaView.
 * Copyright (c) 2017, Alibaba Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

package com.immomo.demo.provider;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.TextUtils;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.collection.LruCache;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.immomo.mls.provider.DrawableLoadCallback;
import com.immomo.mls.provider.ImageProvider;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;

/**
 * XXX
 *
 * @author song
 * @date 16/4/11
 * 主要功能描述
 * 修改描述
 * 下午5:42 song XXX
 */
public class GlideImageProvider implements ImageProvider {
    private static final LruCache<String, Integer> IdCache = new LruCache<>(50);
    @Override
    public void pauseRequests(final ViewGroup view, Context context) {
        Glide.with(context).pauseRequests();
    }

    @Override
    public void resumeRequests(final ViewGroup view, Context context) {
        if (context instanceof Activity && (((Activity) context).isFinishing() || ((Activity) context).isDestroyed())) {
            return;
        }
        if (Glide.with(context).isPaused()) {
            Glide.with(context).resumeRequests();
        }
    }

    /**
     * load url
     *  @param url
     * @param placeHolder
     * @param callback
     */
    public void load(@NonNull Context context, @NonNull ImageView imageView, @NonNull String url,
                     String placeHolder, @Nullable RectF radius, @Nullable DrawableLoadCallback callback) {
        RequestBuilder builder;
        if (callback != null) {
            final WeakReference<DrawableLoadCallback> cf = new WeakReference<DrawableLoadCallback>(callback);
            builder = Glide.with(context).load(url).listener(new RequestListener<Drawable>() {
                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    if (e != null)
                        e.printStackTrace();
                    if (cf.get() != null) {
                        cf.get().onLoadResult(null, e != null ? e.getMessage() : null);
                    }
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    if (cf.get() != null) {
                        cf.get().onLoadResult(resource, null);
                    }
                    return false;
                }
            });
        } else {
            builder = Glide.with(context).load(url);
        }
        if (placeHolder != null) {
            Drawable placeHolderDrawable = loadProjectImage(context,placeHolder);
            if(placeHolderDrawable !=null) {
                builder = builder.apply(new RequestOptions().placeholder(placeHolderDrawable));
            }
        }
        builder.into(imageView);
    }

    @Override
    public void loadWithoutInterrupt(@NonNull Context context, @NonNull ImageView iv, @NonNull String url,
                                     String placeHolder, @Nullable RectF radius, @Nullable DrawableLoadCallback callback) {
        load(context.getApplicationContext(), iv, url, placeHolder, radius, callback);
    }

    private static int getProjectImageId(String name) {
        Integer result = IdCache.get(name);
        if (result != null) {
            return result;
        }
        int id = ResourcesUtils.getResourceIdByName(name, ResourcesUtils.TYPE.DRAWABLE);
        IdCache.put(name, id);
        return id;
    }

    @Override
    public Drawable loadProjectImage(Context context, String name) {
        if (TextUtils.isEmpty(name))
            return null;
        int id = getProjectImageId(name);
        if (id > 0) {
            return context.getResources().getDrawable(id);
        }
        return getImageFromAssert(context,name);
    }

    @Override
    public void preload(@NonNull final Context context, @NonNull String url, @Nullable RectF radius, @Nullable final DrawableLoadCallback callback) {
        RequestBuilder builder;
        if (callback != null) {
            builder = Glide.with(context).load(url).listener(new RequestListener<Drawable>() {

                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    callback.onLoadResult(null, e != null ? e.getMessage() : null);
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    callback.onLoadResult(resource, null);
                    return false;
                }
            });
        } else {
            builder = Glide.with(context).load(url);
        }
        builder.preload();
    }

    /**
     * 从Assert里面获取图片
     * @param context
     * @param fileName
     * @return
     */
    public Drawable getImageFromAssert(Context context,String fileName) {
        AssetManager assetManager = context.getAssets();
        InputStream inputStream;//filename是assets目录下的图片名
        try {
            inputStream = assetManager.open(fileName);
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
            return new BitmapDrawable(bitmap) ;
        } catch (IOException e) {
            return null;
        }
    }
}