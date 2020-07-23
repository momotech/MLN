/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;





import com.immomo.mmui.ud.UDView;

import java.util.HashMap;
import java.util.Map;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-28 12:22
 */
public class DataSource {

    /**
     * 数据源(key: tag, Object: 对应的数据源实例)
     */
    private ObservableMap<String, Object> keySource;

    /**
     * 与listView绑定的keys
     */
    private Map<String, UDView> listKeys;

    /**
     * key为watch添加的IPropertyCallback的hashCode
     */
    private Map<String,String> callBackKeys;


    public DataSource() {
        keySource = new ObservableMap<>();
        listKeys = new HashMap<>();
    }

    public ObservableMap<String, Object> getSource() {
        return keySource;
    }

    public void setSource(ObservableMap<String, Object> source) {
        this.keySource = source;
    }

    /**
     * 判断key中是否包含listKey
     * @param key
     * @return
     */
    public String getListKey(String key) {
        if(listKeys != null) {
            for(String listKey: listKeys.keySet()) {
                if(key.startsWith(listKey)) {
                    return listKey;
                }
            }
        }
        return null;
    }

    /**
     * 添加数据源
     * @param key
     * @param source
     */
    public void addDataSource(String key,Object source) {
        if(source == null) {
            keySource = new ObservableMap<>();
        }
        keySource.put(key,source);
    }


    /**
     * 添加listView数据源的key
     * @param listKey
     */
    public void addListKey(String listKey,UDView listView) {
        if(listKeys ==null) {
            listKeys = new HashMap<>();
        }
        listKeys.put(listKey,listView);
    }


    /**
     * 获取数据源
     * @param key
     * @return
     */
    public Object getData(String key) {
        return keySource.get(key);
    }


    /**
     * 获取listView数据
     * @param tag
     * @return
     */
    public UDView getListView(String tag) {
        return listKeys.get(tag);
    }

    /**
     * 获取观察者的tag
     * @param callBackId
     * @return
     */
    public String getObservableTag(String callBackId) {
        if(callBackKeys ==null) {
            return null;
        }
        return callBackKeys.get(callBackId);
    }

    /**
     * 添加watch的iPropertyCallback
     * @param callBackId
     * @param tag
     */
    public void addCallbackId(String callBackId, String tag) {
        if(callBackKeys ==null) {
            callBackKeys = new HashMap<>();
        }
        callBackKeys.put(callBackId,tag);
    }

}