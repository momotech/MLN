package com.immomo.mls.adapter.impl;

import com.immomo.mls.adapter.ScriptReaderCreator;
import com.immomo.mls.adapter.ScriptReader;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public class DefaultScriptReaderCreatorImpl implements ScriptReaderCreator {
    @Override
    public ScriptReader newScriptLoader(String src) {
        return new DefaultScriptReaderImpl(src);
    }
}
