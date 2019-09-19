/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.activity;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.zxing.client.android.CaptureActivity;
import com.immomo.mln.R;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.MLSEngine;

public class MainActivity extends BaseActivity implements View.OnClickListener{
    private static final String URL_COURSE = "https://mln.immomo.com/zh-cn/docs/build_dev_environment.html";
    private static final String URL_INSTANCE = "https://mln.immomo.com/zh-cn/api/NewListView.lua.html";
    private static final String URL_CONSULT = "https://github.com/wemomo";
    private static final String URL_ABOUT = "https://mln.immomo.com/zh-cn/";

    private static final long DOUBLE_TIME = 1000;
    private static long lastClickTime = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();

        if (MLSEngine.DEBUG)
            findViewById(R.id.tvDevDebug).setVisibility(View.VISIBLE);
    }

    private void initView() {
        findViewById(R.id.btnOpenQr).setOnClickListener(this);
        findViewById(R.id.tvCourse).setOnClickListener(this);
        findViewById(R.id.tvInstance).setOnClickListener(this);
        findViewById(R.id.tvConsult).setOnClickListener(this);
        findViewById(R.id.tvAbout).setOnClickListener(this);
        findViewById(R.id.tvDevDebug).setOnClickListener(this);
        findViewById(R.id.imgLogo).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.imgLogo:
                if (!MLSEngine.DEBUG)
                    return;

                long currentTimeMillis = System.currentTimeMillis();
                if (currentTimeMillis - lastClickTime < DOUBLE_TIME) {

                }
                lastClickTime = currentTimeMillis;
                break;

            case R.id.btnOpenQr:
                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.CAMERA,Manifest.permission.WRITE_EXTERNAL_STORAGE}, 0);
                } else if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 0);
                } else {
                    HotReloadHelper.setConnectListener(this);
                    startActivity(new Intent(MainActivity.this, CaptureActivity.class));
                }
                break;
            case R.id.tvCourse:
                WebActivity.startActivity(this,URL_COURSE);
                break;
            case R.id.tvInstance:
                WebActivity.startActivity(this,URL_INSTANCE);
                break;
            case R.id.tvConsult:
                WebActivity.startActivity(this,URL_CONSULT);
                break;
            case R.id.tvAbout:
                WebActivity.startActivity(this,URL_ABOUT);
                break;

            case R.id.tvDevDebug:
                HotReloadHelper.setConnectListener(this);
                startTeach(true);
                break;
        }
    }
}