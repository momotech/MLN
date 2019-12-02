package com.mln.demo.mln.activity;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.Toast;

import com.immomo.luanative.hotreload.HotReloadServer;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.utils.MainThreadExecutor;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

public abstract class BaseActivity extends Activity implements HotReloadHelper.ConnectListener {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        storageAndCameraPermission();
    }

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
        InitData initData = MLSBundleUtils.createInitData("http://cdnst.momocdn.com/w/u/others/2019/09/23/1569224693764-HotReload.lua?ct=" + (usb ? HotReloadServer.USB_CONNECTION : HotReloadServer.NET_CONNECTION)).forceNotUseX64();
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

    // zx add for storage permission 20190806
    private static final int REQUEST_EXTERNAL_STORAGE = 1;
    private static String[] PERMISSIONS_STORAGE = {
            "android.permission.READ_EXTERNAL_STORAGE",
            "android.permission.WRITE_EXTERNAL_STORAGE",
            Manifest.permission.CAMERA};

    public void storageAndCameraPermission() {
        try {
            //检测是否有写的权限
            int permission = ActivityCompat.checkSelfPermission(BaseActivity.this,
                    "android.permission.WRITE_EXTERNAL_STORAGE");
            if (permission != PackageManager.PERMISSION_GRANTED) {
                // 没有写的权限，去申请写的权限，会弹出对话框
                ActivityCompat.requestPermissions(BaseActivity.this, PERMISSIONS_STORAGE, REQUEST_EXTERNAL_STORAGE);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
