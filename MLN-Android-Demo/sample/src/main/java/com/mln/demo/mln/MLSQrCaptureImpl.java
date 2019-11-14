package com.mln.demo.mln;

import android.content.Context;
import android.content.Intent;

import com.google.zxing.client.android.CaptureActivity;
import com.immomo.mls.adapter.MLSQrCaptureAdapter;


public class MLSQrCaptureImpl implements MLSQrCaptureAdapter {
    @Override
    public void startQrCapture(Context context) {
        Intent intent = new Intent(context, CaptureActivity.class);
        context.startActivity(intent);

    }
}
