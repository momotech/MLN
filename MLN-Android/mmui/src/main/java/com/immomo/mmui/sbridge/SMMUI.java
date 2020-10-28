/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.sbridge;

import android.content.Context;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.immomo.mls.Constants;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mmui.MMUIContainer;

import org.luaj.vm2.Globals;

import java.io.File;

/**
 * Created by MLN Template
 * 注册方法：
 * Register.newSHolderWithLuaClass(SMMUI.LUA_CLASS_NAME, SMMUI.class)
 */
@LuaClass(isStatic = true)
public class SMMUI {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "MMUI";

    //<editor-fold desc="Bridge API">

    @LuaBridge
    static boolean attachUIPage(Globals g, ViewGroup container, String url) {
        String target = null;
        if (url.charAt(0) == File.separatorChar) {
            target = new File(url).isFile() ? url : null;
        } else if (url.startsWith(Constants.ASSETS_PREFIX)) {
            target = url;
        }
        if (target != null) {
            return innerAttachUIPage(container, target);
        }
        LuaViewManager lm = (LuaViewManager) g.getJavaUserdata();
        if (lm == null) {
            return false;
        }

        StringBuilder sb = new StringBuilder(lm.baseFilePath);
        if (sb.charAt(sb.length() - 1) != File.separatorChar && url.charAt(0) != File.separatorChar) {
            sb.append(File.separatorChar);
        }
        sb.append(url);
        if (!url.endsWith(Constants.POSTFIX_LUA)) {
            sb.append(Constants.POSTFIX_LUA);
        }

        target = sb.toString();

        if (!target.startsWith(Constants.ASSETS_PREFIX) && !new File(target).isFile())
            return false;
        return innerAttachUIPage(container, target);
    }
    //</editor-fold>

    private static boolean innerAttachUIPage(ViewGroup container, String url) {
        MMUIContainer mmui = new MMUIContainer(container.getContext(), false);
        mmui.setUrl(url);
        container.addView(mmui);
        return mmui.isValid();
    }

    /**
     * 获取上下文，一般情况，此上下文为Activity
     *
     * @param globals 虚拟机，可通过构造函数存储
     */
    protected static Context getContext(@NonNull Globals globals) {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }
}
