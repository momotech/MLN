/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding;

import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.Globals.OnDestroyListener;

import java.util.List;
import java.util.Map;

/**
 * Description:入口
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-02-21 16:23
 */
public class DataBinding {
    public static final String TAG = "DataBinding";

    public static final  boolean isLog =  false;

    /**
     * 绑定观察者
     *
     * @param target
     * @param observed
     * @param tag
     */
    public static void bind(Globals target, Object observed, String tag) {
        target.addOnDestroyListener(new OnDestroyListener() {
            @Override
            public void onDestroy(Globals g) {
                unbindAll(g);
            }
        });
        DataBindingEngine.getInstance().bindData(target, tag, observed);
    }


    /**
     * 解绑 target 下的所有观察者
     *
     * @param target @KvoWatch 修饰观察者所在实例
     */
    public static void unbindAll(Globals target) {
        DataBindingEngine.getInstance().unbind(target);
    }


    /**
     * 通过key值，设置数据监听
     *
     * @param key
     * @param key
     * @param iPropertyCallback
     */
    public static String watchValue(Globals target, String key, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        return DataBindingEngine.getInstance().watchValue(target, key, iWatchKeyFilter,iPropertyCallback);
    }


    /**
     *  通过key值，设置数据行为监听（只有在完整的key被赋值时才会触发回调）
     * @param target
     * @param key
     * @param iPropertyCallback
     * @return
     */
    public static String watch(Globals target, String key, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        return DataBindingEngine.getInstance().watch(target,key,iWatchKeyFilter,iPropertyCallback);
    }


    /**
     * 数组插入数据
     * @param target
     * @param key
     * @param index
     * @param object
     */
    public static void insert(Globals target, String key, int index,Object object) {
        DataBindingEngine.getInstance().insert(target,key,index,object);
    }


    /**
     * 数组移除数据
     * @param target
     * @param key
     * @param index
     */
    public static void remove(Globals target,String key,int index) {
        DataBindingEngine.getInstance().remove(target,key,index);
    }


    /**
     * 通过key值更改值
     * @param target
     * @param key
     * @param value
     */
    public static void update(Globals target, String key, Object value) {
        DataBindingEngine.getInstance().update(target, key, value);
    }

    /**
     * 通过key，获取值
     *
     * @param target
     * @param key
     * @return
     */
    public static Object get(Globals target, String key) {
        return DataBindingEngine.getInstance().get(target, key);
    }


    /**
     * 通过key绑定列表View
     *
     * @param target
     * @param key
     * @param view
     */
    public static void bindListView(final Globals target, String key, UDView view) {
        target.addOnDestroyListener(new OnDestroyListener() {
            @Override
            public void onDestroy(Globals g) {
                DataBindingEngine.getInstance().unbind(target);
            }
        });
        DataBindingEngine.getInstance().bindListView(target, key, view);
    }



    /**
     * 获取Section数量
     *
     * @param target
     * @param key
     * @return
     */
    public static int getSectionCount(Globals target, String key) {
        return DataBindingEngine.getInstance().getSectionCount(target, key);
    }


    /**
     * 获取Row数量
     *
     * @param target
     * @param key
     * @param section
     * @return
     */
    public static int getRowCount(Globals target, String key, int section) {
        return DataBindingEngine.getInstance().getRowCount(target, key, section);
    }


    /**
     * 获取数组的大小
     * @param target
     * @param key
     * @return
     */
    public static int arraySize(Globals target, String key) {
        return DataBindingEngine.getInstance().arraySize(target, key);
    }


    /**
     * cell 绑定
     *
     * @param target
     * @param key
     * @param section
     * @param row
     * @param bindProperties
     */
    public static void bindCell(Globals target, String key, int section, int row,List<String> bindProperties) {
        DataBindingEngine.getInstance().bindCell(target,key,section,row,bindProperties);
    }



    /**
     * mock 基本数据
     * @param target
     * @param key
     * @param map
     */
    public static void mock(Globals target, String key, ObservableMap<String, Object> map){
        target.addOnDestroyListener(new OnDestroyListener() {
            @Override
            public void onDestroy(Globals g) {
                unbindAll(g);
            }
        });
        DataBindingEngine.getInstance().mock(target,key,map);
    }


    /**
     * mock 列表数据
     * @param target
     * @param tag
     * @param list
     */
    public static void mockArray(final Globals target, String tag, ObservableList list, final Map map) {
        DataBindingEngine.getInstance().mockArray(target,  tag,  list,  map);
    }


    public static void removeObserver(final Globals target, String tag) {
        DataBindingEngine.getInstance().removeObservableId(target,tag);
    }



}