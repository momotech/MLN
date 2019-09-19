/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import android.content.Context;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019-08-21
 * Time         :   11:45
 * Description  :   点击扫描二维码标识，拉起来主客户端扫码界面
 */
public interface MLSQrCaptureAdapter {

    void startQrCapture(Context context);
}