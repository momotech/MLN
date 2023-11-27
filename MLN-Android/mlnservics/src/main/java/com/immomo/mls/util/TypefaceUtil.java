/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import android.content.Context;
import android.graphics.Typeface;

import java.util.HashMap;
import java.util.Map;


/**
 * 字体处理，字体使用SimpleCache，全局缓存
 */
public class TypefaceUtil {
    private static final Map<String, Typeface> TypeFaceCache = new HashMap<>();

    /**
     * create typeface
     */
    public static Typeface create(final Context context, final String name) {
        Typeface result = TypeFaceCache.get(name);
        if (result == null) {
            final String fontNameOrAssetPathOrFilePath = ParamUtil.getFileNameWithPostfix(name, "ttf");
            result = createFromAsset(context, fontNameOrAssetPathOrFilePath);
            if (result == null) {
                result = createFromFile(fontNameOrAssetPathOrFilePath);
            }
            if (result == null) {
                result = createByName(fontNameOrAssetPathOrFilePath);
            }

            if (result != null) {
                TypeFaceCache.put(name, result);
            }
        }

        return result;
    }

    /**
     * create typeface by name or path
     */
    private static Typeface createByName(final String fontName) {
        try {
            final Typeface typeface = Typeface.create(fontName, Typeface.NORMAL);
//            if (typeface != null)) {//得到的是默认字体则返回null
//                return null;
//            }
            return typeface;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * create typeface from asset
     */
    private static Typeface createFromAsset(final Context context, final String assetPath) {
        try {
            return Typeface.createFromAsset(context.getAssets(), assetPath);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * create typeface from file path
     */
    private static Typeface createFromFile(final String filePath) {
        try {
            return Typeface.createFromFile(filePath);
        } catch (Exception e) {
            return null;
        }
    }

}