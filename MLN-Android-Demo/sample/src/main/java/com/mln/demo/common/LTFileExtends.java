package com.mln.demo.common;

import android.util.Log;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.lt.LTFile;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.JsonUtil;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.MainThreadExecutor;
import com.mln.demo.App;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019-11-06
 * Time         :   15:28
 * Description  :
 */
@LuaClass(isStatic = true)
public class LTFileExtends extends LTFile {

    private static final int CODE_NOT_EXIST = -1;
    private static final int CODE_NOT_FILE = -2;
    private static final int CODE_READ_ERROR = -3;
    private static final int CODE_JSON_FAILED = -4;

    private static final String ASSETS_PREFIX = "file://android_asset/";
    public static final String ASSETS = "android_asset";

    @LuaBridge
    public static void asyncReadMapFile(String path, LVCallback callback) {

        if (path.startsWith(ASSETS_PREFIX)) {

        } else if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONReadTask(path, callback));
    }

    private static final class JSONReadTask extends BaseReadTask {

        JSONReadTask(String path, LVCallback callback) {
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

        BaseReadTask(String path, LVCallback callback) {
            super(callback);
            this.path = path;
        }

        @Override
        public void run() {

            if (path.startsWith(ASSETS_PREFIX)) {
                String fileName = getFileName(path);

                String assetsFile = FileUtil.getLuaDir() + File.separator + ASSETS + File.separator + fileName;

                if (!new File(assetsFile).exists()) {
                    copyAssets2SDCard(fileName);
                    if (MLSEngine.DEBUG)
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
                File file = new File(FileUtil.getLuaDir(), ASSETS + File.separator + fileName);
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
                callbackInMain(0, ret);
            }
        }

        protected abstract Object parse(String result);

    }


    private abstract static class BaseCallbackTask implements Runnable {
        LVCallback callback;

        BaseCallbackTask(LVCallback callback) {
            this.callback = callback;
        }

        protected final void callbackError(int code) {
            if (callback != null) {
                callbackInMain(code);
            }
        }

        protected void callbackInMain(final Object... param) {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    callback.call(param);
                }
            });
        }
    }

}
