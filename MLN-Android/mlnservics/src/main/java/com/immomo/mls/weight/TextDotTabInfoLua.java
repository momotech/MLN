/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight;

import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.immomo.mls.R;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * 带红点的tabinfo
 */
public class TextDotTabInfoLua extends BaseTabLayout.TabInfo {
    private final float PERCENT_THRESHOLD = 0.3f;
    @Nullable
    private TextView hintTextView;
    @Nullable
    private View dotView;
    @Nullable
    protected ScaleLayout titleScaleLayout;
    @Nullable
    protected TextView titleTextView;
    @Nullable
    protected CharSequence title;
    @Nullable
    private CharSequence hint;
    private boolean hasDot = false;
    private float scale = MAX_SCALE_OFFSET;

    public TextDotTabInfoLua(@Nullable CharSequence title) {
        this.title = title;
    }

    public void setHint(@Nullable CharSequence hint) {
        this.hint = hint;
        if (hintTextView != null) {
            if (hint != null && hint.length() != 0) {
                hintTextView.setText(hint);
                hintTextView.setVisibility(View.VISIBLE);
            } else {
                hintTextView.setText("");
                hintTextView.setVisibility(View.GONE);
            }
        }
    }

    public void setHasDot(boolean hasDot) {
        this.hasDot = hasDot;
        if (dotView != null) {
            dotView.setVisibility(hasDot ? View.VISIBLE : View.GONE);
        }
    }

    public void setTitle(@Nullable CharSequence title) {
        this.title = title;
        if (titleTextView != null) {
            titleTextView.setText(title);
        }
    }

    @Nullable
    public CharSequence getTitle() {
        return title;
    }

    @Override
    protected void onAnimatorUpdate(@NonNull BaseTabLayout tabLayout,
                                    @NonNull View customView, float percent) {
        if (titleTextView != null) {
            titleTextView.setTypeface(null, percent > PERCENT_THRESHOLD ? Typeface.BOLD : Typeface.NORMAL);
        }
        if (tabLayout.isEnableScale() && titleScaleLayout != null) {
            titleScaleLayout.setChildScale(1 + scale * percent,
                    1 + scale * percent);
        }
    }

    @NonNull
    @Override
    protected View inflateCustomView(@NonNull BaseTabLayout tabLayout) {
        View rootLayout = LayoutInflater.from(tabLayout.getContext()).inflate(
                R.layout.layout_text_dot_tab_lua, tabLayout, false);
        titleScaleLayout = rootLayout.findViewById(R.id.tab_title_scale_layout_lua);
        titleTextView = rootLayout.findViewById(R.id.tab_title_lua);
        hintTextView = rootLayout.findViewById(R.id.tab_hint_lua);
        dotView = rootLayout.findViewById(R.id.tab_dot_lua);

        inheritTabLayoutStyle(titleTextView, tabLayout);
        titleTextView.setTypeface(null, Typeface.NORMAL);
        setTitle(title);
        setHint(hint);
        setHasDot(hasDot);
        rootLayout.setClickable(true);
        return rootLayout;
    }

    public float getSelectScale() {
        return scale + 1;
    }

    public void setSelectScale(float scale) {
        this.scale = scale - 1;
    }

    public void upDataScale(@NonNull BaseTabLayout tabLayout) {
        if (titleScaleLayout != null && tabLayout.isEnableScale())
            titleScaleLayout.setChildScale(1 + scale, 1 + scale);
    }

    public float getNormalFontSize() {
        if (titleTextView == null) {
            return 0;
        }
        return titleTextView.getTextSize();
    }

    public void setNormalFontSize(float size) {
        if (titleTextView == null) {
            return;
        }
        titleTextView.setTextSize(size);
    }

    public void setTitleColor(int color) {
        if (titleTextView == null || color == titleTextView.getTextColors().getDefaultColor()) {
            return;
        }

        titleTextView.setTextColor(color);
    }
}