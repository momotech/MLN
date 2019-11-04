package com.immomo.mls.weight.load;

import androidx.annotation.NonNull;
import android.view.View;

/**
 * Created by XiongFangyu on 2018/6/21.
 */
public interface ILoadWithTextView extends ILoadView {
    /**
     * 设置加载时的文字
     * @param text
     */
    void setLoadText(CharSequence text);

    /**
     * 获取view
     * @return
     */
    @NonNull View getView();
}
