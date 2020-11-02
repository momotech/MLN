/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.wraps;

import android.annotation.SuppressLint;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.ScriptReader;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.PreloadUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.LuaUrlUtils;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.utils.loader.Callback;
import com.immomo.mls.utils.loader.ScriptInfo;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;


import java.io.File;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/23 下午2:51
 */
public class MMUIScriptReaderImpl implements ScriptReader {
    private static final String TAG = "ScriptReader";
    private final Object tag = TAG + hashCode();


    private String rootPath;
    private String url;
    private ParsedUrl parsedUrl;

    public MMUIScriptReaderImpl(String rootPath,String url) {
        this.rootPath  = rootPath;
        this.url = url;
        parsedUrl = new ParsedUrl(url);
    }

    @SuppressLint("WrongConstant")
    @Override
    public void loadScriptImpl(ScriptInfo info) {
        final Callback callback = info.callback;

        /// step1: 若开启了debug，先加载debug.lua
        if (MLSEngine.DEBUG)
            PreloadUtils.checkDebug(info.globals);
        info.globals.setResourceFinder(new RequireResourceFinder(info.context,rootPath));

        /// step2:组装ScriptBundle类
        ScriptBundle ret = new ScriptBundle(url, LuaUrlUtils.getParentPath(parsedUrl.getUrlWithoutParams()));
        ScriptFile main = PreloadUtils.parseAssetMainScript(parsedUrl);
        ret.setMain(main);
        ret.addFlag(ScriptBundle.TYPE_ASSETS | ScriptBundle.SINGLE_FILE);
        callback.onScriptLoadSuccess(ret);
    }

    @Override
    public String getScriptVersion() {
        return "0";
    }

    @Override
    public Object getTaskTag() {
        return tag;
    }

    @Override
    public void onDestroy() {

    }
}
