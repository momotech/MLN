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
public class ScriptLoadException extends Exception {

    private int code;
    private String msg;
    public ScriptLoadException(int code, String msg, Throwable cause) {
        super(cause);
        this.code = code;
        this.msg = msg;
    }

    public ScriptLoadException(ERROR e, Throwable cause) {
        this(e.code, e.msg, cause);
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }
}