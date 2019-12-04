package com.mln.demo;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Handler;
import android.view.View;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.mln.demo.android.activity.IdeaMassActivity;
import com.mln.demo.android.activity.MainTabActivity;
import com.mln.demo.weex.WXPageActivity;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

/**
 * Created by zhang.ke
 * on 2019-11-13
 */
public class LauncherActivity extends AppCompatActivity implements View.OnClickListener {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.mln_btn).setOnClickListener(this);
        findViewById(R.id.native_btn).setOnClickListener(this);
        findViewById(R.id.weex_btn).setOnClickListener(this);

//        final int type;
//        if ("weex".equals(BuildConfig.sdkType)) {
//            type = 3;
//        } else if ("mln".equals(BuildConfig.sdkType)) {
//            type = 2;
//        } else {
//            type = 1;
//        }
//
//        new Handler().postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                gotoPage(type);
//            }
//        }, 500);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.native_btn:
                gotoPage(1);
                break;
            case R.id.mln_btn:
                gotoPage(2);
                break;
            case R.id.weex_btn:
                gotoPage(3);
                break;
        }
    }

    private void gotoPage(int type) {
        switch (type) {
            case 1:
                startActivity(new Intent(this, IdeaMassActivity.class));
                break;
            case 2:
                Intent intent = new Intent(this, com.immomo.mls.activity.LuaViewActivity.class);
                String file = "file://android_asset/MMLuaKitGallery/meilishuo.lua";
                InitData initData = MLSBundleUtils.createInitData(file);
                intent.putExtras(MLSBundleUtils.createBundle(initData));
                startActivity(intent);
                break;

            case 3:
                startActivity(new Intent(this, WXPageActivity.class));
                break;
        }
    }
}
