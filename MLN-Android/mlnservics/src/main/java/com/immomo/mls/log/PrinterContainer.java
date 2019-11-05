/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.log;

/**
 * Created by XiongFangyu on 2018/9/6.
 */
public interface PrinterContainer {
    void showPrinter(boolean show);

    boolean isShowPrinter();

    boolean hasClosePrinter();

    IPrinter getSTDPrinter();

    void onSTDPrinterCreated(IPrinter p);
}