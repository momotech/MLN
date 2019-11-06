package com.immomo.mls.weight.load;

/**
 * Created by XiongFangyu on 2018/6/21.
 *
 * 加载view
 */
public interface ILoadView {
    /**
     * 开始加载动画
     */
    void startAnim();

    /**
     * 结束加载动画
     */
    void stopAnim();

    /**
     * 显示加载view
     */
    void showLoadAnimView();

    /**
     * 隐藏加载view
     */
    void hideLoadAnimView();
}
