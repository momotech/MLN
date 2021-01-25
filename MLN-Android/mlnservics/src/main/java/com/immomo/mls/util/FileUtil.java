/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.immomo.mls.global.LuaViewConfig;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * 文件操作类
 *
 * @author song
 * @date 15/11/9
 */
public class FileUtil {
    private static final String DIR_MODIFY_FILE = ".lastModify__time";
    private static final int BUFFER = 8 << 10;
    /**
     * 默认支持使用内存映射的方式读取或写文件
     */
    private static boolean useMemoryMap = true;
    public static boolean DEBUG = false;

    public static final void setUseMemoryMap(boolean use) {
        useMemoryMap = use;
    }
    /**
     * zip压缩包不合法文件名
     */
    private static final String[] INVALID_ZIP_ENTRY_NAME = new String[]{
            "../",
            "~/"
    };
    public static boolean validEntry(@NonNull String name) {
        for (int i = 0, l = INVALID_ZIP_ENTRY_NAME.length; i < l; i++) {
            if (name.contains(INVALID_ZIP_ENTRY_NAME[i]))
                return false;
        }
        return true;
    }

    /**
     * 处理相对parent的绝对路径
     * 若src中不含../，则返回parent+src
     * 若含有，则结合后再返回
     * @param parent 父路径
     * @param src    相对路径
     */
    public static String dealRelativePath(String parent, String src) {
        final String R = ".." + File.separator;
        int pl = parent.length();
        final int sl = src.length();
        if (pl > 0 && parent.charAt(pl - 1) == File.separatorChar) {
            parent = parent.substring(0, pl - 1);
            pl --;
        }
        /// 若src以 '/'开头，去掉'/'
        if (src.charAt(0) == File.separatorChar) {
            src = src.substring(1);
        }
        /// 若src以 './'开头，去掉
        else if (src.charAt(0) == '.' && sl > 1 && src.charAt(1) == File.separatorChar) {
            src = src.substring(2);
        }
        if (pl == 0) {
            return src;
        }
        String ret = parent + File.separator + src;
        int index = ret.indexOf(R, 1);
        while (index >= 2) {
            int l = ret.lastIndexOf(File.separatorChar, index - 2);
            if (l < 0) {
                ret = ret.substring(index + 3);
                break;
            }
            ret = ret.substring(0, l) + ret.substring(index + 2);
            index = ret.indexOf(R, l);
        }
        return ret;
    }

    /**
     * 解压文件
     * @param path
     * @param is
     * @throws Exception
     */
    public static void unzip(@NonNull String path, InputStream is) throws Exception{
        unzipWithoutModifyTime(path, is);
        generateModifyTimeForAllDir(new File(path));
    }

    /**
     * 解压文件
     * @param path
     * @param is
     * @throws Exception
     */
    public static void unzipWithoutModifyTime(@NonNull String path, InputStream is) throws Exception {
        ZipInputStream zipStream = null;
        try {
            zipStream = new ZipInputStream(new BufferedInputStream(is));
            ZipEntry entry;
            while ((entry = zipStream.getNextEntry()) != null) {
                final String name = entry.getName();
                if (!validEntry(name))
                    throw new IllegalArgumentException("unsecurity zipfile!");
                File entryFile = new File(path, name);

                if (entry.isDirectory()) {
                    if (!entryFile.exists()) {
                        entryFile.mkdirs();
                    }
                    continue;
                }
                File entryDir = new File(entryFile.getParent());
                if (!entryDir.exists()) {
                    entryDir.mkdirs();
                }
                //创建 .nomedia 文件，防止解压后的资源在系统相册中被看到
                File nomeidiaFile = new File(entryDir, ".nomedia");
                if (!nomeidiaFile.exists()) {
                    nomeidiaFile.createNewFile();
                }
                writeFile(entryFile, zipStream);
                zipStream.closeEntry();
            }
        } finally {
            IOUtil.closeQuietly(zipStream);
        }
    }

    public static void generateModifyTimeForAllDir(File dir) {
        generateModifyTimeForSingleDir(dir);
        File[] files = dir.listFiles(new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                return pathname.isDirectory() && !DIR_MODIFY_FILE.equals(pathname.getName());
            }
        });
        if (files == null || files.length == 0)
            return;
        for (File f : files) {
            generateModifyTimeForAllDir(f);
        }
    }

    public static void generateModifyTimeForSingleDir(File dir) {
        if (DIR_MODIFY_FILE.equals(dir.getName()))
            return;
        long now = System.currentTimeMillis();
        File mf = new File(dir, DIR_MODIFY_FILE);
        if (!mf.exists()) {
            mf.mkdir();
        }
        dir.setLastModified(now);
        mf.setLastModified(now);
    }

    public static boolean checkAllDirModifyTime(File dir) {
        if (!checkSingleDirModifyTime(dir))
            return false;
        File[] files = dir.listFiles(new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                return pathname.isDirectory() && !DIR_MODIFY_FILE.equals(pathname.getName());
            }
        });
        if (files == null || files.length == 0)
            return true;
        for (File f : files) {
            if (!checkAllDirModifyTime(f))
                return false;
        }
        return true;
    }

    public static boolean checkSingleDirModifyTime(File dir) {
        if (DIR_MODIFY_FILE.equals(dir.getName()))
            return true;
        File f = new File(dir, DIR_MODIFY_FILE);
        if (!f.exists())
            return false;
        return dir.lastModified() == f.lastModified();
    }

    /**
     * 写文件
     * @param file
     * @param is
     * @throws Exception
     */
    public static void writeFile(@NonNull File file, InputStream is) throws Exception{
        byte data[] = new byte[BUFFER];
        BufferedOutputStream dest = new BufferedOutputStream(new FileOutputStream(file), BUFFER);
        int count = 0;
        while ((count = is.read(data, 0, BUFFER)) != -1) {
            dest.write(data, 0, count);
        }
        dest.flush();
        dest.close();
    }

    /**
     * 是否是相对路径
     * @see RelativePathUtils#isLocalUrl
     */
    @Deprecated
    public static boolean isLocalUrl(String url) {
        return RelativePathUtils.isLocalUrl(url);
    }

    /**
     * 将相对路径转换成绝对路径
     *
     * @see RelativePathUtils#getAbsoluteUrl(String)
     */
    @Deprecated
    public static String getAbsoluteUrl(String url) {
        return RelativePathUtils.getAbsoluteUrl(url);
    }

    /**
     * 将绝对路径转换为相对路径
     * @see RelativePathUtils#getLocalUrl
     */
    @Deprecated
    public static String getLocalUrl(String absoluteUrl) {
        return RelativePathUtils.getLocalUrl(absoluteUrl);
    }

    public static String getUrlPath(String url) {
        Uri uri = Uri.parse(url);
        String host = uri.getHost();
        String path = uri.getPath();
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        return host != null ? host + path : path;
    }

    public static String getUrlName(String url) {
        Uri uri = Uri.parse(url);
        String path = uri.getPath();
        int index = path.lastIndexOf('/');
        if (index >= 0) {
            return path.substring(index + 1);
        }
        return path;
    }

    public static File getSdcardDir() {
        return LuaViewConfig.getLvConfig().getSdcardDir();
    }

    public static File getRootDir() {
        return LuaViewConfig.getLvConfig().getRootDir();
    }

    public static File getCacheDir() {
        return LuaViewConfig.getLvConfig().getCacheDir();
    }

    public static File getImageDir() {
        return LuaViewConfig.getLvConfig().getImageDir();
    }

    public static File getLuaDir() {
        return new File(getRootDir(), "LuaView");
    }

    /**
     * is a file path contains folder path
     *
     * @param filePath
     * @param folderPath
     * @return
     */
    public static boolean isContainsFolderPath(final String filePath, final String folderPath) {//TODO ../../目录处理
        if (filePath != null && folderPath != null) {//filePath本身是folder，并且包含folderPath
            if (folderPath.charAt(folderPath.length() - 1) == '/') {//本身是路径
                return filePath.startsWith(folderPath);
            } else {//非路径的话需要判断路径
                return filePath.startsWith(folderPath + "/");
            }
        }
        return false;
    }

    /**
     * 判断文件路径是否是Folder
     *
     * @param filePath
     * @return
     */
    public boolean isFolder(String filePath) {
        if (!TextUtils.isEmpty(filePath)) {
            final File file = new File(filePath);
            return file.exists() && file.isDirectory();
        }
        return false;
    }

    /**
     * 判断文件路径是否是简单的文件
     *
     * @param filePath
     * @return
     */
    public boolean isFile(String filePath) {
        if (!TextUtils.isEmpty(filePath)) {
            final File file = new File(filePath);
            return file.exists() && file.isFile();
        }
        return false;
    }

    /**
     * build a file path
     *
     * @param basePath
     * @param nameOrPath
     * @return
     */
    public static String buildPath(final String basePath, final String nameOrPath) {
        if (!TextUtils.isEmpty(basePath)) {
            return new StringBuffer().append(basePath).append(basePath.endsWith(File.separator) ? "" : File.separator).append(nameOrPath).toString();
        } else {
            return nameOrPath;
        }
    }

    /**
     * 是否给定的名称是以postfix结尾的名字
     *
     * @param fileName
     * @param posfix
     * @return
     */
    public static boolean isSuffix(final String fileName, final String posfix) {
        return !TextUtils.isEmpty(fileName) && posfix != null && fileName.endsWith(posfix);
    }

    /**
     * 是否有后缀
     *
     * @param fileName
     * @return
     */
    public static boolean hasPostfix(final String fileName) {
        return fileName != null && fileName.lastIndexOf('.') != -1;
    }

    /**
     * 去除文件名称的前缀
     *
     * @param fileName
     * @param prefix
     * @return
     */
    public static String removePrefix(final String fileName, final String prefix) {
        if (prefix != null && fileName != null && fileName.startsWith(prefix)) {
            return fileName.substring(prefix.length());
        }
        return fileName;
    }

    /**
     * 去掉后缀
     *
     * @param fileName
     * @return
     */
    public static String removePostfix(final String fileName) {
        if (fileName != null && fileName.lastIndexOf('.') != -1) {
            return fileName.substring(0, fileName.lastIndexOf('.'));
        }
        return fileName;
    }

    /**
     * 得到文件夹路径
     *
     * @param filePath
     * @return
     */
    public static String getFolderPath(final String filePath) {
        File file = new File(filePath);
        if (file.exists()) {
            if (file.isFile()) {
                return file.getParent();
            } else {
                return file.getPath();
            }
        } else if (filePath.lastIndexOf(File.separatorChar) != -1) {
            return filePath.substring(0, filePath.lastIndexOf(File.separatorChar));
        }
        return "";
    }

    /**
     * 得到Asset的目录路径
     *
     * @param assetFilePath
     * @return
     */
    public static String getAssetFolderPath(final String assetFilePath) {
        if (assetFilePath != null && assetFilePath.lastIndexOf(File.separatorChar) != -1) {
            return assetFilePath.substring(0, assetFilePath.lastIndexOf(File.separatorChar));
        }
        return "";
    }

    /**
     * get file name of given path
     *
     * @param nameOrPath
     * @return
     */
    public static String getFileName(final String nameOrPath) {
        if (nameOrPath != null) {
            int index = nameOrPath.lastIndexOf('/');
            if (index != -1) {
                return nameOrPath.substring(index + 1);
            }
        }
        return nameOrPath;
    }


    /**
     * get filepath
     *
     * @param filepath
     * @return
     */
    public static String getCanonicalPath(String filepath) {
        if (filepath != null) {
            if (filepath.contains("../")) {
                try {
                    return new File(filepath).getCanonicalPath();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } else {
                return filepath;
            }
        }
        return null;
    }

    /**
     * 不包含父路径，有父路径的话则去掉父路径
     *
     * @param nameOrPath
     * @return
     */
    public static String getSecurityFileName(final String nameOrPath) {
        if (nameOrPath != null) {
            boolean isNotSecurity = nameOrPath.contains("../");
            if (isNotSecurity) {
                int index = nameOrPath.lastIndexOf("../");
                if (index != -1) {
                    return nameOrPath.substring(index + 4);
                }
            }
        }
        return nameOrPath;
    }

    /**
     * crate file with given path and file name
     *
     * @param fullpath
     * @param fullpath
     * @return
     */
    public static File createFile(final String fullpath) {
        File file = new File(fullpath);
        if (file.exists()) {
            return file;
        } else {
            File parent = file.getParentFile();
            if (!parent.exists()) {
                parent.mkdirs();
            }
            String fileName = file.getName();
            return new File(parent, fileName);
        }
    }

    /**
     * crate file with given path and file name
     *
     * @param path
     * @param fileName
     * @return
     */
    public static File createFile(final String path, final String fileName) {
        File directory = new File(path);
        directory.mkdirs();
        return new File(directory, fileName);
    }

    public static boolean clearFile(File f) {
        if (f.exists()) {
            if (!f.delete()) return false;
        }
        try {
            return f.createNewFile();
        } catch (IOException e) {
            logError(e);
            return false;
        }
    }

    /**
     * read bytes of given f
     *
     * @param f
     * @return
     */
    public static byte[] readBytes(File f) {
        if (f != null && f.exists() && f.isFile()) {
            InputStream inputStream = null;
            try {
                inputStream = new FileInputStream(f);
                return IOUtil.toBytes(inputStream);
            } catch (FileNotFoundException e) {
                logError(e);
            } finally {
                IOUtil.closeQuietly(inputStream);
            }
        }
        return null;
    }

    /**
     * read bytes of given f
     *
     * @param f
     * @return
     */
    public static byte[] fastReadBytes(File f) {
        if (!useMemoryMap) {
            return readBytes(f);
        }
        if (f != null && f.exists() && f.isFile()) {
            FileInputStream inputStream = null;
            try {
                inputStream = new FileInputStream(f);

                MappedByteBuffer buffer = inputStream.getChannel().map(FileChannel.MapMode.READ_ONLY, 0, f.length());
                byte[] result = new byte[(int) f.length()];
                buffer.get(result);
                return result;
            } catch (Exception e) {
                logError(e);
            } finally {
                IOUtil.closeQuietly(inputStream);
            }
        }
        return null;
    }

    /**
     * 将文件读取到direct buffer中
     * @return 读取失败，返回null
     */
    public static ByteBuffer readByteBuffer(File f) {
        if (f != null && f.exists() && f.isFile()) {
            long fl = f.length();
            if (fl > Integer.MAX_VALUE)
                return null;
            RandomAccessFile raf = null;
            FileChannel channel = null;
            try {
                raf = new RandomAccessFile(f, "r");
                channel = raf.getChannel();
                ByteBuffer byteBuffer = ByteBuffer.allocateDirect((int) fl);
                channel.read(byteBuffer);
                return byteBuffer;
            } catch (IOException e) {
                logError(e);
            } finally {
                IOUtil.closeQuietly(channel);
                IOUtil.closeQuietly(raf);
            }
        }
        return null;
    }

    public static boolean fastSave(File file, byte[] data) {
        if (!useMemoryMap) {
            return save(file, data);
        }
        if (data != null && data.length > 0) {
            FileChannel out = null;
            try {
                out = new RandomAccessFile(file, "rw").getChannel();
                MappedByteBuffer map = out.map(FileChannel.MapMode.READ_WRITE, 0, data.length);
                map.put(data);
                map.force();
                return true;
            } catch (IOException e) {
                logError(e);
                return false;
            } finally {
                IOUtil.closeQuietly(out);
            }
        }
        return false;
    }

    public static boolean fastCopy(File from, File to) {
        FileInputStream inputStream = null;
        FileChannel inChannel = null;
        FileOutputStream outputStream = null;
        FileChannel outChannel = null;
        try {
            inputStream = new FileInputStream(from);
            inChannel = inputStream.getChannel();
            outputStream = new FileOutputStream(to);
            outChannel = outputStream.getChannel();
            outChannel.transferFrom(inChannel, 0, from.length());
        } catch (IOException e) {
            logError(e);
            return false;
        } finally {
            IOUtil.closeQuietly(inputStream);
            IOUtil.closeQuietly(inChannel);
            IOUtil.closeQuietly(outputStream);
            IOUtil.closeQuietly(outChannel);
        }
        return true;
    }

    /**
     * save data to a file
     *
     * @param path file path with file name
     * @param data data to saved
     */
    public static boolean fastSave(final String path, final byte[] data) {
        if (!useMemoryMap) {
            return save(path, data);
        }
        if (!TextUtils.isEmpty(path)) {
            File destFile = createFile(path);
            return fastSave(destFile, data);
        }
        return false;
    }

    public static boolean save(File file, InputStream is) {
        if (is == null) return false;
        return fastSave(file, IOUtil.toBytes(is));
    }

    public static boolean save(File file, byte[] data) {
        if (data != null && data.length > 0) {
            FileOutputStream out = null;
            try {
                out = new FileOutputStream(file);
                out.write(data);
                out.flush();
                return true;
            } catch (IOException e) {
                logError(e);
                return false;
            } finally {
                IOUtil.closeQuietly(out);
            }
        }
        return false;
    }

    /**
     * save data to a file
     *
     * @param path file path with file name
     * @param data data to saved
     */
    public static boolean save(final String path, final byte[] data) {
        if (!TextUtils.isEmpty(path)) {
            File destFile = createFile(path);
            return save(destFile, data);
        }
        return false;
    }

    /**
     * open a file
     *
     * @param filePath
     * @return
     */
    public static InputStream open(final String filePath) {
        if (TextUtils.isEmpty(filePath))
            return null;
        try {
            File f = new File(filePath);
            if (!f.exists() || !f.isFile())
                return null;
            return new FileInputStream(f);
        } catch (Exception e) {
            logError(e);
            return null;
        }
    }

    /**
     * is file exists
     *
     * @param filePath
     * @return
     */
    public static boolean exists(final String filePath) {
        if (!TextUtils.isEmpty(filePath)) {
            return new File(filePath).exists();
        }
        return false;
    }

    public static boolean exists(Context context, String assets) {
        try {
            InputStream is = context.getAssets().open(assets);
            IOUtil.closeQuietly(is);
            return true;
        } catch (IOException e) {
            logError(e);
            return false;
        }
    }

    public static InputStream open(Context context, String assets) {
        try {
            return context.getAssets().open(assets);
        } catch (IOException e) {
            logError(e);
        }
        return null;
    }

    /**
     * copy a input stream to given filepath
     *
     * @param input
     * @param filePath
     * @return
     */
    public static boolean copy(final InputStream input, final String filePath) {
        final int bufSize = BUFFER;
        boolean result = false;
        File file = FileUtil.createFile(filePath);
        OutputStream output = null;
        try {
            output = new BufferedOutputStream(new FileOutputStream(file), bufSize);
            byte[] buffer = new byte[bufSize];
            int read;
            while ((read = input.read(buffer)) != -1) {
                output.write(buffer, 0, read);
            }
            output.flush();
            result = true;
        } catch (Exception e) {
            logError(e);
            result = false;
        } finally {
            IOUtil.closeQuietly(input);
            IOUtil.closeQuietly(output);
        }
        return result;
    }

    public static interface ProgressCallback {
        void onProgress(float p);
    }

    public static void copy(final InputStream input, final String filePath, final long total, ProgressCallback callback) throws Exception{
        final int bufSize = BUFFER;
        File file = FileUtil.createFile(filePath);
        OutputStream output = null;
        try {
            output = new BufferedOutputStream(new FileOutputStream(file), bufSize);
            byte[] buffer = new byte[bufSize];
            int read;
            long readed = 0;
            while ((read = input.read(buffer)) != -1) {
                output.write(buffer, 0, read);
                readed += read;
                if (callback != null) {
                    callback.onProgress((float) (readed / (double)total));
                }
            }
            output.flush();
        } finally {
            IOUtil.closeQuietly(output);
        }
    }

    /**
     * delete all files
     *
     * @param filePath
     */
    public static boolean delete(final String filePath) throws IOException {
        if (filePath != null) {
            File file = new File(filePath);
            return delete(file);
        }
        return false;
    }

    /**
     * delete a file
     *
     * @param file
     */
    public static boolean delete(File file) throws IOException {
        if (file != null && file.exists()) {
            if (file.isDirectory()) {
                File[] children = file.listFiles();
                if (children != null) {
                    for (File child : children) {
                        if (!delete(child))
                            return false;
                    }
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Files.deleteIfExists(file.toPath());
                } else {
                    return !file.delete();
                }
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Files.deleteIfExists(file.toPath());
                } else {
                    return !file.delete();
                }
            }
            return true;
        }
        return false;
    }

    /**
     * create file
     *
     * @param filepath  Absolute file path
     * @param recursion whether create parent directory neccesary or not
     * @return
     * @throws IOException
     */
    public static boolean createFile(String filepath, boolean recursion) throws IOException {
        boolean result = false;
        File f = new File(filepath);
        if (!f.exists()) {
            try {
                result = f.createNewFile();
            } catch (IOException e) {
                if (!recursion) {
                    throw e;
                }
                File parent = f.getParentFile();
                if (parent != null && !parent.exists()) {
                    parent.mkdirs();
                }
                try {
                    result = f.createNewFile();
                } catch (IOException e1) {
                    throw e1;
                }
            }
        }
        return result;
    }

    private static void logError(Throwable e) {
        if (DEBUG)
            LogUtil.e(e);
    }
}