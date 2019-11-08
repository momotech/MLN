/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.demo;

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
