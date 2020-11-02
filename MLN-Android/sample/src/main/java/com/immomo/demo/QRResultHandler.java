/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.text.TextUtils;
import android.widget.Toast;

import com.google.zxing.OuterResultHandler;
import com.google.zxing.Result;
import com.google.zxing.client.android.result.ResultHandler;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.activity.LuaViewActivity;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mmui.MMUIActivity;

/**
 * Created by Xiong.Fangyu on 2019/4/22
 */
public class QRResultHandler implements OuterResultHandler.IResultHandler {
    private static final String DEBUG_SCRIPT = "debug.lua";
    private static final String KEY_HOT_RELOAD = "KEY_HOT_RELOAD";

    @Override
    public boolean handle(Activity activity, Result rawResult, ResultHandler resultHandler, Bitmap barcode) {
        String code = rawResult.getText();
        if (TextUtils.isEmpty(code)) return false;

        if (HotReloadHelper.isIPPortString(code)) {
            boolean r = HotReloadHelper.setUseWifi(code);
            if (!r)
                toast("connect with wifi failed");
            else
                toast("connecting...");
            activity.finish();
            return true;
        }

        Uri uri = Uri.parse(code);
        boolean isMMUI = "true".equals(uri.getQueryParameter("mmui"));
        Class<? extends Activity> clz = isMMUI ? MMUIActivity.class : LuaViewActivity.class;
        Intent intent = new Intent(activity, clz);
        InitData initData = MLSBundleUtils.createInitData(code).forceDownload();
        if (isDebugScript(uri)) {
            handleDebugScript(code);
            activity.finish();
            return true;
        }
//            initData.doAutoPreload = !uri.getHost().startsWith("172.16") || uri.getPath().endsWith(".zip");
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        activity.startActivity(intent);
        return true;
    }

    private static void handleDebugScript(final String code) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    MLSAdapterContainer.getHttpAdapter().downloadLuaFileSync(code, FileUtil.getLuaDir().getAbsolutePath(), DEBUG_SCRIPT, null, null, null, 0);
                    toast("下载debug脚本成功");
                } catch (ScriptLoadException e) {
                    e.printStackTrace();
                    toast("下载debug脚本失败：");
                }
            }
        }).start();
    }

    private static void toast(final String msg) {
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(MLSEngine.getContext(), msg, Toast.LENGTH_LONG).show();
            }
        });
    }

    private static boolean isDebugScript(Uri uri) {
        String path = uri.getPath();
        int index = path.lastIndexOf('/');
        if (index >= 0) {
            path = path.substring(index + 1);
        }
        return DEBUG_SCRIPT.equals(path);
    }
}