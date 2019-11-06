package com.immomo.mls.adapter.impl;

import android.widget.Toast;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.ToastAdapter;

/**
 * Created by XiongFangyu on 2018/6/27.
 */
public class DefaultToastAdapter implements ToastAdapter {

    @Override
    public void toast(String msg) {
        toast(msg, Toast.LENGTH_SHORT);
    }

    @Override
    public synchronized void toast(String msg, int len) {
        if (len != 0) {
            len = Toast.LENGTH_LONG;
        }
        Toast.makeText(MLSEngine.getContext(), msg, len).show();
    }
}
