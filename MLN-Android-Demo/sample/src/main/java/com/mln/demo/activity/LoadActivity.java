package com.mln.demo.activity;

import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.google.zxing.client.android.CaptureActivity;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSEngine;
import com.mln.demo.App;
import com.mln.demo.R;

import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/8/29.
 */

public class LoadActivity extends BaseActivity implements View.OnClickListener{

    private static final int CHOOSE_ASSETS = 0x123;
    private static final int CHOOSE_SDCARD = 0x124;

    private TextView ipTV, debugTV;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_load);
        findViewById(R.id.qr).setOnClickListener(this);
        findViewById(R.id.connect_hr).setOnClickListener(this);
        ipTV = findViewById(R.id.debug_ip);
        ipTV.setOnClickListener(this);
        setDebugInfo();
        debugTV = findViewById(R.id.debug_open);
        debugTV.setOnClickListener(this);
        findViewById(R.id.test).setOnClickListener(this);
        findViewById(R.id.test_weidget).setOnClickListener(this);
        findViewById(R.id.test_lua_sdk).setOnClickListener(this);
        findViewById(R.id.choose_assets).setOnClickListener(this);
        findViewById(R.id.choose_sd_file).setOnClickListener(this);
        findViewById(R.id.test_sqlite).setOnClickListener(this);

        storageAndCameraPermission();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id) {
            case R.id.qr:
                HotReloadHelper.setConnectListener(this);
                startActivity(new Intent(this, CaptureActivity.class));
                break;
            case R.id.connect_hr:
                startTeach(true);
                break;
            case R.id.debug_ip:
                showIpDialog();
                break;
            case R.id.debug_open:
                boolean open = MLSEngine.isOpenDebugger();
                MLSEngine.setOpenDebugger(!open);
                debugTV.setText("debug open: " + (open ? "off" : "on"));
                break;
            case R.id.test:
                startActivity(new Intent(this, DemoActivity.class));
                break;
            case R.id.test_sqlite:
                DemoActivity.startActivity(this, id == R.id.test_sqlite ? "sqlite" : null);
                break;
            case R.id.test_weidget:
                startActivity(new Intent(this, WeidgetTesterActivity.class));
                break;
            case R.id.test_lua_sdk:
                startActivity(new Intent(this, LuaSDKTestActivity.class));
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            String file = null;
            switch (requestCode) {
                case CHOOSE_ASSETS:
                    file = "file://android_asset/" + data.getStringExtra(ChooseFileActivity.KEY_FILE);
                    break;
                case CHOOSE_SDCARD:
                    file = data.getStringExtra(ChooseFileActivity.KEY_FILE);
                    break;
            }
            if (file == null)
                return;
            final Intent intent = new Intent(this, LuaViewActivity.class);
            InitData initData = MLSBundleUtils.createInitData(file, false);
            intent.putExtras(MLSBundleUtils.createBundle(initData));
            startActivity(intent);
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    private void showIpDialog() {
        Dialog d = new Dialog(this);
        View layout = LayoutInflater.from(this).inflate(R.layout.layout_reset_usb_port, null);
        d.setContentView(layout);
        final EditText ipet = layout.findViewById(R.id.ip);
        final EditText port = layout.findViewById(R.id.port);
        d.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                String ip = ipet.getText().toString();
                String pt = port.getText().toString();
                if (!TextUtils.isEmpty(ip))
                    MLSEngine.setDebugIp(ip);
                if (!TextUtils.isEmpty(pt)) {
                    MLSEngine.setDebugPort(Integer.parseInt(pt));
                }
                setDebugInfo();
            }
        });
        d.show();
    }

    private void setDebugInfo() {
        ipTV.setText("debug remote ip: " + MLSEngine.getDebugIp() + ":" + MLSEngine.getDebugPort());
    }

}
