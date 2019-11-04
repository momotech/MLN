package com.immomo.mls.fun.weight;


import android.view.View;

/**
 * Created by Xiong.Fangyu on 2018/11/6
 */
public interface IPriorityObserver {

    void onViewPriorityChanged(View child, int oldPriority, int newPriority);
}
