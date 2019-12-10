/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

import java.util.Collection;
import java.util.Map;

import androidx.annotation.NonNull;

/**
 * Created by Xiong.Fangyu on 2019/4/19
 */
public class CompileUtils {

    public static void compile(@NonNull final ScriptBundle scriptBundle,
                               @NonNull final Globals globals) throws ScriptLoadException {
        Map<String, ScriptFile> children = scriptBundle.getChildren();
        final Collection<ScriptFile> scriptFiles = children != null ? children.values() : null;
        final int len = scriptFiles != null ? scriptFiles.size() + 1 : 1;

        compile(scriptBundle, scriptBundle.getMain(), globals);
        if (len == 1)
            return;
        for (ScriptFile sf : scriptFiles) {
            if (sf != null) {
                compile(scriptBundle, sf, globals);
            }
        }
    }

    /**
     * 编译ScriptFile
     *
     * @throws ScriptLoadException 未读取文件或编译出错时抛出异常
     */
    private static void compile(ScriptBundle scriptBundle, @NonNull ScriptFile scriptFile, @NonNull Globals globals) throws ScriptLoadException {
        checkGlobalsIsValid(globals);
        if (scriptFile.isCompiled())
            return;
        if (scriptFile.path == null && scriptFile.getSourceDataLength() == 0) {
            throw new ScriptLoadException(ERROR.COMPILE_FAILED, null);
        }
        if (scriptFile.isMain) {
            String chunkname = scriptFile.getChunkName();
            boolean compiled = scriptFile.pathType ?
                    (scriptFile.isAssetsPath() ? globals.loadAssetsFile(scriptFile.getAssetsPath(), chunkname) : globals.loadFile(scriptFile.path, chunkname))
                    : globals.loadData(chunkname, scriptFile.getSourceData());
            scriptFile.setCompiled(compiled);
            scriptFile.setSourceData(null);
            if (!compiled) {
                throw new ScriptLoadException(-5, "compile error" + globals.getErrorMsg(), null);
            }
            return;
        }
        try {
            globals.preloadData(scriptFile.getChunkName(), scriptFile.getSourceData());
            scriptFile.setSourceData(null);
            scriptFile.setCompiled(true);
        } catch (Throwable e) {
            throw new ScriptLoadException(ERROR.COMPILE_FAILED, e);
        }
    }

    private static void checkGlobalsIsValid(@NonNull Globals globals) throws ScriptLoadException {
        if (globals.isDestroyed()) {
            throw new ScriptLoadException(ERROR.GLOBALS_DESTROY, null);
        }
    }
}