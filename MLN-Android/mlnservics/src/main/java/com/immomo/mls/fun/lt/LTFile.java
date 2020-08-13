/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import android.text.TextUtils;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.FileInfo;
import com.immomo.mls.util.EncryptUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.util.JsonUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.MainThreadExecutor;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaValue;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/13.
 */
@LuaClass(isStatic = true)
public class LTFile {
    public static final String LUA_CLASS_NAME = "File";

    //<editor-fold desc="API-1.5.1">
    @LuaBridge
    public static int syncMoveFile(String old, String newPath) {
        File oldFile = new File(old);
        if (!oldFile.exists()) {
            return CODE_SOURCE_NOT_EXIST;
        }
        File dest = new File(newPath);
        if (dest.exists()) {
            return CODE_SAME_FILE;
        }
        return oldFile.renameTo(dest) ? CODE_NO_ERROR : CODE_MOVE_FAILED;
    }
    //</editor-fold>

    //<editor-fold desc="API-1.2.11">
    @Deprecated
    @LuaBridge
    public static String getStorageDir() {
        return FileUtil.getSdcardDir().getAbsolutePath();
    }

    @LuaBridge
    public static String rootPath() {
        return FileUtil.getRootDir().getAbsolutePath();
    }

    @LuaBridge
    public static void asyncCreateFile(String path, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new CreateFileTask(path, callback));
    }

    @LuaBridge
    public static void asyncCreateDirs(String path, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new CreateDirsTask(path, callback));
    }

    @LuaBridge
    public static void asyncDelete(String path, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new DeleteTask(path, callback));
    }

    @LuaBridge
    public static void asyncMoveFile(Globals g, String fromPath, String toPath, final LVCallback callback) {
        ErrorUtils.debugDeprecateMethod("asyncMoveFile", "syncMoveFile", g);
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new MoveFileTask(fromPath, toPath, callback));
    }

    @LuaBridge
    public static void asyncCopyFile(String fromPath, String toPath, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new CopyFileTask(fromPath, toPath, callback));
    }

    @LuaBridge
    public static void asyncGetFileList(String path, boolean recurisve, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new GetFileListTask(path, recurisve, callback));
    }

    @LuaBridge
    public static Map getFileInfo(String path) {
        if (TextUtils.isEmpty(path)) {
            ErrorUtils.debugUnsupportError("path can`t be null");
            return null;
        }
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        File file = new File(path);
        if (!file.exists()) {
            return null;
        }
        Map<String, Object> fileInfo = new HashMap<>();
        fileInfo.put(FileInfo.FileSize, file.length());
        fileInfo.put(FileInfo.ModiDate, file.lastModified() / 1000f);

        return fileInfo;
    }

    //</editor-fold>

    //<editor-fold desc="API">
    @LuaBridge
    public static boolean exist(String path) {
        if (TextUtils.isEmpty(path))
            return false;
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        return FileUtil.exists(path);
    }

    @LuaBridge
    public static boolean isDir(String path) {
        if (TextUtils.isEmpty(path))
            return false;
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        return new File(path).isDirectory();
    }

    @LuaBridge
    public static boolean isFile(String path) {
        if (TextUtils.isEmpty(path))
            return false;
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        return new File(path).isFile();
    }

    @LuaBridge
    public static void asyncReadFile(String path, final LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new StringReadTask(path, callback));
    }

    @LuaBridge
    public static void asyncReadMapFile(String path, LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONReadTask(path, callback));
    }

    @LuaBridge
    public static void asyncReadArrayFile(String path, LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONArrayTask(path, callback));
    }

    @LuaBridge
    public static void asyncWriteFile(String path, String str, LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteStringTask(path, callback, str));
    }

    @LuaBridge
    public static void asyncWriteMap(String path, Map map, LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteJsonTask(path, callback, map));
    }

    @LuaBridge
    public static void asyncWriteArray(String path, List array, LVCallback callback) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteArrayTask(path, callback, array));
    }

    @LuaBridge
    public static void asyncUnzipFile(String sourcePath, String targetPath, LVCallback callback) {
        String returnPath = sourcePath;
        if (RelativePathUtils.isLocalUrl(sourcePath)) {
            sourcePath = RelativePathUtils.getAbsoluteUrl(sourcePath);
        }
        if (RelativePathUtils.isLocalUrl(targetPath)) {
            targetPath = RelativePathUtils.getAbsoluteUrl(targetPath);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH,
                new UnZipTask(sourcePath, targetPath, sourcePath, callback));
    }

    @LuaBridge
    public static void asyncMd5File(Globals g, String path, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new FileMD5Task(g, path, callback));
    }

    @LuaBridge
    public static String syncReadString(String path) {
        CAR result = readFileBytes(path);
        if (result.code != CODE_NO_ERROR) {
            return null;
        }
        return (String) result.result;
    }

    @LuaBridge
    public static int syncWriteFile(String path, String str) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        int result = makeFile(path);
        if (result != CODE_NO_ERROR) {
            return result;
        }
        return writeFileByte(new File(path), str);
    }

    @LuaBridge
    public static int syncWriteMap(String path, Map map) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        int result = makeFile(path);
        if (result != CODE_NO_ERROR) {
            return result;
        }
        return writeFileByte(new File(path), new JSONObject(map).toString());
    }

    @LuaBridge
    public static int syncWriteArray(String path, List array) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        int result = makeFile(path);
        if (result != CODE_NO_ERROR) {
            return result;
        }
        return writeFileByte(new File(path), new JSONArray(array).toString());
    }

    @LuaBridge
    public static int syncUnzipFile(String sourcePath, String targetPath) {
        if (RelativePathUtils.isLocalUrl(sourcePath)) {
            sourcePath = RelativePathUtils.getAbsoluteUrl(sourcePath);
        }
        if (RelativePathUtils.isLocalUrl(targetPath)) {
            targetPath = RelativePathUtils.getAbsoluteUrl(targetPath);
        }
        return unZipFile(sourcePath, targetPath);
    }

    @LuaBridge
    public static LuaValue syncMd5File(String path) {
        if (TextUtils.isEmpty(path)) {
            return LuaValue.Nil();
        }
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        File file = new File(path);
        if (file.exists() && file.isFile()) {
            byte[] datas = FileUtil.fastReadBytes(file);
            String md5 = EncryptUtil.md5Hex(datas);
            return LuaString.valueOf(md5);
        }

        return LuaValue.Nil();
    }


    //</editor-fold>

    private static final int CODE_NO_ERROR = 0;
    private static final int CODE_NOT_EXIST = -1;
    private static final int CODE_NOT_FILE = -2;
    private static final int CODE_READ_ERROR = -3;
    private static final int CODE_JSON_FAILED = -4;
    private static final int CODE_MKDIRS_FAILED = -5;
    private static final int CODE_WRITE_FAILED = -6;
    private static final int CODE_SOURCE_NOT_EXIST = -7;
    private static final int CODE_CREATE_FAILED = -8;
    private static final int CODE_DELETE_FAILED = -9;
    private static final int CODE_MOVE_FAILED = -10;
    private static final int CODE_COPY_FAILED = -11;
    private static final int CODE_GET_FILELIST_FAILED = -12;
    private static final int CODE_SAME_FILE = -14;

    private static final class JSONArrayTask extends BaseReadTask {

        JSONArrayTask(String path, LVCallback callback) {
            super(path, callback);
        }

        @Override
        protected Object parse(String result) {
            try {
                return JsonUtil.toList(new JSONArray(result));
            } catch (JSONException e) {
                callbackError(CODE_JSON_FAILED);
            }
            return null;
        }
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

    private static final class StringReadTask extends BaseReadTask {

        StringReadTask(String path, LVCallback callback) {
            super(path, callback);
        }

        @Override
        protected Object parse(String result) {
            return result;
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
            if (RelativePathUtils.isAssetUrl(path)) {
                path = RelativePathUtils.getAbsoluteAssetUrl(path);
            } else if (RelativePathUtils.isLocalUrl(path)) {
                path = RelativePathUtils.getAbsoluteUrl(path);
            }
            byte[] data;
            File target = new File(path);
            if (!target.exists()) {
                data = tryReadFromAssets();
                if (data == null) {
                    callbackError(CODE_NOT_EXIST);
                    return;
                } else {
                    callback(new String(data));
                    return;
                }
            }

            if (!target.isFile()) {
                callbackError(CODE_NOT_FILE);
                return;
            }
            data = FileUtil.fastReadBytes(target);
            if (data == null) {
                callbackError(CODE_READ_ERROR);
                return;
            }
            callback(new String(data));
        }

        private byte[] tryReadFromAssets() {
            InputStream is = null;
            try {
                is = MLSEngine.getContext().getAssets().open(path);
                return IOUtil.toBytes(is);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                IOUtil.closeQuietly(is);
            }
            return null;
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

    private static final class WriteArrayTask extends BaseWriteTask<List> {

        WriteArrayTask(String path, LVCallback callback, List data) {
            super(path, callback, data);
        }

        @Override
        public String toString(List data) {
            return new JSONArray(data).toString();
        }
    }

    private static final class WriteJsonTask extends BaseWriteTask<Map> {


        WriteJsonTask(String path, LVCallback callback, Map data) {
            super(path, callback, data);
        }

        @Override
        public String toString(Map data) {
            return new JSONObject(data).toString();
        }
    }

    private static final class WriteStringTask extends BaseWriteTask<String> {

        WriteStringTask(String path, LVCallback callback, String data) {
            super(path, callback, data);
        }

        @Override
        public String toString(String data) {
            return data;
        }
    }

    private abstract static class BaseWriteTask<T> extends BaseCallbackTask {
        String path;
        T data;

        BaseWriteTask(String path, LVCallback callback, T data) {
            super(callback);
            this.data = data;
            this.path = path;
        }

        @Override
        public void run() {
            if (RelativePathUtils.isAssetUrl(path)) {
                path = RelativePathUtils.getAbsoluteAssetUrl(path);
            } else if (RelativePathUtils.isLocalUrl(path)) {
                path = RelativePathUtils.getAbsoluteUrl(path);
            }
            File target = new File(path);
            if (!target.getParentFile().exists()) {
                if (!target.getParentFile().mkdirs()) {
                    callbackError(CODE_MKDIRS_FAILED);
                    return;
                }
            }
            if (target.isDirectory()) {
                callbackError(CODE_NOT_FILE);
                return;
            }
            String s = toString(data);
            if (s == null)
                return;
            if (FileUtil.fastSave(target, toBytes(s))) {
                callbackInMain(0, RelativePathUtils.getLocalUrl(path));
            } else {
                callbackError(CODE_WRITE_FAILED);
            }
        }

        protected byte[] toBytes(String s) {
            return s.getBytes();
        }

        public abstract String toString(T data);
    }

    private static class UnZipTask extends BaseCallbackTask {
        private String sourcePath;
        private String targetPath;
        private String returnPath;

        UnZipTask(String sourcePath, String targetPath, String returnPath, LVCallback callback) {
            super(callback);
            this.sourcePath = sourcePath;
            this.targetPath = targetPath;
            this.returnPath = returnPath;
        }

        @Override
        public void run() {
            int code = unZipFile(sourcePath, targetPath);
            callbackInMain(code, returnPath);
        }
    }

    //<editor-fold desc="Task-1.2.11">

    private static class FileMD5Task extends BaseCallbackTask {
        private String path;
        private Globals globals;

        FileMD5Task(Globals globals,String path, LVCallback callback) {
            super(callback);
            this.path = path;
            this.globals=globals;
        }

        @Override
        public void run() {
            if (TextUtils.isEmpty(path)) {
                callbackInMain(LuaValue.Nil());
                return;
            }
            if (RelativePathUtils.isLocalUrl(path)) {
                path = RelativePathUtils.getAbsoluteUrl(path);
            }
            File file = new File(path);
            if (file.exists() && file.isFile()) {
                byte[] datas = FileUtil.fastReadBytes(file);
                String md5 = EncryptUtil.md5Hex(datas);
                callbackInMain(md5);
                return;
            }
            callbackInMain(LuaValue.Nil());
        }
    }

    private static class CreateFileTask extends BaseCallbackTask {
        private String path;

        CreateFileTask(String path, LVCallback callback) {
            super(callback);
            this.path = path;
        }

        @Override
        public void run() {
            callbackError(makeFile(path));
        }
    }

    private static class CreateDirsTask extends BaseCallbackTask {
        private String path;

        CreateDirsTask(String path, LVCallback callback) {
            super(callback);
            this.path = path;
        }

        @Override
        public void run() {
            callbackError(makeDirs(path));
        }
    }

    private static class DeleteTask extends BaseCallbackTask {
        private String path;

        DeleteTask(String path, LVCallback callback) {
            super(callback);
            this.path = path;
        }

        @Override
        public void run() {
            if (TextUtils.isEmpty(path)) {
                callbackError(CODE_DELETE_FAILED);
                return;
            }
            if (RelativePathUtils.isLocalUrl(path)) {
                path = RelativePathUtils.getAbsoluteUrl(path);
            }
            if (path != null) {
                File file = new File(path);
                if (file.exists()) {
                    try {
                        FileUtil.delete(file);
                        callbackError(CODE_NO_ERROR);
                        return;
                    } catch (Throwable t) {
                    }
                }
            }
            callbackError(CODE_DELETE_FAILED);
        }
    }

    private static class MoveFileTask extends BaseCallbackTask {
        private String fromPath;
        private String toPath;

        MoveFileTask(String fromPath, String toPath, LVCallback callback) {
            super(callback);
            this.fromPath = fromPath;
            this.toPath = toPath;
        }

        @Override
        public void run() {
            if (moveFile(fromPath, toPath)) {
                callbackError(CODE_NO_ERROR);
            } else {
                callbackError(CODE_MOVE_FAILED);
            }
        }
    }

    private static class CopyFileTask extends BaseCallbackTask {
        private String oldPath;
        private String newPath;

        CopyFileTask(String fromPath, String toPath, LVCallback callback) {
            super(callback);
            this.oldPath = fromPath;
            this.newPath = toPath;
        }

        @Override
        public void run() {
            if (TextUtils.isEmpty(oldPath) || TextUtils.isEmpty(newPath)) {
                callbackError(CODE_COPY_FAILED);
                return;
            }
            if (RelativePathUtils.isLocalUrl(oldPath)) {
                oldPath = RelativePathUtils.getAbsoluteUrl(oldPath);
            }
            if (RelativePathUtils.isLocalUrl(newPath)) {
                newPath = RelativePathUtils.getAbsoluteUrl(newPath);
            }

            File oldFile = new File(oldPath);
            File newFile = new File(newPath);
            if (!oldFile.exists() || newFile.exists() || oldPath == null || newPath == null || oldPath.equals(newPath)) {
                callbackError(CODE_COPY_FAILED);
                return;
            }

            boolean result = false;
            if (oldFile.isDirectory()) {
                result = copyFolder(oldFile, newPath);
            } else if (oldFile.isFile()) {
                result = copyFile(oldFile, newPath);
            }
            if (result) {
                callbackError(CODE_NO_ERROR);
            } else {
                callbackError(CODE_COPY_FAILED);
            }
        }
    }

    private static class GetFileListTask extends BaseCallbackTask {
        private String path;
        private boolean recurisve;

        GetFileListTask(String path, boolean recurisve, LVCallback callback) {
            super(callback);
            this.path = path;
            this.recurisve = recurisve;
        }

        @Override
        public void run() {
            if (TextUtils.isEmpty(path)) {
                ErrorUtils.debugUnsupportError("path can`t be null");
                return;
            }
            if (RelativePathUtils.isLocalUrl(path)) {
                path = RelativePathUtils.getAbsoluteUrl(path);
            }
            List fileLists;
            fileLists = fileLists(path, new File(path), recurisve);
            if (fileLists != null) {
                callbackInMain(CODE_NO_ERROR, fileLists);
            } else {
                callbackError(CODE_GET_FILELIST_FAILED);
            }
        }
    }
    //</editor-fold>

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

    private static CAR readFileBytes(String path) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        int code = checkFile(path);
        if (code != CODE_NO_ERROR) {
            return new CAR(code);
        }
        byte[] data = FileUtil.readBytes(new File(path));
        if (data == null) {
            return new CAR(CODE_READ_ERROR);
        }
        return new CAR(CODE_NO_ERROR, new String(data));
    }

    private static int checkFile(String path) {
        File target = new File(path);
        if (!target.exists()) {
            return CODE_NOT_EXIST;
        }
        if (!target.isFile()) {
            return CODE_NOT_FILE;
        }
        return CODE_NO_ERROR;
    }

    private static int makeFile(String path) {
        return makeDirsOrFile(path, true);
    }

    private static int makeDirs(String path) {
        return makeDirsOrFile(path, false);
    }

    private static int makeDirsOrFile(String path, boolean isFile) {
        if (RelativePathUtils.isLocalUrl(path)) {
            path = RelativePathUtils.getAbsoluteUrl(path);
        }
        File target = new File(path);
        if (target.exists()) {
            if (isFile && !target.isFile()) {
                return CODE_NOT_FILE;
            }
            if (!isFile && !target.isDirectory()) {
                return CODE_MKDIRS_FAILED;
            }
            return CODE_NO_ERROR;
        }
        File parentFile = target.getParentFile();
        if (parentFile != null && !parentFile.exists()) {
            if (!parentFile.mkdirs()) {
                return CODE_MKDIRS_FAILED;
            }
        }
        if (isFile) {
            try {
                if (target.createNewFile())
                    return CODE_NO_ERROR;
                return CODE_CREATE_FAILED;
            } catch (Throwable t) {
                return CODE_CREATE_FAILED;
            }
        } else if (target.mkdir()) {
            return CODE_NO_ERROR;
        } else {
            return CODE_MKDIRS_FAILED;
        }
    }

    private static int writeFileByte(File file, String content) {
        if (!FileUtil.save(file, content.getBytes())) {
            return CODE_WRITE_FAILED;
        }
        return CODE_NO_ERROR;
    }

    private static int unZipFile(String sourcePath, String targetPath) {
        int code = checkFile(sourcePath);
        if (code != CODE_NO_ERROR) {
            return code;
        }
        code = makeDirs(targetPath);
        if (code != CODE_NO_ERROR) {
            return code;
        }
        try {
            FileUtil.unzip(targetPath, new FileInputStream(new File(sourcePath)));
        } catch (Exception e) {
            e.printStackTrace();
            return CODE_NOT_FILE;
        }
        return CODE_NO_ERROR;
    }

    private static final class CAR {
        int code;
        Object result;
        CAR(int c, Object result) {
            code = c;
            this.result = result;
        }
        CAR(int c) {
            code = c;
            result = null;
        }
    }

    private static boolean moveFile(String fromPath, String toPath) {
        if (TextUtils.isEmpty(fromPath) || TextUtils.isEmpty(toPath)) {
            return false;
        }
        if (RelativePathUtils.isLocalUrl(fromPath)) {
            fromPath = RelativePathUtils.getAbsoluteUrl(fromPath);
        }
        if (RelativePathUtils.isLocalUrl(toPath)) {
            toPath = RelativePathUtils.getAbsoluteUrl(toPath);
        }
        File fromFile = new File(fromPath);
        if (!fromFile.exists() || fromPath == null || toPath == null || fromPath.equals(toPath)) {
            return false;
        }

        if (fromFile.isFile()) {
            File toFile = new File(toPath);
            if (toFile.exists()) {
                return false;//源文件存在 or 源文件是file，目标文件是dir，return false
            }
            File parent = toFile.getParentFile();
            if (parent != null && !parent.exists()) {
                parent.mkdirs();
            }
            //移动文件
            return fromFile.renameTo(toFile);
        } else if (fromFile.isDirectory()) {
            File[] fromFiles = fromFile.listFiles();
            if (fromFiles == null) {
                return false;
            }
            File toFolder = new File(toPath);
            if (!toFolder.exists()) {
                toFolder.mkdirs();
            } else {
                return false;//源文件存在 or 源文件是dir，目标文件是file，return false
            }
            for (int i = 0; i < fromFiles.length; i++) {
                File file = fromFiles[i];
                if (file.isDirectory()) {
                    boolean result = moveFile(file.getPath(), toPath + File.separator + file.getName());
                    if (!result) {
                        return false;
                    }
                    file.delete();
                }
                if (file.isFile()) {
                    File toFile = new File(toFolder + File.separator + file.getName());
                    if (toFile.exists()) {
                        toFile.delete();
                    }
                    //移动文件
                    boolean result = file.renameTo(toFile);
                    if (!result) {
                        return false;
                    }
                }
            }
            return fromFile.delete();
        }
        return true;
    }

    private static boolean copyFile(File oldFile, String newPath) {
        if (!oldFile.exists()) {
            return false;
        }
        if (oldFile.isFile()) {
            return FileUtil.fastCopy(oldFile, new File(newPath));
        }
        return false;
    }

    // 复制某个目录及目录下的所有子目录和文件到新文件夹
    private static boolean copyFolder(File oldFile, String newPath) {

        if (oldFile == null || !oldFile.exists()) {
            return false;
        }
        // 如果文件夹不存在，则建立新文件夹
        File newFile = new File(newPath);
        if (!newFile.exists()) {
            newFile.mkdirs();
        } else if (newFile.isFile()) {
            return false;
        }
        // 读取整个文件夹的内容到file字符串数组，下面设置一个游标i，不停地向下移开始读这个数组
        String[] file = oldFile.list();
        // 要注意，这个temp仅仅是一个临时文件指针
        // 整个程序并没有创建临时文件
        File temp = null;
        for (String s : file) {
            temp = new File(oldFile.getAbsolutePath() + s);

            // 如果游标遇到文件
            if (temp.isFile()) {
                boolean result = FileUtil.fastCopy(temp, new File(newPath + File.separator + temp.getName()));
                if (!result) {
                    return false;
                }
            }
            // 如果游标遇到文件夹
            if (temp.isDirectory()) {
                boolean result = copyFolder(new File(oldFile.getAbsolutePath() + File.separator + s), newPath + File.separator + s);
                if (!result) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * 遍历指定目录下的子文件
     *
     * @param rootPath  指定的文件目录
     * @param dir       指定的文件目录
     * @param recurisve 是否递归
     * @return 子文件集合
     */
    private static List<String> fileLists(String rootPath, File dir, boolean recurisve) {
        if (dir == null || !dir.exists() || dir.isFile()) {
            return null;
        }

        if (!recurisve) {//不递归
            String[] lists = dir.list();
            return lists != null ? Arrays.asList(lists) : null;
        } else {
            List<String> totalLists = new ArrayList<>();
            File[] fileLists = dir.listFiles();
            for (File subFile :
                    fileLists) {
                if (subFile == null || !subFile.exists()) {
                    continue;
                }

                if (subFile.isFile()) {
                    totalLists.add(getRelativePath(rootPath, subFile.getAbsolutePath()));
                } else if (subFile.isDirectory()) {
                    totalLists.add(getRelativePath(rootPath, subFile.getAbsolutePath()));
                    List<String> subLists = fileLists(rootPath, subFile, recurisve);
                    if (subLists != null) {
                        totalLists.addAll(subLists);
                    }
                }
            }
            return totalLists;
        }
    }

    private static String getRelativePath(String rootPath, String absolutePath) {
        if (!rootPath.endsWith("/")) {
            rootPath = rootPath + "/";
        }
        return absolutePath.replace(rootPath, "");
    }
}