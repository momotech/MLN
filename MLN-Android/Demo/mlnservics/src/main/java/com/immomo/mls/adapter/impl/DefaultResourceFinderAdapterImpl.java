package com.immomo.mls.adapter.impl;

import com.immomo.mls.MLSResourceFinder;
import com.immomo.mls.adapter.MLSResourceFinderAdapter;
import com.immomo.mls.utils.ParsedUrl;

import org.luaj.vm2.utils.ResourceFinder;

/**
 * Created by XiongFangyu on 2018/9/17.
 */
public class DefaultResourceFinderAdapterImpl implements MLSResourceFinderAdapter {
    @Override
    public ResourceFinder newFinder(String src, ParsedUrl parsedUrl) {
        return new MLSResourceFinder(src, parsedUrl);
    }
}
