/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.debug;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.Switch;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.R;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by fanqiang on 2018/9/7.
 */
public class DebugView extends FrameLayout implements CompoundButton.OnCheckedChangeListener, View.OnClickListener {

    private EditText etDebugIp;
    private EditText edDebugPort;
    private Switch swDebug;

    public static DebugView getDebugView(Context context) {
        DebugView debugView = new DebugView(context);
        return debugView;
    }

    public DebugView(@NonNull Context context) {
        super(context);
        intView();
    }

    public DebugView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        intView();
    }


    private void intView() {
        View view = View.inflate(getContext(), R.layout.debug, this);
        etDebugIp = view.findViewById(R.id.etDebugIp);
        edDebugPort = view.findViewById(R.id.edDebugPort);
        swDebug = view.findViewById(R.id.swDebug);

        etDebugIp.setText(MLSEngine.getDebugIp());
        edDebugPort.setText(MLSEngine.getDebugPort() + "");
        swDebug.setChecked(MLSEngine.isOpenDebugger());
        swDebug.setOnCheckedChangeListener(this);

        view.findViewById(R.id.set).setOnClickListener(this);
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        MLSEngine.setOpenDebugger(isChecked);
    }

    @Override
    public void onClick(View v) {
        String ip = etDebugIp.getText().toString();
        String port = edDebugPort.getText().toString();
        if (!TextUtils.isEmpty(ip)) {
            MLSEngine.setDebugIp(ip);
        }
        if (!TextUtils.isEmpty(port)) {
            MLSEngine.setDebugPort(Integer.parseInt(port));
        }
    }
}