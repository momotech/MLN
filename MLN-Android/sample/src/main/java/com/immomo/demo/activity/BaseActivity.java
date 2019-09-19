/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.view.WindowManager;
import android.widget.Toast;

import com.immomo.luanative.hotreload.HotReloadServer;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.utils.MainThreadExecutor;

public class BaseActivity extends Activity implements HotReloadHelper.ConnectListener {

    @Override
    public void onConnected(final boolean hasCallback) {
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                if (!hasCallback) {
                    Toast.makeText(MLSEngine.getContext(), "connect with wifi success", Toast.LENGTH_LONG).show();
                    startTeach(false);
                }
                HotReloadHelper.setConnectListener(null);
            }
        });
    }

    protected void startTeach(boolean usb) {
        InitData initData = MLSBundleUtils.createInitData("http://cdnst.momocdn.com/w/u/others/2019/08/21/1566360807746-HotReload.lua?ct=" + (usb ? HotReloadServer.USB_CONNECTION : HotReloadServer.NET_CONNECTION)).forceNotUseX64();
        Intent intent = new Intent(BaseActivity.this, LuaViewActivity.class);
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        startActivity(intent);
    }

    @Override
    public void onDisConnected() {
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                HotReloadHelper.setConnectListener(null);
            }
        });
    }
}