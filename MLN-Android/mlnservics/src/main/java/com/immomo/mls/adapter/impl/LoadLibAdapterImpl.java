/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.adapter.impl;

import com.immomo.mls.adapter.ILoadLibAdapter;
import com.immomo.mls.util.LogUtil;

/**
 * Created by Xiong.Fangyu on 2019-12-23
 */
public class LoadLibAdapterImpl implements ILoadLibAdapter {
    private static volatile LoadLibAdapterImpl instance;

    public static LoadLibAdapterImpl getInstance() {
        if (instance == null) {
            synchronized (LoadLibAdapterImpl.class) {
                if (instance == null) {
                    instance = new LoadLibAdapterImpl();
                }
            }
        }
        return instance;
    }

    private LoadLibAdapterImpl() {

    }
    @Override
    public boolean load(String libName) {
        try {
            System.loadLibrary(libName);
            return true;
        } catch (Throwable e) {
            LogUtil.e(e, "load " + libName + " failed");
        }
        return false;
    }
}
