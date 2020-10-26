/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.databinding.core;

import com.immomo.mmui.databinding.bean.ObservableField;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.interfaces.IGetSet;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.DataBindUtils;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/7/24 下午6:42
 */
public class GetSetMapAdapter implements IGetSet {

    @Override
    public Object get(Object source, String key) {
        if (DataBindUtils.isEmpty(key) || source ==null) {
             return null;
        }
        Object temp = source;
        String[] fields = key.split(Constants.SPOT_SPLIT);
        for (int i = 0; i < fields.length; i++) {
            if(temp == null) {
                return null;
            }
            String fieldName = fields[i];
            if(temp instanceof ObservableField) {
                temp =  ((ObservableField) temp).getFields().get(fieldName);
            } else if(temp instanceof ObservableMap) {
                temp = ((ObservableMap)temp).get(fieldName);
            } else if(temp instanceof ObservableList) {
                temp = ((ObservableList)temp).get(Integer.parseInt(fieldName)-1);
            }
        }
        return temp;
    }


    /**
     * update 时调用,若key值中间取的值为null且不为list时创建
     * @param source
     * @param key
     * @param value
     */
    @Override
    public void set(Object source, String key, Object value) {
        if(DataBindUtils.isEmpty(key) || source == null) {
            return;
        }

        Object temp = source;
        String[] fields = key.split(Constants.SPOT_SPLIT);
        for (int i = 0; i < fields.length; i++) {
            if(temp == null) {
                return;
            }

            String fieldName = fields[i];
            if(temp instanceof ObservableField) {
                ObservableField observableField = (ObservableField) temp;

                if(i == fields.length -1) {
                    observableField.getFields().putInLua(fieldName,value);
                } else {
                    temp =  observableField.getFields().get(fieldName);
                    if(temp == null && !DataBindUtils.isNumber(fields[i+1])) {
                        temp = new ObservableMap<>();
                        observableField.getFields().putInLua(fieldName,temp);
                    }
                }
            } else if(temp instanceof ObservableMap) {
                ObservableMap observableMap = (ObservableMap) temp;

                if(i == fields.length -1) {
                    observableMap.putInLua(fieldName,value);
                } else {
                    temp = ((ObservableMap)temp).get(fieldName);
                    if(temp == null && !DataBindUtils.isNumber(fields[i+1])) {
                        temp = new ObservableMap<>();
                        observableMap.putInLua(fieldName,temp);
                    }
                }

            } else if(temp instanceof ObservableList) {
                ObservableList observableList = (ObservableList)temp;

                if(i == fields.length -1) {
                    observableList.setInLua(Integer.parseInt(fieldName)-1, value);
                } else {
                    temp = (observableList).get(Integer.parseInt(fieldName)-1);
                    if(temp == null && !DataBindUtils.isNumber(fields[i+1])) {// 如果a.b.c
                        temp = new ObservableMap<>();
                        observableList.setInLua(Integer.parseInt(fieldName)-1,temp);
                    }
                }
            }
        }
    }

}
