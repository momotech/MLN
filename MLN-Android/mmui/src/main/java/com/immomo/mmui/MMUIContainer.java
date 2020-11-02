/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.content.Context;
import android.view.KeyEvent;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.ScriptStateListener;

/**
 * Created by Xiong.Fangyu on 2020/8/6
 */
public class MMUIContainer extends FrameLayout implements ScriptStateListener {
    public MMUIContainer(@NonNull Context context, boolean showDebugButton) {
        super(context);
        init(context, showDebugButton);
    }

    private MMUIInstance instance;

    private void init(Context context, boolean showDebugButton) {
        instance = new MMUIInstance(context, showDebugButton, showDebugButton);
        instance.setContainer(this);
    }

    public void setData(InitData data) {
        data.showLoadingView(showLoadingView());
        instance.setData(data);
        if (!data.hasType(Constants.LT_SHOW_LOAD)) {
            instance.setScriptStateListener(this);
        }
    }

    public void setUrl(String url) {
        setData(MLSBundleUtils.createInitData(url));
    }

    public boolean isValid() {
        return instance.isValid();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (instance.dispatchKeyEvent(event))
            return true;
        return super.dispatchKeyEvent(event);
    }

    public void onResume() {
        instance.onResume();
    }

    public void onPause() {
        instance.onPause();
    }

    public void onDestroy() {
        instance.onDestroy();
    }

    protected boolean showLoadingView() {
        return false;
    }

    @Override
    public void onSuccess() {

    }

    @Override
    public void onFailed(ScriptStateListener.Reason reason) {

    }
}
