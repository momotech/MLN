/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.provider;

import android.content.Context;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.view.ViewGroup;
import android.widget.ImageView;

/**
 * 提供图片下载功能，用作ImageView相关
 *
 * @author song
 * @date 16/4/11
 * 主要功能描述
 * 修改描述
 * 下午4:48 song XXX
 */
public interface ImageProvider {
    /**
     * 下载图片
     *  @param context
     * @param imageView
     * @param url
     * @param placeHolder
     * @param radius left-top left-bottom right-top right-bottom
     * @param callback
     */
    void load(@NonNull Context context, @NonNull ImageView imageView, @NonNull String url,
              @Nullable String placeHolder, @Nullable RectF radius, @Nullable DrawableLoadCallback callback);

    /**
     * 下载图片，不能被 {@link #pauseRequests(ViewGroup, Context)}打断
     * @param context
     * @param iv
     * @param url
     * @param placeHolder
     * @param radius  left-top left-bottom right-top right-bottom
     * @param callback
     */
    void loadWithoutInterrupt(@NonNull Context context, @NonNull ImageView iv, @NonNull String url,
                              @Nullable String placeHolder, @Nullable RectF radius, @Nullable DrawableLoadCallback callback);

    /**
     * 获取工程内的图片
     * @param context
     * @param name
     * @return
     */
    Drawable loadProjectImage(Context context, @NonNull String name);

    /**
     * 预下载图片
     *
     * @param context
     * @param url
     * @param radius  left-top left-bottom right-top right-bottom
     * @param callback
     */
    void preload(@NonNull Context context, @NonNull String url, @Nullable RectF radius, @Nullable DrawableLoadCallback callback);

    /**
     * pause all requests
     *
     * @param context
     */
    void pauseRequests(@NonNull ViewGroup view, @NonNull Context context);

    /**
     * resume all requests
     *
     * @param context
     */
    void resumeRequests(@NonNull ViewGroup view, @NonNull Context context);


}