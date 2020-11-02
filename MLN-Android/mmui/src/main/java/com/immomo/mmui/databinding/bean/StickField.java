/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.bean;

import com.immomo.mmui.databinding.annotation.WatchContext;

import java.util.Objects;

/**
 * Description:粘性实体类
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/10/12 上午10:20
 */
public class StickField {
    private int watchContext;
    private String field;

    public static StickField obtain(@WatchContext int watchContext,String field) {
        StickField stickField = new StickField();
        stickField.watchContext = watchContext;
        stickField.field = field;
        return stickField;
    }

    public int getWatchContext() {
        return watchContext;
    }

    public void setWatchContext(int watchContext) {
        this.watchContext = watchContext;
    }

    public String getField() {
        return field;
    }

    public void setField(String field) {
        this.field = field;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StickField that = (StickField) o;
        return Objects.equals(field, that.field);
    }

    @Override
    public int hashCode() {
        return Objects.hash(field);
    }
}
