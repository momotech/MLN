/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import android.content.Context;

import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;

import org.luaj.vm2.utils.ResourceFinder;

import java.io.File;
import java.io.InputStream;
import java.util.Objects;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 寻找在Android assets包下存在的文件数据
 */
public class AssetsResourceFinder implements ResourceFinder {
    private final Context context;

    /**
     * 需要传入上下文
     */
    public AssetsResourceFinder(Context context) {
        this.context = context.getApplicationContext();
    }

    @Override
    public String preCompress(String name) {
        if (name.endsWith(".lua"))
            name = name.substring(0, name.length() - 4);
        if (!name.contains(".."))
            return name.replaceAll("\\.", File.separator) + ".lua";
        return FileUtil.dealRelativePath("", name + ".lua");
    }

    @Override
    public String findPath(String name) {
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        InputStream is = null;
        try {
            is = context.getAssets().open(name);
            byte[] data = new byte[is.available()];
            if (is.read(data) == data.length)
                return data;
        } catch (Throwable ignore) {

        } finally {
            IOUtil.closeQuietly(is);
        }
        return null;
    }

    @Override
    public void afterContentUse(String name) {

    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        return o != null && getClass() == o.getClass();
    }

    @Override
    public int hashCode() {
        return 0;
    }
}