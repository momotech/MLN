/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.immomo.mln.R;
import com.immomo.mls.Constants;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.activity.LuaViewActivity;

public class MainActivity extends BaseActivity implements View.OnClickListener{
    private static final String URL_COURSE = "https://mln.immomo.com/zh-cn/docs/build_dev_environment.html";
    private static final String URL_INSTANCE = "https://mln.immomo.com/zh-cn/api/NewListView.lua.html";
    private static final String URL_CONSULT = "https://github.com/momotech/MLN";
    private static final String URL_ABOUT = "https://mln.immomo.com/zh-cn/";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();

        findViewById(R.id.tvDevDebug).setVisibility(MLSEngine.DEBUG ? View.VISIBLE : View.GONE);
    }

    private void initView() {
        findViewById(R.id.tvInnerDemo).setOnClickListener(this);
        findViewById(R.id.tvCourse).setOnClickListener(this);
        findViewById(R.id.tvInstance).setOnClickListener(this);
        findViewById(R.id.tvConsult).setOnClickListener(this);
        findViewById(R.id.tvAbout).setOnClickListener(this);
        findViewById(R.id.tvDevDebug).setOnClickListener(this);
        findViewById(R.id.tvDemo).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvInnerDemo:
                AssetsChooserActivity.startActivity(this, "inner_demo");
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
            case R.id.tvDemo:
                Intent intent = new Intent(this, LuaViewActivity.class);
                InitData initData = MLSBundleUtils.createInitData(Constants.ASSETS_PREFIX + "MMLuaKitGallery/meilishuo.lua");
                intent.putExtras(MLSBundleUtils.createBundle(initData));
                startActivity(intent);
                break;
        }
    }
}