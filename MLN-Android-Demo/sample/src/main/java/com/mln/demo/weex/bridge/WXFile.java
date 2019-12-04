/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.mln.demo.weex.bridge;

import android.os.Environment;
import android.util.Log;

import com.mln.demo.App;
import com.mln.demo.BuildConfig;
import com.mln.demo.weex.utils.FileUtil;
import com.mln.demo.weex.utils.JsonUtil;
import com.mln.demo.weex.utils.MLSAdapterContainer;
import com.mln.demo.weex.utils.MLSThreadAdapter;
import com.taobao.weex.WXSDKManager;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Created by zhang.ke
 * on 2019-12-03
 */
public class WXFile extends WXModule {

    private static final int CODE_NOT_EXIST = -1;
    private static final int CODE_NOT_FILE = -2;
    private static final int CODE_READ_ERROR = -3;
    private static final int CODE_JSON_FAILED = -4;

    private static final String ASSETS_PREFIX = "file://android_asset/";
    public static final String ASSETS = "android_asset";

    @JSMethod
    public void asyncReadMapFile(JSCallback callback) {
        String path = ASSETS_PREFIX + "discoverry_detail.json";
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONReadTask(path, callback));
    }

    private static final class JSONReadTask extends BaseReadTask {

        JSONReadTask(String path, JSCallback callback) {
            super(path, callback);
        }

        @Override
        protected Object parse(String result) {
            try {
                return JsonUtil.toMap(new JSONObject(result));
            } catch (JSONException e) {
                callbackError(CODE_JSON_FAILED);
            }
            return null;
        }
    }

    private abstract static class BaseReadTask extends BaseCallbackTask {
        String path;

        BaseReadTask(String path, JSCallback callback) {
            super(callback);
            this.path = path;
        }

        @Override
        public void run() {

            if (path.startsWith(ASSETS_PREFIX)) {
                String fileName = getFileName(path);

                String assetsFile = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + ASSETS + File.separator + fileName;

                if (!new File(assetsFile).exists()) {
                    copyAssets2SDCard(fileName);
                    if (BuildConfig.DEBUG)
                        Log.d("assets", "进入到拷贝到sdk目录代码了。。。。。 ");
                }

                path = assetsFile;
            }

            File target = new File(path);
            if (!target.exists()) {
                callbackError(CODE_NOT_EXIST);
                return;
            }
            if (!target.isFile()) {
                callbackError(CODE_NOT_FILE);
                return;
            }
            byte[] data = FileUtil.fastReadBytes(target);
            if (data == null) {
                callbackError(CODE_READ_ERROR);
                return;
            }
            callback(new String(data));
        }

        private String getFileName(String path) {
            if (path == null || path.length() == 0)
                return "";

            return path.substring(path.lastIndexOf("/") + 1);
        }


        private void copyAssets2SDCard(String fileName) {
            try {
                InputStream in = App.getApp().getClassLoader().getResourceAsStream("assets/" + fileName);
                File file = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/" , ASSETS + File.separator + fileName);
                File parent = file.getParentFile();
                if (parent != null && !file.getParentFile().exists()) {
                    parent.mkdirs();
                }
                FileOutputStream fos = new FileOutputStream(file);
                int len = 0;
                byte[] buffer = new byte[1024];
                while ((len = in.read(buffer)) != -1) {
                    fos.write(buffer, 0, len);
                    fos.flush();
                }
                in.close();
                fos.close();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        protected void callback(String result) {
            if (callback != null) {
                Object ret = parse(result);
                if (ret == null)
                    return;
                callbackInMain(ret);
            }
        }

        protected abstract Object parse(String result);

    }


    private abstract static class BaseCallbackTask implements Runnable {
        JSCallback callback;

        BaseCallbackTask(JSCallback callback) {
            this.callback = callback;
        }

        protected final void callbackError(int code) {
            if (callback != null) {
//                callbackInMain(code);
            }
        }

        protected void callbackInMain(final Object param) {
            WXSDKManager.getInstance().postOnUiThread(new Runnable() {
                @Override
                public void run() {
                    callback.invoke(param);
                }
            }, 0);

        }
    }
}
