/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.immomo.luanative.hotreload.HotReloadServer;
import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.util.LogUtil;

/**
 * Created by Xiong.Fangyu on 2020-05-27
 */
public class MMUIActivity extends AppCompatActivity {

    private static final String KEY_HOT_RELOAD = "KEY_HOT_RELOAD";
    private MMUIInstance instance;

    public static void startHotReload(Context context, boolean usb) {
        InitData initData = MLSBundleUtils.createInitData(Constants.ASSETS_PREFIX + "hotreload_mmui.lua?ct=" + (usb ? HotReloadServer.USB_CONNECTION : HotReloadServer.NET_CONNECTION)).forceNotUseX64();
        Intent intent = new Intent(context, MMUIActivity.class);
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        intent.putExtra(KEY_HOT_RELOAD, true);

        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FrameLayout frameLayout = new FrameLayout(this);
        setContentView(frameLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        Intent intent = getIntent();
        boolean hr = intent.getBooleanExtra(KEY_HOT_RELOAD, false);
        InitData initData = MLSBundleUtils.parseFromBundle(intent.getExtras()).showLoadingView(true);
        instance = new MMUIInstance(this, hr, hr);
        instance.setContainer(frameLayout);
        instance.setScriptReader(MLSAdapterContainer.getScriptReaderCreator().newScriptLoader(initData.url));
        instance.setData(initData);

        if (instance == null || !instance.isValid()) {
            Toast.makeText(this, "something wrong", Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        instance.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        instance.onPause();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        LogUtil.d("  dispatchKeyEvent  ", event);
        if (instance.dispatchKeyEvent(event))
            return true;
        return super.dispatchKeyEvent(event);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        instance.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (instance.onActivityResult(requestCode, resultCode, data))
            return;
        super.onActivityResult(requestCode, resultCode, data);
    }
}
