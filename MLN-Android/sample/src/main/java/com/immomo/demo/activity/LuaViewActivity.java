/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.immomo.mln.R;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSInstance;

import androidx.annotation.Nullable;


/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class LuaViewActivity extends Activity  {

    private MLSInstance instance;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FrameLayout frameLayout = new FrameLayout(this);
//        frameLayout.setFitsSystemWindows(true);
        setContentView(frameLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        instance = new MLSInstance(this);
        instance.setContainer(frameLayout);
        instance.setBackgroundRes(R.drawable.ic_launcher_background);
        Intent intent = getIntent();
        if (intent != null) {
            InitData initData = MLSBundleUtils.parseFromBundle(intent.getExtras()).showLoadingView(true);
//            initData.forceDebug = true;
            instance.setData(initData);
        }
//        File file = new File(FileUtil.getLuaDir(), "172.16.139.44/~XiongFangyu/UI_HScrollView.lua");
//        instance.setUrl(file.getAbsolutePath());
//        instance.setUrl("http://172.16.139.44/~XiongFangyu/UI_HScrollView.zip");
        if (!instance.isValid()) {
            Toast.makeText(this, "something wrong", Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        instance.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        instance.onPause();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            if (event.getAction() != KeyEvent.ACTION_UP)
                instance.dispatchKeyEvent(event);

            if (!instance.getBackKeyEnabled())
                return true;
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        instance.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (instance.onActivityResult(requestCode, resultCode, data))
            return;
        super.onActivityResult(requestCode, resultCode, data);
    }
}