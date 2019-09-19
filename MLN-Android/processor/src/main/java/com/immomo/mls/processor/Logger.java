/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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