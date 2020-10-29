/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import androidx.annotation.IntDef;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by XiongFangyu on 2018/9/6.
 */

public interface Constants {

    String KEY_URL_PARAMS = "urlParams";
    String KEY_URL = "url";
    String KEY_LUA_SOURCE = "LuaSource";//判断lua来源，url/本地文件,参考window方法:getLuaSource(）
    String KEY_OFFLINE_VERSION = "offlineVersion";
    String KEY_OFFLINE_URL = "offlineUrl";
    String KEY_DEBUG_BUTTON_EVENT = "debugButtonEvent";
    String KEY_DEBUG_BUTTON_PARAMS = "open";

    /**
     * 适当的时候，更新sdk版本，更新需记录文档，并同步iOS
     */
    String SDK_VERSION = "1.6.0";
    int SDK_VERSION_INT = 43;
    //Bundle encrypt and decrypt
    String POSTFIX_LUA = ".lua";
    String POSTFIX_X64 = "64";
    String POSTFIX_BIN = "b";
    String POSTFIX_B_LUA = POSTFIX_LUA + POSTFIX_BIN;
    String POSTFIX_LV_ZIP = ".zip";//lua的zip包
    String POSTFIX_SIGN = ".sign";
    String ASSETS_PREFIX = "file://android_asset/";

    /**
     * Load Type
     *                  * * * * * * * * *
     * force download:                  1
     * main thread:                   1
     * auto preload:                1
     * no x64:                    1
     * show load:               1
     * show load bg:          1
     * force debug:         1
     * no window size:    1
     */
    int LT_NORMAL           = 0;/*普通加载类型，加载时根据内置逻辑处理是否需要下载、使用线程等*/
    int LT_FORCE_DOWNLOAD   = 1;/*强制下载（解压）*/
    int LT_MAIN_THREAD      = 1<<1;/*强制在主线程中执行，默认在子线程做加载文件操作*/
    int LT_AUTO_PRELOAD     = 1<<2;/*强制与加载所有文件*/
    int LT_NO_X64           = 1<<3;/*强制不使用64位目录*/
    int LT_SHOW_LOAD        = 1<<4;/*加载时显示loading view*/
    int LT_SHOW_LOAD_BG     = 1<<5;/*加载时显示load背景*/
    int LT_FORCE_DEBUG      = 1<<6;/*强制debug*/
    int LT_NO_WINDOW_SIZE   = 1<<7;/*不关心window是否有宽高大小*/

    @Target(ElementType.PARAMETER)
    @IntDef({LT_FORCE_DOWNLOAD,
            LT_MAIN_THREAD,
            LT_AUTO_PRELOAD,
            LT_NO_X64,
            LT_SHOW_LOAD,
            LT_SHOW_LOAD_BG,
            LT_FORCE_DEBUG})
    @Retention(RetentionPolicy.SOURCE)
    @interface LoadType { }
}