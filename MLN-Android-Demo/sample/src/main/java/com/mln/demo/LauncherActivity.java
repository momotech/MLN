package com.mln.demo;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.mln.demo.android.activity.MainTabActivity;

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

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.mln_btn:
                Intent intent = new Intent(this, com.immomo.mls.activity.LuaViewActivity.class);
                String file = "file://android_asset/MMLuaKitGallery/meilishuo.lua";
                InitData initData = MLSBundleUtils.createInitData(file);
                intent.putExtras(MLSBundleUtils.createBundle(initData));
                startActivity(intent);
                break;
            case R.id.native_btn:
                startActivity(new Intent(this, MainTabActivity.class));
                break;
        }
    }
}
