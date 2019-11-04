package com.mln.demo.performance;

import android.content.Intent;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSInstance;
import com.mln.demo.R;
import com.mln.demo.activity.BaseActivity;

import androidx.annotation.Nullable;


/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class EmptyActivity extends BaseActivity  {

    private MLSInstance instance;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FrameLayout frameLayout = new FrameLayout(this);
//        frameLayout.setFitsSystemWindows(true);
        setContentView(frameLayout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        MemoryStatic.logMemoryStats("before === ");

        for (int i = 0; i < 30; i++) {
            instance = new MLSInstance(this);
            instance.setContainer(frameLayout);
            instance.setBackgroundRes(R.drawable.ic_launcher_background);

            String file = "file://android_asset/meilishuo.zip";
            if (file == null)
                return;
            InitData initData = MLSBundleUtils.createInitData(file, false).showLoadingView(true);

            // instance.setData(initData);

            if (!instance.isValid()) {
                Toast.makeText(this, "something wrong", Toast.LENGTH_SHORT).show();
            }
        }


        MemoryStatic.logMemoryStats("after   === ");


        storageAndCameraPermission();
    }

    @Override
    protected void onResume() {
        super.onResume();
//        instance.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
//        instance.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
       // instance.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
       /* if (instance.onActivityResult(requestCode, resultCode, data))
            return;*/
        super.onActivityResult(requestCode, resultCode, data);
    }
}
