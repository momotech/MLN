package com.immomo.mls.wrapper;


import org.luaj.vm2.utils.ResourceFinder;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 基于{@link ScriptBundle} 寻找相应的资源
 */
public class ScriptBundleResourceFinder implements ResourceFinder {

    private final ScriptBundle scriptBundle;

    /**
     * 需传入{@link ScriptBundle}实例
     */
    public ScriptBundleResourceFinder(ScriptBundle scriptBundle) {
        this.scriptBundle = scriptBundle;
    }

    @Override
    public String preCompress(String name) {
        return name;
    }

    @Override
    public String findPath(String name) {
        ScriptFile sf = scriptBundle.getChild(name);
        if (sf == null)
            return null;
        if (sf.hasSourceData())
            return null;
        String p;
        File f;
        p = sf.getBinPath(scriptBundle.getBasePath());
        f = new File(p);
        if (f.isFile()) {
            return p;
        }
        p = sf.getPath(scriptBundle.getBasePath());
        f =  new File(p);
        if (f.isFile())
            return p;
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        ScriptFile sf = scriptBundle.getChild(name);
        if (sf == null)
            return null;
        return sf.getSourceData();
    }

    @Override
    public void afterContentUse(String name) {
        ScriptFile sf = scriptBundle.getChild(name);
        if (sf != null)
            sf.setSourceData(null);
    }
}
