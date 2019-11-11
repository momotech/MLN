/*
 * Created by LuaView.
 * Copyright (c) 2017, Alibaba Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

package com.mln.demo.provider;

import android.app.Activity;
import android.content.Context;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
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

import java.lang.ref.WeakReference;

/**
 * XXX
 *
 * @author song
 * 主要功能描述
 * 修改描述
 * 下午5:42 song XXX
 */
public class GlideImageProvider implements ImageProvider {
    private static final LruCache<String, Integer> IdCache = new LruCache<>(50);
    @Override
    public void pauseRequests(@NonNull final ViewGroup view, @NonNull Context context) {
        Glide.with(context).pauseRequests();
    }

    @Override
    public void resumeRequests(@NonNull final ViewGroup view, @NonNull Context context) {
        if (context instanceof Activity && (((Activity) context).isFinishing() || ((Activity) context).isDestroyed())) {
            return;
        }
        if (Glide.with(context).isPaused()) {
            Glide.with(context).resumeRequests();
        }
    }

    /**
     * load url
     */
    public void load(@NonNull Context context, @NonNull ImageView imageView, @NonNull String url,
                     String placeHolder, @Nullable RectF radius, @Nullable DrawableLoadCallback callback) {
        RequestBuilder builder;
        if (callback != null) {
            final WeakReference<DrawableLoadCallback> cf = new WeakReference<>(callback);
            builder = Glide.with(context).load(url).listener(new RequestListener<Drawable>() {
                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    if (e != null)
                        e.printStackTrace();
                    if (cf.get() != null) {
                        cf.get().onLoadResult(null);
                    }
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    if (cf.get() != null) {
                        cf.get().onLoadResult(resource);
                    }
                    return false;
                }
            });
        } else {
            builder = Glide.with(context).load(url);
        }
        if (placeHolder != null) {
            int id = ResourcesUtils.getResourceIdByUrl(placeHolder, null, ResourcesUtils.TYPE.DRAWABLE);
            if (id > 0) {
                builder = builder.apply(new RequestOptions().placeholder(id));
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
    public Drawable loadProjectImage(Context context, @Nullable String name) {
        if (TextUtils.isEmpty(name))
            return null;
        int id = getProjectImageId(name);
        if (id > 0) {
            return context.getResources().getDrawable(id);
        }
        return null;
    }

    @Override
    public void preload(@NonNull final Context context, @NonNull String url, @Nullable RectF radius, @Nullable DrawableLoadCallback callback) {
        RequestBuilder builder;
        if (callback != null) {
            final WeakReference<DrawableLoadCallback> cf = new WeakReference<>(callback);
            builder = Glide.with(context).load(url).listener(new RequestListener<Drawable>() {

                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    if (cf.get() != null) {
                        cf.get().onLoadResult(null);
                    }
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    if (cf.get() != null) {
                        cf.get().onLoadResult(resource);
                    }
                    return false;
                }
            });
        } else {
            builder = Glide.with(context).load(url);
        }
        builder.preload();
    }
}
