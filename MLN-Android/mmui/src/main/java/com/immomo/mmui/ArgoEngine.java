/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.app.Application;
import android.os.Environment;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSBuilder;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.global.LVConfigBuilder;
import com.immomo.mls.provider.ImageProvider;

/**
 * Description:argo Application初始化
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/8/24 上午10:29
 */
public class ArgoEngine {
    public static String SD_CARD_PATH;


    /**
     * 初始化sd卡地址（默认地址为"SD卡/ARGO/"）
     */
    static {
        try {
            SD_CARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath();
            if (!SD_CARD_PATH.endsWith("/")) {
                SD_CARD_PATH += "/";
            }
            SD_CARD_PATH += "ARGO/";
        } catch (Exception e) {
        }
    }

    /**
     * Argo 在Application初始化
     * @param app Application
     */
    public static void init(Application app) {
        init(app,false);
    }

    /**
     * Argo 在Application初始化（单独使用argo框架初始化）
     * @param app Application
     * @param debug 是否debug模式
     * @return
     */
    public static void init(Application app, boolean debug) {
        MLSBuilder mlsBuilder = MLSEngine.init(app, debug)
                .setLVConfig(new LVConfigBuilder(app)
                        .setSdcardDir(SD_CARD_PATH)
                        .setRootDir(SD_CARD_PATH)
                        .setCacheDir(SD_CARD_PATH + "cache")
                        .setImageDir(SD_CARD_PATH + "image")
                        .setGlobalResourceDir(SD_CARD_PATH + "g_res")
                        .build());
        mlsBuilder.build(true);
        initArgo(app);
    }


    /**
     * Argo 在Application初始化（与MLN框架公用，必须MLN初始化之后）
     * @param app
     */
    public static void initArgo(Application app) {
        MMUIEngine.init(app);
        MMUIEngine.preInit(1);
    }


    /**
     * 设置图片加载器
     * @param imageProvider
     */
    public static void setImageProvider(ImageProvider imageProvider) {
        MLSAdapterContainer.setImageProvider(imageProvider);
    }


    /**
     * 注册Argo注册跳转的页面
     * @param linkHolders
     */
    public static void registerActivity(LinkHolder... linkHolders) {
        for(LinkHolder linkHolder: linkHolders) {
            MMUILinkRegister.register(linkHolder.linkKey,linkHolder.linkActivity);
        }
    }


    /**
     * 页面包装类
     */
    public static class LinkHolder {
        public String linkKey;
        public Class linkActivity;
        public LinkHolder(String linkKey, Class linkActivity) {
            this.linkKey = linkKey;
            this.linkActivity  = linkActivity;
        }
    }


}
