package com.immomo.mls.wrapper;

import java.util.HashMap;
import java.util.Map;

public class LuaDirectory {
    private ScriptFile main;
    private Map<String, ScriptFile> children;

    public ScriptFile getMain() {
        return main;
    }

    public void setMain(ScriptFile main) {
        this.main = main;
    }

    public Map<String, ScriptFile> getChildren() {
        return children;
    }

    public void setChildren(Map<String, ScriptFile> children) {
        this.children = children;
    }

    public void addChild(ScriptFile c) {
        addChild(c.getChunkName(), c);
    }

    public void addChild(String chunkname, ScriptFile c) {
        if (children == null) {
            children = new HashMap<>();
        }
        children.put(chunkname, c);
    }

    public boolean hasChildren() {
        return children != null;
    }
}
