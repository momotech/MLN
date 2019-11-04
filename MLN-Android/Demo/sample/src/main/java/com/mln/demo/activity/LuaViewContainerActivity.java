package com.mln.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.view.KeyEvent;
import android.view.ViewGroup;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;

/**
 * Created by XiongFangyu on 2018/8/15.
 */

public class LuaViewContainerActivity extends Activity {
    private LuaViewContainer container;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        container = new LuaViewContainer(this);
        container.setLayoutParams(new ViewGroup.LayoutParams(500, 500));
        setContentView(container);
        Intent intent = getIntent();
        if (intent != null) {
            InitData initData = MLSBundleUtils.parseFromBundle(intent.getExtras()).showLoadingView(true);
//            initData.forceDebug = true;
            container.setData(initData);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        container.onResume();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK && event.getAction() != KeyEvent.ACTION_UP) {
            container.dispatchKeyEvent(event);
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    protected void onPause() {
        super.onPause();
        container.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        container.onDestroy();
    }
}
