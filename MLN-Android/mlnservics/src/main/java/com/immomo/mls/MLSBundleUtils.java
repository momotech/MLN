/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MLSBundleUtils {
    public static final String KEY_URL = "LUA_URL";
    public static final String KEY_INIT_DATA = "__INIT_DATA";

    private MLSBundleUtils(){}

    public static @NonNull InitData createInitData(@NonNull String luaUrl) {
        return new InitData(luaUrl);
    }

    public static @NonNull InitData createInitData(@NonNull String luaUrl, boolean forceDownload) {
        InitData initData = new InitData(luaUrl);
        if (forceDownload) initData.forceDownload();
        return initData;
    }

    public static @Nullable
    InitData parseFromBundle(@Nullable Bundle bundle) {
        if (bundle == null)
            return null;
        InitData initData = bundle.getParcelable(KEY_INIT_DATA);
        if (initData == null) {
            initData = new InitData(bundle.getString(KEY_URL));
        }
        return initData;
    }

    public static @NonNull Bundle createBundle(@NonNull String url) {
        return createBundle(url, false);
    }

    public static @NonNull Bundle createBundle(@NonNull String url, boolean forceDownload) {
        return createBundle(createInitData(url, forceDownload));
    }

    public static @NonNull Bundle createBundle(InitData data) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(KEY_INIT_DATA, data);
        return bundle;
    }
}