package com.immomo.mls.processor;


import com.immomo.mls.annotation.LuaBridge;

import javax.lang.model.element.Element;

/**
 * Created by XiongFangyu on 2018/8/29.
 */
class PropertyElement {
    Element setter;
    Element getter;
    LuaBridge bridge;
}
