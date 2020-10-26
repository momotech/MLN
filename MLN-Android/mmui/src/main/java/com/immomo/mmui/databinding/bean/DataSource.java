/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.bean;





import com.immomo.mmui.ud.UDView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-28 12:22
 */
public class DataSource {
    private static final int CAPACITY = 20;

    /**
     * 数据源(key: tag, Object: 对应的数据源实例)
     */
    private ObservableMap<String, Object> keySource;

    /**
     * 与listView绑定的keys
     */
    private Map<String, UDView> listViews;


    /**
     * listView已经绑定的Cell的属性
     */
    private Map<String,List<BindCell>> bindCellKvs;

    /**
     * key为watch添加的IPropertyCallback的hashCode
     */
    private Map<String,CallBackWrap> callBackKeys;



    public DataSource() {
        keySource = new ObservableMap<>();
        listViews = new HashMap<>();
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
        if(listViews != null) {
            List<String> keyList = new ArrayList<>(listViews.keySet());
            Collections.sort(keyList,new SortByLengthComparator());
            for(String listKey: keyList) {
                if(key.startsWith(listKey) ) {
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
        if(listViews ==null) {
            listViews = new HashMap<>();
        }
        listViews.put(listKey,listView);
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
        return listViews.get(tag);
    }

    /**
     * 获取观察者的tag
     * @param callBackId
     * @return
     */
    public CallBackWrap getObservableTag(String callBackId) {
        if(callBackKeys ==null) {
            return null;
        }
        return callBackKeys.remove(callBackId);
    }

    /**
     * 添加watch的iPropertyCallback
     * @param callBackId
     * @param callBackWrap
     */
    public void addCallbackId(String callBackId, CallBackWrap callBackWrap) {
        if(callBackKeys ==null) {
            callBackKeys = new HashMap<>(CAPACITY);
        }
        callBackKeys.put(callBackId,callBackWrap);
    }


    /**
     * 添加bindCell
     * @param key
     * @param bindCell
     */
    public void addBindCell(String key,BindCell bindCell) {
        if(bindCellKvs == null) {
            bindCellKvs = new HashMap<>();
        }

        List bindCells = bindCellKvs.get(key);

        if(bindCells == null) {
            bindCells = new ArrayList<>();
            bindCells.add(bindCell);
            bindCellKvs.put(key,bindCells);
        }

        if(!bindCells.contains(bindCell)) {
            bindCells.add(bindCell);
        }
    }


    /**
     * 是否已经绑定过Cell
     * @param key
     * @param bindCell
     * @return
     */
    public boolean isContainBindCell(String key,BindCell bindCell) {
        if(bindCellKvs ==null) {
            return false;
        }

        List bindCells = bindCellKvs.get(key);
        if(bindCells == null) {
            return false;
        }
        if(!bindCells.contains(bindCell)) {
            return false;
        }
        return true;
    }


    public static  class SortByLengthComparator implements Comparator<String> {

        @Override
        public int compare(String var1, String var2) {
            if (var1.length() > var2.length()) {
                return -1;
            } else if (var1.length() == var2.length()) {
                return 0;
            } else {
                return 1;
            }
        }
    }

}