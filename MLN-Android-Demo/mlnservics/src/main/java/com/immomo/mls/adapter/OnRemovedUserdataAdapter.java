package com.immomo.mls.adapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.luaj.vm2.LuaUserdata;

/**
 * Created by Xiong.Fangyu on 2019-10-30
 */
public interface OnRemovedUserdataAdapter {

    /**
     * 通过id获取userdata为空，但removecache中不为空时回调
     * @param id userdata对象id
     * @param cache 已remove的对象
     * @return 可返回空，或返回cache
     */
    @Nullable
    LuaUserdata onNullGet(long id, @NonNull LuaUserdata cache);
}
