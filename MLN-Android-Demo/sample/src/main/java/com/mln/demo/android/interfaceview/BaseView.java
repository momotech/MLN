package com.mln.demo.android.interfaceview;

import java.util.List;

/**
 * Created by zhang.ke
 * on 2019-11-08
 */
public interface BaseView<T> {
    void refreshUI(List<T> list);

    void fetchUI(List<T> list);
}
