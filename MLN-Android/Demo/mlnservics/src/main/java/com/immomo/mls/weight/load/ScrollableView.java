package com.immomo.mls.weight.load;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
public interface ScrollableView {

    int findFirstCompletelyVisibleItemPosition();

    int getOrientation();

    boolean scrolled();
}
