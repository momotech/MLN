package com.immomo.mls.adapter;

import com.immomo.mls.utils.ParsedUrl;

import org.luaj.vm2.utils.ResourceFinder;

/**
 * Created by XiongFangyu on 2018/9/17.
 */
public interface MLSResourceFinderAdapter {
    ResourceFinder newFinder(String src, ParsedUrl parsedUrl);
}
