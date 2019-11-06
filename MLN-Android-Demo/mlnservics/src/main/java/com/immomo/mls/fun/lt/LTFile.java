package com.immomo.mls.fun.lt;

import android.text.TextUtils;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.FileInfo;
import com.immomo.mls.util.EncryptUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.JsonUtil;
import com.immomo.mls.util.LogUtil;
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
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
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

    private static final String KEY_CODE = "code";
    private static final String KEY_RESULT = "result";

    //<editor-fold desc="API-1.2.11">
    @Deprecated
    @LuaBridge
    public static String getStorageDir() {
        try {
            return FileUtil.getSdcardPath();
        } catch (Exception ignored) {
        }
        return "";
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
    public static void asyncMoveFile(String fromPath, String toPath, final LVCallback callback) {
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
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
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
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        return FileUtil.exists(path) ? true : false;
    }

    @LuaBridge
    public static boolean isDir(String path) {
        if (TextUtils.isEmpty(path))
            return false;
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        return new File(path).isDirectory();
    }

    @LuaBridge
    public static boolean isFile(String path) {
        if (TextUtils.isEmpty(path))
            return false;
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        return new File(path).isFile();
    }

    @LuaBridge
    public static void asyncReadFile(String path, final LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new StringReadTask(path, callback));
    }

    @LuaBridge
    public static void asyncReadMapFile(String path, LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONReadTask(path, callback));
    }

    @LuaBridge
    public static void asyncReadArrayFile(String path, LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new JSONArrayTask(path, callback));
    }

    @LuaBridge
    public static void asyncWriteFile(String path, String str, LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteStringTask(path, callback, str));
    }

    @LuaBridge
    public static void asyncWriteMap(String path, Map map, LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteJsonTask(path, callback, map));
    }

    @LuaBridge
    public static void asyncWriteArray(String path, List array, LVCallback callback) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new WriteArrayTask(path, callback, array));
    }

    @LuaBridge
    public static void asyncUnzipFile(String sourcePath, String targetPath, LVCallback callback) {
        String returnPath = sourcePath;
        if (FileUtil.isLocalUrl(sourcePath)) {
            sourcePath = FileUtil.getAbsoluteUrl(sourcePath);
        }
        if (FileUtil.isLocalUrl(targetPath)) {
            targetPath = FileUtil.getAbsoluteUrl(targetPath);
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH,
                new UnZipTask(sourcePath, targetPath, returnPath, callback));
    }

    @LuaBridge
    public static void asyncMd5File(Globals g, String path, final LVCallback callback) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new FileMD5Task(g, path, callback));
    }

    @LuaBridge
    public static String syncReadString(String path) {
        Map result = readFileBytes(path);
        if ((Integer) result.get(KEY_CODE) != CODE_NO_ERROR) {
            return null;
        }
        return (String) result.get(KEY_RESULT);
    }

    @LuaBridge
    public static int syncWriteFile(String path, String str) {
        Map result = makeFile(path);
        if (((Integer) result.get(KEY_CODE)) != CODE_NO_ERROR) {
            return (Integer) result.get(KEY_CODE);
        }
        return writeFileByte((File) result.get(KEY_RESULT), str);
    }

    @LuaBridge
    public static int syncWriteMap(String path, Map map) {
        Map result = makeFile(path);
        if ((Integer) result.get(KEY_CODE) != CODE_NO_ERROR) {
            return (Integer) result.get(KEY_CODE);
        }
        return writeFileByte((File) result.get(KEY_RESULT), new JSONObject(map).toString());
    }

    @LuaBridge
    public static int syncWriteArray(String path, List array) {
        Map result = makeFile(path);
        if ((Integer) result.get(KEY_CODE) != CODE_NO_ERROR) {
            return (Integer) result.get(KEY_CODE);
        }
        return writeFileByte((File) result.get(KEY_RESULT), new JSONArray(array).toString());
    }

    @LuaBridge
    public static int syncUnzipFile(String sourcePath, String targetPath) {
        if (FileUtil.isLocalUrl(sourcePath)) {
            sourcePath = FileUtil.getAbsoluteUrl(sourcePath);
        }
        if (FileUtil.isLocalUrl(targetPath)) {
            targetPath = FileUtil.getAbsoluteUrl(targetPath);
        }
        Map unZipResult = unZipFile(sourcePath, targetPath);
        return (int) unZipResult.get(KEY_CODE);
    }

    @LuaBridge
    public static LuaValue syncMd5File(String path) {
        if (TextUtils.isEmpty(path)) {
            return LuaValue.Nil();
        }
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        File file = new File(path);
        if (file.exists() && file.isFile()) {
            byte[] datas = FileUtil.fastReadBytes(file);
            String md5 = EncryptUtil.md5Hex(datas);
            return LuaString.valueOf(md5);
        }

        ErrorUtils.debugIllegalStateError("文件不存在 or 不是一个文件");
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
    private static final int CODE_CREATE_FAILED = -8;
    private static final int CODE_DELETE_FAILED = -9;
    private static final int CODE_MOVE_FAILED = -10;
    private static final int CODE_COPY_FAILED = -11;
    private static final int CODE_GET_FILELIST_FAILED = -12;
    private static final int CODE_GET_FILEINFO_FAILED = -13;

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
                callbackInMain(0, FileUtil.getLocalUrl(path));
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
            Map unZipResult = unZipFile(sourcePath, targetPath);
            callbackInMain(unZipResult.get(KEY_CODE), returnPath);
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
            if (FileUtil.isLocalUrl(path)) {
                path = FileUtil.getAbsoluteUrl(path);
            }
            File file = new File(path);
            if (file.exists() && file.isFile()) {
                byte[] datas = FileUtil.fastReadBytes(file);
                String md5 = EncryptUtil.md5Hex(datas);
                callbackInMain(md5);
                return;
            }
            ErrorUtils.debugLuaError("文件不存在 or 不是一个文件",globals);
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
            if (TextUtils.isEmpty(path)) {
                callbackError(CODE_CREATE_FAILED);
                return;
            }
            if (FileUtil.isLocalUrl(path)) {
                path = FileUtil.getAbsoluteUrl(path);
            }
            try {
                if (FileUtil.createFile(path, true)) {
                    callbackError(CODE_NO_ERROR);
                    return;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            callbackError(CODE_CREATE_FAILED);
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
            Map result = makeDirs(path);
            Integer code = ((Integer) result.get(KEY_CODE));
            if (code != CODE_NO_ERROR) {
                callbackError(code);
                return;
            }
            File file = (File) result.get(KEY_RESULT);
            if (file != null && !file.exists()) {
                if (file.mkdirs()) {
                    callbackError(CODE_NO_ERROR);
                    return;
                }
            }
            callbackError(CODE_MKDIRS_FAILED);
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
            if (FileUtil.isLocalUrl(path)) {
                path = FileUtil.getAbsoluteUrl(path);
            }
            if (path != null) {
                File file = new File(path);
                if (delete(file)) {
                    callbackError(CODE_NO_ERROR);
                    return;
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
            if (FileUtil.isLocalUrl(oldPath)) {
                oldPath = FileUtil.getAbsoluteUrl(oldPath);
            }
            if (FileUtil.isLocalUrl(newPath)) {
                newPath = FileUtil.getAbsoluteUrl(newPath);
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
            if (FileUtil.isLocalUrl(path)) {
                path = FileUtil.getAbsoluteUrl(path);
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

    @SuppressWarnings("unchecked")
    private static Map readFileBytes(String path) {
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        Map map = checkFile(path);
        if ((Integer) map.get(KEY_CODE) != CODE_NO_ERROR) {
            return map;
        }
        byte[] data = FileUtil.readBytes(new File(path));
        if (data == null) {
            map.put(KEY_CODE, CODE_READ_ERROR);
            return map;
        }
        map.put(KEY_RESULT, new String(data));
        return map;
    }

    private static Map checkFile(String path) {
        Map map = new HashMap(2);
        File target = new File(path);
        if (!target.exists()) {
            map.put(KEY_CODE, CODE_NOT_EXIST);
            return map;
        }
        if (!target.isFile()) {
            map.put(KEY_CODE, CODE_NOT_FILE);
            return map;
        }
        map.put(KEY_CODE, CODE_NO_ERROR);
        return map;
    }

    private static Map makeFile(String path) {
        return makeDirsOrFile(path, true);
    }

    private static Map makeDirs(String path) {
        return makeDirsOrFile(path, false);
    }

    @SuppressWarnings("unchecked")
    private static Map makeDirsOrFile(String path, boolean checkDirectory) {
        Map result = new HashMap(2);
        if (FileUtil.isLocalUrl(path)) {
            path = FileUtil.getAbsoluteUrl(path);
        }
        File target = new File(path);
        File parentFile = target.getParentFile();
        if (parentFile != null && !parentFile.exists()) {
            if (!parentFile.mkdirs()) {
                result.put(KEY_CODE, CODE_MKDIRS_FAILED);
                return result;
            }
        }
        if (checkDirectory && target.isDirectory()) {
            result.put(KEY_CODE, CODE_NOT_FILE);
            return result;
        }
        result.put(KEY_RESULT, target);
        result.put(KEY_CODE, CODE_NO_ERROR);
        return result;
    }

    private static int writeFileByte(File file, String content) {
        if (!FileUtil.save(file, content.getBytes())) {
            return CODE_WRITE_FAILED;
        }
        return CODE_NO_ERROR;
    }

    private static Map unZipFile(String sourcePath, String targetPath) {
        Map mapResult = checkFile(sourcePath);
        if ((Integer) mapResult.get(KEY_CODE) != CODE_NO_ERROR) {
            return mapResult;
        }
        mapResult = makeDirs(targetPath);
        if ((Integer) mapResult.get(KEY_CODE) != CODE_NO_ERROR) {
            return mapResult;
        }
        try {
            FileUtil.unzip(targetPath, new FileInputStream(new File(sourcePath)));
        } catch (Exception e) {
            e.printStackTrace();
            mapResult.put(KEY_CODE, CODE_NOT_FILE);
            return mapResult;
        }
        mapResult.put(KEY_CODE, CODE_NO_ERROR);
        return mapResult;
    }

    private static boolean delete(File file) {
        if (file != null && file.exists()) {
            if (file.isDirectory()) {
                File[] children = file.listFiles();
                if (children != null) {
                    for (File child : children) {
                        boolean resultIner = delete(child);
                        if (!resultIner) {
                            return false;
                        }
                    }
                }
                return file.delete();
            } else {
                return file.delete();
            }
        }
        return false;
    }

    private static boolean moveFile(String fromPath, String toPath) {
        if (TextUtils.isEmpty(fromPath) || TextUtils.isEmpty(toPath)) {
            return false;
        }
        if (FileUtil.isLocalUrl(fromPath)) {
            fromPath = FileUtil.getAbsoluteUrl(fromPath);
        }
        if (FileUtil.isLocalUrl(toPath)) {
            toPath = FileUtil.getAbsoluteUrl(toPath);
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
            try {
                FileInputStream input = new FileInputStream(oldFile);
                return FileUtil.copy(input, newPath);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                return false;
            }
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
        for (int i = 0; i < file.length; i++) {
            temp = new File(oldFile.getAbsolutePath() + file[i]);

            // 如果游标遇到文件
            if (temp.isFile()) {
                boolean result;
                try {
                    FileInputStream input = new FileInputStream(temp);
                    result = FileUtil.copy(input, String.format("%s%s%s", newPath, File.separator, temp.getName()));
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    result = false;
                }
                if (!result) {
                    return false;
                }
            }
            // 如果游标遇到文件夹
            if (temp.isDirectory()) {
                boolean result = copyFolder(new File(oldFile.getAbsolutePath() + File.separator + file[i]), newPath + File.separator + file[i]);
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
