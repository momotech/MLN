package com.immomo.mls.base.ud.lv;

import androidx.annotation.NonNull;
import android.view.ViewGroup;

import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;

import java.util.List;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
public interface ILViewGroup<U extends UDViewGroup> extends ILView<U> {

    void bringSubviewToFront(UDView child);

    void sendSubviewToBack(UDView child);

    @NonNull
    ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams);

    @NonNull
    ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams);

}
