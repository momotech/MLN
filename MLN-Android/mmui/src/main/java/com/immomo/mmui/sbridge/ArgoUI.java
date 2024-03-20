package com.immomo.mmui.sbridge;

import android.view.ViewGroup;

import com.immomo.mls.Constants;
import com.immomo.mls.ILuaParent;
import com.immomo.mls.InitData;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mmui.MMUIInstance;
import com.immomo.mmui.MMUILuaViewManager;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;
import org.luaj.vm2.utils.PathResourceFinder;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2021/1/14
 */
@LuaApiUsed
public class ArgoUI {
    /*
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "ArgoUI";
    //<editor-fold desc="native method">

    /**
     * 初始化方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    //<editor-fold desc="Bridge API">
    @CGenerate(params = "G")
    @LuaApiUsed
    static boolean attachUIPage(long L, LuaValue ud, final String url) {
        LuaViewManager lm = (LuaViewManager) Globals.getGlobalsByLState(L).getJavaUserdata();
        if (lm == null) {
            return false;
        }
        ViewGroup vg = (ViewGroup) ud.toUserdata().getJavaUserdata();
        String target = null;
        if (url.charAt(0) == File.separatorChar) {
            target = new File(url).isFile() ? url : null;
        } else if (RelativePathUtils.isAssetUrl(url)) {
            target = Constants.ASSETS_PREFIX + RelativePathUtils.getAbsoluteAssetUrl(url);
        }
        if (target != null) {
            return innerAttachUIPage(lm instanceof MMUILuaViewManager
                            ? ((MMUILuaViewManager) lm).instance : lm.instance,
                    vg, lm.baseFilePath, target, url);
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
        return innerAttachUIPage(lm instanceof MMUILuaViewManager
                        ? ((MMUILuaViewManager) lm).instance : lm.instance,
                vg, lm.baseFilePath, target, url);
    }

    @CGenerate(params = "G")
    @LuaApiUsed
    static void dettachUIPage(long L, String url) {
        LuaViewManager lm = (LuaViewManager) Globals.getGlobalsByLState(L).getJavaUserdata();
        if (lm == null) return;
        lm.instance.remove(url);
    }

    @CGenerate(params = "G", returnType = "T")
    @LuaApiUsed
    static long mapToTable(long L, UDMap map) {
        if (map == null) {
            return LuaValue.Nil().nativeGlobalKey();
        }
        return ConvertUtils.toTable(Globals.getGlobalsByLState(L), map.getMap()).nativeGlobalKey();
    }
    //</editor-fold>

    private static boolean innerAttachUIPage(ILuaParent parent, ViewGroup container, String base, String url, String key) {
        if (parent instanceof MMUIInstance) {
            return attachInOneVm((MMUIInstance) parent, base, key);
        }
        parent.setHotReloadImediately(true);
        MMUIInstance instance = new MMUIInstance(container.getContext(), true);
        instance.setContainer(container);
        InitData initData = MLSBundleUtils.createInitData(url);
        initData.rootPath = base;
        instance.setData(initData);
        parent.add(key, instance);
        return instance.isValid();
    }

    private static boolean attachInOneVm(MMUIInstance in, String base, String url) {
        in.setHotReloadImediately(true);
        Globals g = in.getGlobals();
        g.addResourceFinder(new PathResourceFinder(base));
        return g.require(url);
    }
}
