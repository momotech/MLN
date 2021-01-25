/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.log;

public enum ErrorType {
    LOG("", 0xFFFFFFFF),
    ERROR("[LUA_ERROR] ", 0xFFFF0000),
    ERROR_REPEAT("", 0xFFFF0000),
    WARNING("[LUA_WARNING] ", 0xFFFFFF00),
    WARNING_REPEAT("", 0xFFFFFF00);

    private final String errorPrefix;
    private final int errorColor;

    ErrorType(String errorPrefix, int errorColor) {
        this.errorPrefix = errorPrefix;
        this.errorColor = errorColor;
    }

    public String getErrorPrefix() {
        return this.errorPrefix;
    }

    public int getErrorColor() {
        return this.errorColor;
    }
}
