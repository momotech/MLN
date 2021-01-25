/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.immomo.luanative.hotreload.HotReloadServer;
import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSInstance;

public class LuaViewActivity extends AppCompatActivity {
    public static final String KEY_HOT_RELOAD = "KEY_HOTRELOAD";

    private MLSInstance instance;

    public static void startHotReload(Context context, boolean usb) {
        InitData initData = MLSBundleUtils.createInitData(Constants.ASSETS_PREFIX + "hotreload.lua?ct=" + (usb ? HotReloadServer.USB_CONNECTION : HotReloadServer.NET_CONNECTION));
        Intent intent = new Intent(context, LuaViewActivity.class);
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        intent.putExtra(KEY_HOT_RELOAD, true);

        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FrameLayout frameLayout = new FrameLayout(this);
        setContentView(frameLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        Intent intent = getIntent();
        boolean hr = intent.getBooleanExtra(KEY_HOT_RELOAD, false);
        InitData initData = MLSBundleUtils.parseFromBundle(intent.getExtras()).showLoadingView(true);
        instance = new MLSInstance(this, hr, true);
        instance.setContainer(frameLayout);
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
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            if (event.getAction() != KeyEvent.ACTION_UP)
                instance.dispatchKeyEvent(event);

            if (!instance.getBackKeyEnabled())
                return true;
        }
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