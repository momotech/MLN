package com.immomo.mls.fun.ud.view.recycler;


import com.immomo.mls.fun.other.Size;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by Xiong.Fangyu
 */
@LuaApiUsed
public class UDCollectionAutoFitAdapter extends UDCollectionAdapter {
    public static final String LUA_CLASS_NAME = "CollectionViewAutoFitAdapter";
    public static final String[] methods = new String[]{

    };

    @LuaApiUsed(ignore = true)
    public UDCollectionAutoFitAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected Size initSize() {
       return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
    }

    /**
     * autoFitAdapter 两端统一，cellSize用Wrap_Content
     */
    @Override
    protected void onOrientationChanged() {
        super.onOrientationChanged();
        initSize.setHeight(Size.WRAP_CONTENT);
        initSize.setWidth(Size.WRAP_CONTENT);
    }

    @Override
    public boolean hasCellSize() {
        return false;
    }
}
