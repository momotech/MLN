/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.github.crab2died;

import org.apache.poi.ss.usermodel.Sheet;

/**
 * Created by Xiong.Fangyu on 2020/7/28
 */
public interface OnSheetPreparedListener {
    void onPrepared(Sheet sheet);
}
