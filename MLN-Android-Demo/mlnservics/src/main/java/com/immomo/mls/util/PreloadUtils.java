package com.immomo.mls.util;

import android.content.Context;

import com.immomo.mls.Constants;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by Xiong.Fangyu on 2019/4/19
 */
public class PreloadUtils {

    public static boolean checkDebug(final Globals g) {
        if (LuaViewConfig.isOpenDebugger()) {
            final String ip = LuaViewConfig.getDebugIp();
            final int port = LuaViewConfig.getPort();
            if (ip == null || ip.isEmpty())
                return false;
            LuaViewManager lv = (LuaViewManager) g.getJavaUserdata();
            Context c = lv != null ? lv.context : null;
            if (c == null)
                return false;
            final byte[] data = readDebug(c);
            if (data == null)
                return false;
            g.startDebug(data, ip, port);
            return true;
        }
        return false;
    }

    private static byte[] readDebugFromRoot() {
        File f = new File(FileUtil.getLuaDir(), "debug.lua");
        if (f.isFile()) {
            return FileUtil.readBytes(f);
        }
        return null;
    }

    private static byte[] readDebug(Context c) {
        byte[] data = readDebugFromRoot();
        if (data != null)
            return data;
        try {
            InputStream s = c.getAssets().open("debug.lua");
            byte[] d = IOUtil.toBytes(s, s.available());
            IOUtil.closeQuietly(s);
            return d;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static boolean preload(ScriptBundle bundle,
                                  ParsedUrl src,
                                  String[] preloadScripts,
                                  int minReadFileInThread,
                                  Object taskTag) {
        String[] preloads = src.getUrlParams().getPreload();
        int len = preloads != null ? preloads.length : 0;
        if (len == 0) {
            preloads = preloadScripts;
            len = preloads != null ? preloads.length : 0;
            if (len == 0) {
                return false;
            }
        }
        File file = new File(bundle.getBasePath());
        if (!file.isDirectory()) {
            return false;
        }
        final AtomicBoolean interrupted = new AtomicBoolean(false);
        // 多线程读取文件
        if (minReadFileInThread > 0 && len >= minReadFileInThread) {
            final MLSThreadAdapter adapter = MLSAdapterContainer.getThreadAdapter();
            final AtomicInteger finishedTask = new AtomicInteger(0);
            for (int i = 0; i < len; i++) {
                if (interrupted.get())
                    return true;
                String name = preloads[i];
                if (bundle.getChild(name) != null) {
                    finishedTask.incrementAndGet();
                    continue;
                }
                // 不支持二级目录
                File f = new File(file, name);
                String prefix = null;
                if (f.isFile()) {
                    prefix = name;
                }
                adapter.executeTaskByTag(taskTag, new ReadTask(file, bundle, finishedTask, prefix, len, interrupted));
            }
            while (finishedTask.get() < len) {
                synchronized (finishedTask) {
                    try {
                        finishedTask.wait();
                    } catch (Throwable e) {
                        interrupted.set(true);
                    }
                }
            }
            return true;
        }
        for (final String s : preloads) {
            if (bundle.getChild(s) != null)
                continue;
            File child = new File(file, s);
            if (child.isFile()) {
                ScriptFile sf = createByFile(s, child);
                if (sf != null) {
                    bundle.addChild(sf);
                }
            } else if (child.isDirectory()) {
                String path = s;
                int si = path.lastIndexOf(File.separatorChar);
                if (si < 0) {
                    path = "";
                } else {
                    path = path.substring(0, si + 1);
                }
                checkFileAndCreate(bundle, child, path, interrupted);
            }
        }
        return true;
    }

    public static void autoPreLoad(ScriptBundle scriptBundle, int minReadFileInThread, Object taskTag) {
        File file = new File(scriptBundle.getBasePath());
        if (!file.isDirectory()) {
            return;
        }
        // 不在多线程中处理
        if (minReadFileInThread < 0) {
            File[] children = file.listFiles(dirFilter);
            if (children == null)
                return;
            for (File f : children) {
                new ReadTask(f, scriptBundle, null, null, 0, null).run();
            }
            return;
        }
        final AtomicBoolean interrupted = new AtomicBoolean(false);
        final StringBuilder pathBuilder = new StringBuilder();
        int len;
        int loopCount = 0;
        File[] childrenDir;
        do {
            // 寻找子文件夹的个数，第一次只找文件夹，第二次开始找文件夹和.lua文件
            childrenDir = file.listFiles(getFilterForAutoPreLoad(loopCount++));
            len = childrenDir != null ? childrenDir.length : 0;
            // 空文件夹，直接返回
            if (len == 0)
                return;
            // 循环10次，若还是只有一个文件夹，直接返回
            if (loopCount == 10 && len == 1)
                return;
            if (loopCount == 2) {
                pathBuilder.append(file.getName());
            } else if (loopCount > 2) {
                pathBuilder.append(File.separator).append(file.getName());
            }
            file = childrenDir[0];
        } while (len <= 1);

        final AtomicInteger finishedTask = new AtomicInteger(0);
        MLSThreadAdapter adapter = MLSAdapterContainer.getThreadAdapter();
        for (int i = 0; i < len; i++) {
            if (interrupted.get())
                return;
            adapter.executeTaskByTag(taskTag,
                    new ReadTask(childrenDir[i], scriptBundle,
                            finishedTask, pathBuilder.length() == 0 ? null : pathBuilder.toString(), len, interrupted));
        }
        while (finishedTask.get() < len) {
            synchronized (finishedTask) {
                try {
                    finishedTask.wait();
                } catch (Throwable t) {
                    interrupted.set(true);
                }
            }
        }
    }

    /**
     * 读取文件任务
     */
    private static class ReadTask implements Runnable {
        private @NonNull
        final File file;
        private @NonNull
        final ScriptBundle bundle;
        private final String path;
        private final AtomicInteger finishedTask;
        private final int maxTask;
        private final AtomicBoolean interrupted;

        protected long cast;

        ReadTask(@NonNull File file,
                 @NonNull ScriptBundle bundle,
                 @Nullable AtomicInteger finishedTask,
                 @Nullable String prefixIfFile,
                 int maxTask,
                 AtomicBoolean interrupted) {
            this.file = file;
            this.bundle = bundle;
            this.finishedTask = finishedTask;
            this.maxTask = maxTask;
            this.interrupted = interrupted;
            if (file.isFile()) {
                path = prefixIfFile;
            } else {
                if (prefixIfFile != null) {
                    path = prefixIfFile + File.separator;
                } else {
                    path = "";
                }
            }
        }

        @Override
        public void run() {
            if (interrupted != null && interrupted.get())
                return;
            long now = System.currentTimeMillis();
            if (MLSEngine.DEBUG) {
                LogUtil.d("reading " + file);
            }
            checkFileAndCreate(bundle, file, path, interrupted);
            cast = System.currentTimeMillis() - now;
            if (finishedTask == null)
                return;
            int finished = finishedTask.incrementAndGet();
            if (MLSEngine.DEBUG) {
                LogUtil.d("read " + file + " finished, cast: " + cast + ", finished: " + finished + " max: " + maxTask);
            }
            if (finished >= maxTask) {
                synchronized (finishedTask) {
                    finishedTask.notify();
                }
            }
        }

        @Override
        public String toString() {
            return getClass().getName() + " read file " + path + " cast: " + cast;
        }
    }

    /**
     * 读取子文件并放入scriptBundle中
     *
     * @param scriptBundle
     * @param file         子文件，或文件夹
     * @param path         文件前缀
     */
    private static void checkFileAndCreate(ScriptBundle scriptBundle, File file, String path, AtomicBoolean interrupted) {
        if (interrupted != null && interrupted.get())
            return;
        if (file.isFile()) {
            ScriptFile sf = createByFile(path + file.getName(), file);
            if (sf != null) {
                scriptBundle.addUseByte((int) file.length());
                scriptBundle.addChild(sf);
            }
            return;
        }
        if (file.isDirectory()) {
            File[] children = file.listFiles(fileFilter);
            path += file.getName() + File.separator;
            for (File f : children) {
                checkFileAndCreate(scriptBundle, f, path, interrupted);
                if (!scriptBundle.checkUseByte())
                    return;
            }
        }
    }

    /**
     * 根据文件创建ScriptFile
     *
     * @see #checkFileAndCreate
     */
    private static ScriptFile createByFile(String name, File file) {
        if (!checkFile(file))
            return null;
        if (name.endsWith(Constants.POSTFIX_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_LUA.length());
        } else if (name.endsWith(Constants.POSTFIX_B_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_B_LUA.length());
        }
        name = name.replaceAll("/", ".");
        return createScriptFile(name, file, false);
    }

    /**
     * 生成{@link ScriptFile}
     *
     * @param file      本地文件
     * @throws ScriptLoadException 读文件出错时，抛出异常
     */
    public static ScriptFile parseMainScript(File file) throws ScriptLoadException {
        if (!checkFile(file))
            throw new ScriptLoadException(ERROR.READ_FILE_FAILED, null);
        String name = file.getName();
        if (name.endsWith(Constants.POSTFIX_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_LUA.length());
        } else if (name.endsWith(Constants.POSTFIX_B_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_B_LUA.length());
        }
        ScriptFile sf = createScriptFile(name, file, true);
        if (sf == null)
            throw new ScriptLoadException(ERROR.READ_FILE_FAILED, null);
        return sf;
    }

    private static ScriptFile createScriptFile(String cn, File f, boolean isMain) {
        if (MLSConfigs.readScriptFileInJava) {
            byte[] data = FileUtil.fastReadBytes(f);
            if (data == null)
                return null;
            return new ScriptFile(cn, data, isMain);
        }
        return new ScriptFile(cn, f.getAbsolutePath(), isMain);
    }

    private static boolean checkFile(File f) {
        return f.isFile();
    }

    /**
     * 自动预读的文件筛选
     *
     * @see #autoPreLoad
     */
    private static FileFilter getFilterForAutoPreLoad(int loopCount) {
        return loopCount == 0 ? dirFilter : fileFilter;
    }

    private static final FileFilter fileFilter = new FileFilter() {
        @Override
        public boolean accept(File pathname) {
            return pathname.isDirectory() || (pathname.isFile() && pathname.getName().endsWith(".lua") && !pathname.getName().startsWith("."));
        }
    };

    private static final FileFilter dirFilter = new FileFilter() {
        @Override
        public boolean accept(File pathname) {
            return pathname.isDirectory();
        }
    };
}
