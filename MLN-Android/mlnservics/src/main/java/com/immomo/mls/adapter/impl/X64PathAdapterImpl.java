package com.immomo.mls.adapter.impl;

import com.immomo.mls.adapter.X64PathAdapter;
import com.immomo.mls.utils.MLSUtils;

/**
 * Created by Xiong.Fangyu on 2020/7/15
 */
public class X64PathAdapterImpl implements X64PathAdapter {

    @Override
    public String checkArm64(String path) {
        return MLSUtils.checkArm64(path);
    }
}
