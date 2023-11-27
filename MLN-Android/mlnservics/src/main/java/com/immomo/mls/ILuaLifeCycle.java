package com.immomo.mls;

import android.content.Intent;
import android.view.KeyEvent;

/**
 * Created by Xiong.Fangyu on 2021/1/14
 */
public interface ILuaLifeCycle {
    void onResume();
    void onPause();
    boolean dispatchKeyEvent(KeyEvent event);
    boolean onActivityResult(int requestCode, int resultCode, Intent data);
    void onDestroy();
}
