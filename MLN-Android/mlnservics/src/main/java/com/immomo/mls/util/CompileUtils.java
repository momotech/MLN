/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019/4/19
 */
public class CompileUtils {

    public static void compile(@NonNull final ScriptBundle scriptBundle,
                               @NonNull final Globals globals) throws ScriptLoadException {
        compile(scriptBundle.getMain(), globals);
    }

    /**
     * 编译ScriptFile
     *
     * @throws ScriptLoadException 未读取文件或编译出错时抛出异常
     */
    private static void compile(@NonNull ScriptFile scriptFile, @NonNull Globals globals) throws ScriptLoadException {
        checkGlobalsIsValid(globals);
        if (scriptFile.isCompiled())
            return;
        if (scriptFile.path == null && scriptFile.getSourceDataLength() == 0) {
            throw new ScriptLoadException(ERROR.COMPILE_FAILED, null);
        }
        String chunkname = scriptFile.getChunkName();
        if (scriptFile.pathType) {
            if (scriptFile.isAssetsPath()) {
                    scriptFile.setCompiled(globals.loadAssetsFile(scriptFile.getAssetsPath(), chunkname));
            } else if (globals.loadFile(scriptFile.path, chunkname)) {
                scriptFile.setCompiled(true);
            } else if ((Globals.getNativeFileConfigs() & Globals.LUA_FILE_CINFIG_SOURCE_FILE) != Globals.LUA_FILE_CINFIG_SOURCE_FILE){
                //尝试在java层读取代码
                LuaViewManager vm = (LuaViewManager) globals.getJavaUserdata();
                scriptFile.toSourceDataType(vm != null ? vm.context : null);
            } else {
                scriptFile.setCompiled(false);
            }
        }
        if (!scriptFile.isCompiled()) {
            final byte[] data = scriptFile.getSourceData();
            if (data != null) {
                scriptFile.setCompiled(globals.loadData(chunkname, data));
            }
        }
        scriptFile.setSourceData(null);

        if (!scriptFile.isCompiled()) {
            throw new ScriptLoadException(ERROR.COMPILE_FAILED, globals.getError());
        }
    }

    private static void checkGlobalsIsValid(@NonNull Globals globals) throws ScriptLoadException {
        if (globals.isDestroyed()) {
            throw new ScriptLoadException(ERROR.GLOBALS_DESTROY, null);
        }
    }
}