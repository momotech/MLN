package com.immomo.mls.processor;

import javax.lang.model.element.Element;
import javax.tools.Diagnostic;

/**
 * Created by XiongFangyu on 2018/8/29.
 */
public interface Logger {

    void error(Element element, String message, Object... args);

    void note(Element element, String message, Object... args);

    void log(Diagnostic.Kind kind, Element element, String message, Object[] args);
}
