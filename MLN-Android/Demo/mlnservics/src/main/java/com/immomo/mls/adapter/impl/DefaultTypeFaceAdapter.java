package com.immomo.mls.adapter.impl;

import android.graphics.Typeface;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.util.TypefaceUtil;

/**
 * Created by XiongFangyu on 2018/9/7.
 */
public class DefaultTypeFaceAdapter implements TypeFaceAdapter {
    @Override
    public Typeface create(String name) {
        return TypefaceUtil.create(MLSEngine.getContext(), name);
    }
}
