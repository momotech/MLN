/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;
import org.luaj.vm2.exception.UndumpError;
import org.luaj.vm2.utils.StringReplaceUtils;

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
            return g.startDebug(data, ip, port);
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

    /**
     * 预加载
     */
    public static boolean preload(@NonNull ScriptBundle bundle,
                                  @NonNull ParsedUrl src,
                                  @Nullable String[] preloadScripts,
                                  @NonNull Globals g,
                                  @Nullable StringBuilder errorSB) {
        String[] preloads = src.getUrlParams().getPreload();
        if (preloads == null || preloads.length == 0) {
            preloads = preloadScripts;
        }
        int len = preloads != null ? preloads.length : 0;
        if (len == 0)
            return false;
        File file = new File(bundle.getBasePath());
        if (!file.isDirectory()) {
            if (errorSB != null)
                errorSB.append("base path \"").append(file).append("\" is not a directory!");
            return false;
        }
        boolean result = true;
        String error = null;
        for (final String s : preloads) {
            if (bundle.getChild(s) != null)
                continue;
            File child = new File(file, s);
            ScriptFile sf = createByFile(s, child);
            if (sf != null) {
                try {
                    g.preloadFile(s, child.getAbsolutePath());
                    sf.setCompiled(true);
                } catch (UndumpError e) {
                    sf.setCompiled(false);
                    error = e.getMessage();
                }
                bundle.addChild(sf);
                result = sf.isCompiled();
            } else {
                result = false;
            }
            if (!result) {
                if (errorSB != null)
                    errorSB.append(error);
                break;
            }
        }
        return result;
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
        if (!file.isFile())
            return null;
        if (name.endsWith(Constants.POSTFIX_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_LUA.length());
        } else if (name.endsWith(Constants.POSTFIX_B_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_B_LUA.length());
        }
        name = StringReplaceUtils.replaceAllChar(name, File.separatorChar, '.');
        return createScriptFile(name, file, false);
    }

    /**
     * 生成{@link ScriptFile}
     *
     * @param file      本地文件
     * @throws ScriptLoadException 读文件出错时，抛出异常
     */
    public static ScriptFile parseMainScript(File file) throws ScriptLoadException {
        if (!file.isFile())
            throw new ScriptLoadException(ERROR.READ_FILE_FAILED, null);
        String name = file.getName();
        if (name.endsWith(Constants.POSTFIX_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_LUA.length());
        } else if (name.endsWith(Constants.POSTFIX_B_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_B_LUA.length());
        }
        return createScriptFile(name, file, true);
    }

    public static ScriptFile parseAssetMainScript(ParsedUrl parsedUrl) {
        String name = parsedUrl.getName();
        if (name.endsWith(Constants.POSTFIX_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_LUA.length());
        } else if (name.endsWith(Constants.POSTFIX_B_LUA)) {
            name = name.substring(0, name.length() - Constants.POSTFIX_B_LUA.length());
        }
        return new ScriptFile(name, parsedUrl.getUrlWithoutParams(), true, true);
    }

    private static ScriptFile createScriptFile(String cn, File f, boolean isMain) {
        return new ScriptFile(cn, f.getAbsolutePath(), isMain);
    }

    /**
     * 自动预读的文件筛选
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