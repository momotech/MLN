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

    @Override
    public void set(Object source, String key, Object value) {
        if(DataBindUtils.isEmpty(key) || source == null) {
            return;
        }
        Object target = get(source,key.substring(0,key.lastIndexOf(Constants.SPOT)));
        String fieldName = key.substring(key.lastIndexOf(Constants.SPOT) +1);
        if(target instanceof ObservableField) {
            ((ObservableField)target).getFields().put(fieldName,value);
        } else if(target instanceof ObservableMap) {
            ((ObservableMap)target).put(fieldName,value);
        } else if(target instanceof ObservableList) {
            ((ObservableList)target).set(Integer.parseInt(fieldName)-1, value);
        }
    }

}
