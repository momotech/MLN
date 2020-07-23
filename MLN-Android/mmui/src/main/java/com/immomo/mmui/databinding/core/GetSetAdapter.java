/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.core;

import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.databinding.annotation.IntColor;
import com.immomo.mmui.databinding.bean.MMUIColor;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.interfaces.IGetSet;
import com.immomo.mmui.databinding.utils.DataBindUtils;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-06-01 15:34
 */
public class GetSetAdapter implements IGetSet {

    @Override
    public Object get(Object source, String key) {
        if (!DataBindUtils.isEmpty(key) && source !=null) {
            Object temp = source;
            String[] fields = key.split("\\.");
            for (int i = 0; i < fields.length; i++) {
                try {
                    if(temp == null) {
                        return null;
                    }
                    String fieldName = fields[i];
                    if (i == fields.length - 1) {
                        if(temp instanceof ObservableMap) {
                            return ((ObservableMap)temp).get(fieldName);
                        } else if(temp instanceof ObservableList) {
                            return  ((ObservableList)temp).get(Integer.parseInt(fieldName)-1);
                        }else {
                            Class cls = temp.getClass();
                            Method getMethod = cls.getDeclaredMethod("get" + DataBindUtils.captureStr(fieldName));
                            if(isHaveColorInt(temp,fieldName)) {
                                return new MMUIColor((int)getMethod.invoke(temp));
                            }
                            return getMethod.invoke(temp);
                        }
                    }
                    if(temp instanceof ObservableMap) {
                        temp = ((ObservableMap)temp).get(fieldName);
                    } else if(temp instanceof ObservableList) {
                        temp = ((ObservableList)temp).get(Integer.parseInt(fieldName)-1);
                    } else {
                        Class clazz = temp.getClass();
                        Field field = clazz.getDeclaredField(fieldName);
                        field.setAccessible(true);
                        if (field.get(temp) == null) {
                            String fieldType = field.getGenericType().toString();
                            field.set(temp, Class.forName(fieldType).newInstance());
                        }
                        temp = field.get(temp);
                    }

                } catch (IllegalAccessException | NoSuchFieldException | NoSuchMethodException | InvocationTargetException | ClassNotFoundException | InstantiationException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    @Override
    public void set(Object source, String key, Object value) {
        if (!DataBindUtils.isEmpty(key)) {
            Object temp = source;
            String[] fields = key.split("\\.");
            for (int i = 0; i < fields.length; i++) {
                if(temp == null) {
                    return;
                }
                try {
                    String fieldName = fields[i];
                    if (i == fields.length - 1) { //最后一个执行set方法
                        if(temp instanceof ObservableMap) {
                            ((ObservableMap)temp).put(fieldName,value);
                        } else if(temp instanceof ObservableList) {
                            ((ObservableList)temp).set(Integer.parseInt(fieldName)-1,value);
                        }else {
                            Class cls = temp.getClass();
                            Field field = cls.getDeclaredField(fieldName);
                            Method setMethod = cls.getDeclaredMethod("set" + DataBindUtils.captureStr(fieldName), field.getType());
                            setMethod.invoke(temp, value);
                        }
                        break;
                    }
                    if(temp instanceof ObservableMap) {
                        temp = ((ObservableMap)temp).get(fieldName);
                    } else if(temp instanceof ObservableList) {
                        Object model = ((ObservableList)temp).get(Integer.parseInt(fieldName)-1);
                        temp = model;
                    } else {
                        Class clazz = temp.getClass();
                        Field field = clazz.getDeclaredField(fieldName);
                        field.setAccessible(true);
                        temp = field.get(temp);
                    }
                } catch (IllegalAccessException  | NoSuchFieldException | NoSuchMethodException | InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }
    }



    /**
     * 方法上有注解
     * @param temp
     * @param fieldName
     *
     * @return
     */
    private static boolean isHaveColorInt(Object temp, String fieldName) {
        Class clazz = temp.getClass();
        Field field;
        try {
            field = clazz.getDeclaredField(fieldName);
            field.setAccessible(true);
            IntColor colorInt = field.getAnnotation(IntColor.class);
            if(colorInt !=null) {
                return true;
            }
        } catch (NoSuchFieldException e) {
            LogUtil.e(e);
        }
        return false;
    }
}