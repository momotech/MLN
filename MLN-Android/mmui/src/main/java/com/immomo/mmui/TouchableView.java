package com.immomo.mmui;

import android.view.View;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public interface TouchableView {
    void addOnTouchListener(View.OnTouchListener l);
    void removeOnTouchListener(View.OnTouchListener l);
}
