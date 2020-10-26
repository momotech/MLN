/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.os.Parcel;
import android.os.Parcelable;

import com.immomo.mls.utils.UrlParams;
import com.immomo.mls.utils.loader.LoadTypeUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/15.
 */
public class InitData implements Parcelable {

    /**
     * lua文件的根目录
     */
    public String rootPath;
    /**
     * lua脚本地址
     */
    public String url;
    /**
     * 放入环境的参数
     *
     * @see com.immomo.mls.fun.globals.LuaView#putExtras(Map)
     */
    public HashMap extras;
    /**
     * 需要预加载的脚本，或脚本目录
     * eg: [utils/color.lua, cell] 将预加载根目录下color.lua和根目录下的cell目录里所有脚本
     */
    public String[] preloadScripts;
    /**
     * 集合了所有的参数
     * 使用{@link #addType(int)}设置
     *
     * @see LoadTypeUtils
     * @see Constants#LT_NORMAL
     */
    public int loadType = Constants.LT_NORMAL;
    /**
     * 设置超时，默认20s
     * 若设置为0，表示不监听超时
     * 单位ms
     */
    public long loadTimeout = MLSConfigs.defaultLoadScriptTimeout;

    public InitData(String url) {
        this.url = url;
        showLoadingView(true);
        showLoadingBackground(true);
        forceDebug(MLSConfigs.openDebug);
        forceNotUseX64();
    }

    /**
     * 强制下载
     */
    public InitData forceDownload() {
        addType(Constants.LT_FORCE_DOWNLOAD);
        return this;
    }

    /**
     * 加载动画
     */
    public InitData showLoadingView(boolean show) {
        if (show) {
            addType(Constants.LT_SHOW_LOAD);
        } else {
            removeType(Constants.LT_SHOW_LOAD);
        }
        return this;
    }

    /**
     * 是否显示加载背景
     */
    public InitData showLoadingBackground(boolean show) {
        if (show) {
            addType(Constants.LT_SHOW_LOAD_BG);
        } else {
            removeType(Constants.LT_SHOW_LOAD_BG);
        }
        return this;
    }

    /**
     * 设置为debug模式
     * 1. 有个reload按钮
     */
    public InitData forceDebug(boolean d) {
        if (d) {
            addType(Constants.LT_FORCE_DEBUG);
        } else {
            removeType(Constants.LT_FORCE_DEBUG);
        }
        return this;
    }

    public InitData forceNotUseX64() {
        addType(Constants.LT_NO_X64);
        return this;
    }

    public InitData useX64() {
        removeType(Constants.LT_NO_X64);
        return this;
    }

    /**
     * 在主线程中加载脚本，包括下载脚本，轻易不要设置
     */
    public InitData loadInMainThread() {
        addType(Constants.LT_MAIN_THREAD);
        return this;
    }

    /**
     * 不关心window是否有宽高（已在View树中）
     * 默认情况，脚本会在window已有宽高的情况下才加载
     */
    public InitData noWindowSize() {
        addType(Constants.LT_NO_WINDOW_SIZE);
        return this;
    }

    /**
     * 是否自动预加载，当{@link #preloadScripts}为空时
     * 且{@link UrlParams#getPreload()} 为空时，自动预加载根目录下所有的lua文件
     */
    public InitData doAutoPreload() {
        addType(Constants.LT_AUTO_PRELOAD);
        return this;
    }

    public void addType(@Constants.LoadType int type) {
        loadType = LoadTypeUtils.add(loadType, type);
    }

    public void removeType(@Constants.LoadType int type) {
        loadType = LoadTypeUtils.remove(loadType, type);
    }

    public boolean hasType(@Constants.LoadType int type) {
        return LoadTypeUtils.has(loadType, type);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.url);
        dest.writeInt(this.loadType);
        dest.writeSerializable(this.extras);
        dest.writeStringArray(this.preloadScripts);
    }

    protected InitData(Parcel in) {
        this.url = in.readString();
        this.loadType = in.readInt();
        this.extras = (HashMap) in.readSerializable();
        this.preloadScripts = in.createStringArray();
    }

    public static final Creator<InitData> CREATOR = new Creator<InitData>() {
        @Override
        public InitData createFromParcel(Parcel source) {
            return new InitData(source);
        }

        @Override
        public InitData[] newArray(int size) {
            return new InitData[size];
        }
    };

    @Override
    public String toString() {
        return url;
    }
}