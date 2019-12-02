package com.mln.demo.mln.activity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSInstance;
import com.immomo.mls.ScriptStateListener;
import com.mln.demo.LauncherActivity;
import com.mln.demo.R;

import androidx.annotation.Nullable;


/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class LuaViewActivity extends BaseActivity {

    private MLSInstance instance;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        final long startTime = System.currentTimeMillis();
        Log.d("keye", "onCreate:   cast = " + startTime);
//        FrameLayout frameLayout = new FrameLayout(this);
//        frameLayout.setFitsSystemWindows(true);

//        getWindow().getDecorView().getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
//            //当layout结束后回调此方法
//            @Override
//            public void onGlobalLayout() {
//                Log.d("keye", "onGlobalLayout:  layout cast = " + (System.currentTimeMillis() - startTime));
//            }
//        });

//        setContentView(frameLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(R.layout.activity_luaview);
        FrameLayout frameLayout = findViewById(R.id.container);
        instance = new MLSInstance(this);
        instance.setContainer(frameLayout);
        instance.setScriptStateListener(new ScriptStateListener() {
            @Override
            public void onSuccess() {
                Log.d("keye", "onSuccess:  layout cast = " + (System.currentTimeMillis() - startTime));

            }

            @Override
            public void onFailed(Reason reason) {

            }
        });
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        if (intent != null && intent.getExtras() != null) {
            InitData initData = MLSBundleUtils.parseFromBundle(intent.getExtras()).showLoadingView(true);
            this.instance.setData(initData);
        } else {
            String file = "file://android_asset/MMLuaKitGallery/meilishuo.lua";
            InitData initData = MLSBundleUtils.createInitData(file, false).showLoadingView(true);
            this.instance.setData(initData);
        }

        if (!instance.isValid()) {
            Toast.makeText(this, "something wrong", Toast.LENGTH_SHORT).show();
        }

//        storageAndCameraPermission();
        TextView menuBtn = findViewById(R.id.menu_btn);//返回首页
        menuBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LuaViewActivity.this, LauncherActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent);
                finish();
            }
        });
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
