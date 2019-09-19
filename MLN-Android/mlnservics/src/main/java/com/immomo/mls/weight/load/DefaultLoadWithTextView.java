/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight.load;

import android.content.Context;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.R;


/**
 * Created by XiongFangyu on 2018/6/21.
 */
public class DefaultLoadWithTextView extends FrameLayout implements ILoadWithTextView {

    private DefaultLoadView defaultLoadView;
    private TextView loadText;

    public DefaultLoadWithTextView(Context context) {
        this(context, null);
    }

    public DefaultLoadWithTextView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DefaultLoadWithTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        View v = LayoutInflater.from(getContext()).inflate(R.layout.lv_default_load_with_text_view, this);
        LayoutParams p = (LayoutParams) v.getLayoutParams();
        if (p == null) {
            p = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, DimenUtil.dpiToPx(100));
        }
        p.gravity = Gravity.CENTER;
        v.setLayoutParams(p);
        defaultLoadView = (DefaultLoadView) findViewById(R.id.lv_default_load_view);
        loadText = (TextView) findViewById(R.id.lv_default_load_tv);
    }

    @Override
    public void startAnim() {
        defaultLoadView.startAnim();
    }

    @Override
    public void stopAnim() {
        defaultLoadView.stopAnim();
    }

    @Override
    public void showLoadAnimView() {
        defaultLoadView.showLoadAnimView();
    }

    @Override
    public void hideLoadAnimView() {
        defaultLoadView.hideLoadAnimView();
    }

    @Override
    public void setLoadText(CharSequence text) {
        loadText.setText(text);
    }

    @Override
    public View getView() {
        return this;
    }
}