package com.mln.demo.activity;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.widget.FrameLayout;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.MLSInstance;
import com.immomo.mls.ScriptStateListener;

/**
 * Created by XiongFangyu on 2018/8/15.
 */
public class LuaViewContainer extends FrameLayout implements ScriptStateListener{
    public LuaViewContainer(@NonNull Context context) {
        this(context, null);
    }

    public LuaViewContainer(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LuaViewContainer(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        instance = new MLSInstance(context);
        instance.setContainer(this);
    }

    private MLSInstance instance;

    public void setUrl(String url) {
        setData(MLSBundleUtils.createInitData(url));
    }

    public void setData(InitData data) {
        data.showLoadingView(showLoadingView());
        instance.setData(data);
        if (!data.hasType(Constants.LT_SHOW_LOAD)) {
            instance.setScriptStateListener(this);
        }
    }

    public boolean isValid() {
        return instance.isValid();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        instance.dispatchKeyEvent(event);
        return super.dispatchKeyEvent(event);
    }

    public void onResume() {
        instance.onResume();
    }

    public void onPause() {
        instance.onPause();
    }

    public void onDestroy() {
        instance.onDestroy();
    }

    protected boolean showLoadingView() {
        return false;
    }

    @Override
    public void onSuccess() {

    }

    @Override
    public void onFailed(ScriptStateListener.Reason reason) {

    }
}
