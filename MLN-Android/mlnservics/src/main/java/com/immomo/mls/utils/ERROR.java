/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public enum ERROR {
    FILE_NOT_FOUND(404, "fileNotFound"),
    FILE_UNKONWN(-1, "fileUnknown"),
    UNKNOWN_ERROR(-2, "unknownError"),
    PRELOAD_FAILED(-3, "preload file failed"),
    READ_FILE_FAILED(-4, "readFileFailed"),
    COMPILE_FAILED(-5, "compileFailed"),
    GLOBALS_DESTROY(-6, "globals is destroy"),
    TIMEOUT(-7, "timeout"),
    ;

    int code;
    String msg;

    ERROR(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() {
        return code;
    }
}