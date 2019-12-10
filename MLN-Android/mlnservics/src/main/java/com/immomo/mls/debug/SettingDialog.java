/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.debug;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;

import androidx.appcompat.app.AppCompatDialog;

import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.R;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class SettingDialog extends AppCompatDialog implements View.OnClickListener, CompoundButton.OnCheckedChangeListener {

    private EditText etDebugIp;
    private EditText edDebugPort;

    private EditText hr_use_port;

    private boolean showDebug;
    private boolean showHotReload;

    private boolean debugState;

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

        etDebugIp = findViewById(R.id.etDebugIp);
        edDebugPort = findViewById(R.id.edDebugPort);
        Switch swDebug = findViewById(R.id.swDebug);
        debugState = MLSEngine.isOpenDebugger();
        swDebug.setChecked(debugState);
        swDebug.setOnCheckedChangeListener(this);

        hr_use_port = findViewById(R.id.hr_use_port);

        findViewById(R.id.btn_cancel).setOnClickListener(this);
        findViewById(R.id.btn_confirm).setOnClickListener(this);

        if (!showHotReload) {
            hotReloadContainer.setVisibility(View.GONE);
        }
        if (!showDebug) {
            debugContainer.setVisibility(View.GONE);
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
        }
    }

    private void setHotReload() {
        String ps = hr_use_port.getText().toString();
        if (TextUtils.isEmpty(ps))
            return;
        try {
            HotReloadHelper.setUseUSB(Integer.parseInt(ps));
        } catch (Throwable t) {
            MLSAdapterContainer.getToastAdapter().toast("请输入数字");
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
