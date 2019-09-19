/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.immomo.mls.weight;

import android.content.Context;
import android.graphics.drawable.Drawable;
import androidx.appcompat.widget.TintTypedArray;
import android.util.AttributeSet;
import android.view.View;

/**
 * TabItem is a special 'view' which allows you to declare tab items for a {@link TabLayout}
 * within a layout. This view is not actually added to TabLayout, it is just a dummy which allows
 * setting of a tab items's text, icon and custom layout. See TabLayout for more information on how
 * to use it.
 *
 * @attr ref android.android.support.design.R.styleable#TabItem_android_icon
 * @attr ref android.android.support.design.R.styleable#TabItem_android_text
 * @attr ref android.android.support.design.R.styleable#TabItem_android_layout
 */
public final class CustomTabItem extends View {
    final CharSequence mText;
    final Drawable mIcon;
    final int mCustomLayout;

    public CustomTabItem(Context context) {
        this(context, null);
    }

    public CustomTabItem(Context context, AttributeSet attrs) {
        super(context, attrs);
        mText = "";
        mIcon = null;
        mCustomLayout = 0;
    }
}