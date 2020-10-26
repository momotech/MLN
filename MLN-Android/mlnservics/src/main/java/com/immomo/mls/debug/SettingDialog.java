/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.debug;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;

import androidx.appcompat.app.AppCompatDialog;

import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.R;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class SettingDialog extends AppCompatDialog implements View.OnClickListener, CompoundButton.OnCheckedChangeListener {

    private static final String UNKNOWN = "unknown";

    private EditText etDebugIp;
    private EditText edDebugPort;

    private EditText hr_use_port;
    private EditText hr_serial;

    private boolean showDebug;
    private boolean showHotReload;

    private boolean debugState;

    private Button btnStartLog;
    private Button btnFinishLog;

    public SettingDialog(Context context) {
        this(context, true, true);
    }

    public SettingDialog(Context context, boolean showDebug, boolean showHotReload) {
        super(context);
        this.showDebug = showDebug;
        this.showHotReload = showHotReload;
        initView();
    }

    private void initView() {
        setContentView(R.layout.layout_setting_view);
        View debugContainer = findViewById(R.id.lua_setting_debug);
        View hotReloadContainer = findViewById(R.id.lua_setting_hr);
        View serialContainer = findViewById(R.id.lua_setting_serial);

        etDebugIp = findViewById(R.id.etDebugIp);
        edDebugPort = findViewById(R.id.edDebugPort);
        Switch swDebug = findViewById(R.id.swDebug);
        debugState = MLSEngine.isOpenDebugger();
        swDebug.setChecked(debugState);
        swDebug.setOnCheckedChangeListener(this);

        hr_use_port = findViewById(R.id.hr_use_port);
        hr_serial = findViewById(R.id.hr_serial);

        findViewById(R.id.btn_cancel).setOnClickListener(this);
        findViewById(R.id.btn_confirm).setOnClickListener(this);
        findViewById(R.id.btn_start_log).setOnClickListener(this);
        findViewById(R.id.btn_finish_log).setOnClickListener(this);

        if (!showHotReload) {
            hotReloadContainer.setVisibility(View.GONE);
            serialContainer.setVisibility(View.GONE);
        } else {
            hr_use_port.setText("" + HotReloadHelper.getUsbPort());
            String s = HotReloadHelper.getSerial();
            if (UNKNOWN.equalsIgnoreCase(s))
                s = null;
            hr_serial.setText(s);
        }
        if (!showDebug) {
            debugContainer.setVisibility(View.GONE);
        } else {
            etDebugIp.setText(MLSEngine.getDebugIp());
            edDebugPort.setText(MLSEngine.getDebugPort() + "");
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_cancel) {
            dismiss();
        } else if (id == R.id.btn_confirm) {
            if (showDebug)
                setDebug();
            if (showHotReload)
                setHotReload();
            dismiss();
        } else if(id == R.id.btn_start_log) {
            Globals.setStatistic((char) 0);
            Globals.setStatistic((char) (Globals.STATISTIC_BRIDGE + Globals.STATISTIC_REQUIRE));
        } else if(id == R.id.btn_finish_log) {
            Globals.notifyStatisticsCallback();
        }
    }

    private void setHotReload() {
        String ps = hr_use_port.getText().toString();
        try {
            HotReloadHelper.setUseUSB(Integer.parseInt(ps));
        } catch (Throwable t) {
            MLSAdapterContainer.getToastAdapter().toast("请输入数字");
        }
        Editable editable = hr_serial.getText();
        if (editable != null) {
            String s = editable.toString();
            HotReloadHelper.setSerial(s);
            MLSAdapterContainer.getFileCache().save("android_serial", s);
        }
    }

    private void setDebug() {
        String ip = etDebugIp.getText().toString();
        String port = edDebugPort.getText().toString();
        if (!TextUtils.isEmpty(ip)) {
            MLSEngine.setDebugIp(ip);
        }
        if (!TextUtils.isEmpty(port)) {
            MLSEngine.setDebugPort(Integer.parseInt(port));
        }
        MLSEngine.setOpenDebugger(debugState);
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        debugState = isChecked;
    }
}
