package com.immomo.mls.adapter;

import com.immomo.mls.utils.loader.ScriptInfo;

/**
 * Created by Xiong.Fangyu on 2018/11/1
 */
public interface ScriptReader {

    void loadScriptImpl(final ScriptInfo info);

    String getScriptVersion();

    Object getTaskTag();

    void onDestroy();
}
