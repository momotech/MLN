/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Copyright (C) 2015-2016 Jacksgong(blog.dreamtobe.cn)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.immomo.mls.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;

/**
 * Created by Jacksgong on 3/28/16.
 * <p>
 * For wrap some utils for view.
 */
public class KeyboardViewUtil {


    public static boolean isFullScreen(final Context context) {
        if (context instanceof Activity) {
            return (((Activity) context).getWindow().getAttributes().flags &
                    WindowManager.LayoutParams.FLAG_FULLSCREEN) != 0;

        }
        return false;
    }

    /**
     * 是否给Activity设置了 {@link View#SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN}
     * 如果设置了这个 flag，会导致界面的高度填充到状态栏 与 {@link #isFullScreen(Context)} 的处理逻辑一样
     *
     * @param context
     * @return
     */
    public static boolean isSystemUiVisibilityFullScreen(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            if (context instanceof Activity) {
                return (((Activity) context).getWindow().getDecorView().getSystemUiVisibility() & ((View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN))) != 0;
            }
        }
        return false;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    public static boolean isTranslucentStatus(final Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            if (context instanceof Activity) {
                return (((Activity) context).getWindow().getAttributes().flags &
                        WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS) != 0;
            }
        }
        return false;
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    public static boolean isFitsSystemWindows(final Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            if (context instanceof Activity) {
                return ((ViewGroup) (((Activity) context).findViewById(android.R.id.content))).getChildAt(0).
                        getFitsSystemWindows();
            }
        }
        return false;
    }

}