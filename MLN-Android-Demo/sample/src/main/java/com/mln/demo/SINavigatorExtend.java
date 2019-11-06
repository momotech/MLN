package com.mln.demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import com.immomo.mls.InitData;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.lt.SINavigator;
import com.immomo.mls.util.FileUtil;
import com.mln.demo.activity.LuaViewActivity;
import com.mln.fileexplorer.ChooseFileActivity;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhang.ke
 * on 2019/1/31
 */
@LuaClass
public class SINavigatorExtend extends SINavigator {

    public SINavigatorExtend(Globals g, LuaValue[] init) {
        super(g, init);
    }


    @Override
    public void gotoPage(String action, Map params, int animType) {
        if (TextUtils.isEmpty(action)) {
            return;
        }
        if (FileUtil.isLocalUrl(action)) {
            if (!action.endsWith(".lua")) {
                action = action + ".lua";
            }

            if (!action.startsWith("file://android_asset/"))
                action = FileUtil.getAbsoluteUrl(action);//相对路径转化


        } else if (action.endsWith(".lua")) {
            String localUrl = ((LuaViewManager) globals.getJavaUserdata()).baseFilePath;
            File entryFile = new File(localUrl, action);//入口文件路径
            if (entryFile.exists()) {
                action = entryFile.getAbsolutePath();
            }
        }

        Activity a = getActivity();
        Intent intent = new Intent(a, LuaViewActivity.class);
        InitData initData = MLSBundleUtils.createInitData(action);
        if (initData.extras == null) {
            initData.extras = new HashMap();
        }
        initData.extras.putAll(params);
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        if (a != null) {
            a.startActivity(intent);
            a.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));
        }
    }

    @Override
    public void gotoAndCloseSelf(String action, Map params, int animType) {
        gotoPage(action, params, animType);
        closeSelf(animType);
    }

//    @Override
//    protected void internalGotoPage(String action, Bundle bundle, int at) {
//        Activity a = getActivity();
//        Intent intent = new Intent(a, LuaViewActivity.class);
//        InitData initData = MLSBundleUtils.createInitData(action);
//        intent.putExtras(MLSBundleUtils.createBundle(initData));
//        a.startActivity(intent);
//        a.overridePendingTransition(parseInAnim(at), parseOutAnim(at));
//    }

    @Override
    protected void internalGotoPage(String action, Bundle bundle, @AnimType int at, int l) {
        Activity a = getActivity();
        ChooseFileActivity.startChooseFile(a, l, ChooseFileActivity.TYPE_SDCARD, FileUtil.getRootDir().getAbsolutePath());
    }
}
