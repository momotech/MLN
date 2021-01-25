/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.fragment.app.Fragment;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.OnGlobalsCreateListener;
import com.immomo.mmui.databinding.bean.ObservableField;
import com.immomo.mmui.wraps.RequireResourceFinder;

import org.luaj.vm2.Globals;

import java.io.File;

/**
 * Description:Argo 使用入口
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/8/18 下午4:52
 */
public class Argo {
    private static final String ARGO_PATH = Constants.ASSETS_PREFIX;
    private MMUIInstance mmuiInstance;
    private MMUIBinding mmuiBinding;
    private ViewGroup rootView;
    private boolean isLoadedUI = false;
    private Context context;

    /**
     * Activity 中使用argo
     *
     * @param activity
     */
    public Argo(Activity activity) {
        rootView= new FrameLayout(activity);
        activity.setContentView(rootView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        initArgo(activity,rootView);
    }


    /**
     * Fragment中使用argo
     * @param fragment
     * @return
     */
    public Argo(Fragment fragment) {
        rootView = new FrameLayout(context);
        initArgo(context,rootView);
    }

    /**
     * ViewGroup 中使用
     *
     * @param viewGroup
     *
     */
    public Argo(ViewGroup viewGroup) {
        rootView = (ViewGroup) viewGroup;
        initArgo(rootView.getContext(),rootView);
    }

    /**
     * 是否显示debugButton
     * @param isShowDebugButton
     */
    public void showDebugButton(boolean isShowDebugButton) {
        if(isLoadedUI) {
            throw new RuntimeException("must invoke before loadAssetsUI");
        }
        mmuiInstance.setShowDebugButton(isShowDebugButton);
    }


    /**
     * 初始化MMInstance 和 mmuiBinding
     * @param context
     * @param rootView
     */
    private void initArgo(Context context,ViewGroup rootView) {
        mmuiInstance = new MMUIInstance(context,false, false);
        mmuiInstance.setContainer(rootView);
        mmuiBinding = new MMUIBinding(mmuiInstance);
        this.context = context;
    }


    /**
     * 加载lua文件（.lua放到assert目录下）
     * @param rootPath assert中业务的根目录
     * @param fileName lua文件名
     */
    private ViewGroup loadAssetsUI(final String rootPath, String fileName) {
        isLoadedUI = true;
        String filePath = !TextUtils.isEmpty(rootPath) ? ARGO_PATH + rootPath + File.separator + fileName : ARGO_PATH + fileName;
        InitData initData = MLSBundleUtils.createInitData(filePath);
        initData.rootPath = rootPath;
        mmuiInstance.setData(initData);
        return rootView;
    }


    /**
     * 数据绑定
     * @param viewModel
     */
    public void bind(ObservableField viewModel) {
        if(!isLoadedUI) {
            loadAssetsUI(viewModel.getRootPath(),viewModel.getEntryFile());
        }
        if(mmuiBinding !=null) {
            if(viewModel != null) {
                mmuiBinding.bind(viewModel.getModelKey(),viewModel);
            } else {
                throw new RuntimeException(viewModel.getClass().getSimpleName() + "must extends ObservableField");
            }
        }
    }


    /**
     * 生命周期 onResume
     * 对应于Activity,Fragment的onResume
     */
    public void onResume() {
        mmuiInstance.onResume();
    }

    /**
     * 生命周期 onPause
     * 对应于Activity,Fragment的onPause
     */
    public void onPause() {
        mmuiInstance.onPause();
    }


    /**
     * 生命周期 onDestroy
     * 对应于Activity,Fragment的onDestroy
     */
    public void onDestroy() {
        mmuiInstance.onDestroy();
    }


    /**
     * 生命周期 页面返回监听
     * @param requestCode
     * @param resultCode
     * @param data
     * @return
     */
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return mmuiInstance.onActivityResult(requestCode,resultCode,data);
    }


    /**
     * 事件回调
     * 在activity的dispatchKeyEvent方法中调用
     * eg:
     *  if (argo.dispatchKeyEvent(event))
     *      return true;
     *  else
     *      return super.dispatchKeyEvent(event);
     */
    public boolean dispatchKeyEvent(KeyEvent event) {
        return mmuiInstance.dispatchKeyEvent(event);
    }

    /**
     * 事件回调
     * 在activity的dispatchKeyEvent方法中调用
     * 若返回true，表示在lua中处理
     * 建议直接使用{@link #dispatchKeyEvent}
     * @see #dispatchKeyEvent(KeyEvent)
     * @see MMUIInstance#dispatchKeyEvent(KeyEvent)
     */
    public boolean getBackKeyEnabled(){
      return mmuiInstance.getBackKeyEnabled();
    }
}
