/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.core;

import android.util.Log;

import com.immomo.mmui.databinding.DataBinding;
import com.immomo.mmui.databinding.DataBindingEngine;
import com.immomo.mmui.databinding.bean.CallBackWrap;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.filter.WatchActionFilter;
import com.immomo.mmui.databinding.interfaces.IGetSet;
import com.immomo.mmui.databinding.interfaces.IMapAssembler;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.Constants;

import org.luaj.vm2.Globals;


/**
 * Description:基本数据处理处理器
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-20 18:12
 */
public class DataProcessor {

    private IGetSet mGetSet;

    public DataProcessor(IGetSet iGetSet) {
        mGetSet = iGetSet;
    }


    /**
     * 监控被观察者
     * * 如tag为'userData.source.1.person.name' -- 监听source中第一个元素的person对象的name属性，只有name或person发生变化的时候才会收到通知.
     * * tag为'userData.page.title'-- 监听普通对象，当title、page、userData发生赋值操作时都能收到通知
     * * tag为'userData.source' 监听一个Array，当source发生赋值操作，或者source发生Add/Remove/Replace操作时都能收到通知，如果source是个二维数组，当对内层数组做Add/Remove/Replace时也能收到通知.
     * @param globals
     * @param observed
     * @param tag
     * @param iWatchKeyFilter
     * @param iPropertyCallback
     */
    public CallBackWrap watchValue(Globals globals, final Object observed, String tag, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        if(observed instanceof IObservable) {
            final String observerTag = Constants.GLOBAL + Constants.SPOT + tag;
            IMapAssembler iMapAssembler = ((IObservable)observed).watchAll(globals,observerTag).filterItemChange(true).filter(iWatchKeyFilter).callback(iPropertyCallback);
            return CallBackWrap.obtain(iMapAssembler.getObserved(),iMapAssembler.getObservedTag());
        }
        return null;
    }


    /**
     * 监控被观察者的行为，
     * 如tag为'userData.source.1.person.name' --  只有之后节点的person执行setName时触发
     * @param globals
     * @param observed
     * @param tag
     * @param iPropertyCallback
     * @return
     */
    public CallBackWrap watch(Globals globals, final Object observed, String tag, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        if(observed instanceof IObservable) {
            final String observerTag = Constants.GLOBAL + Constants.SPOT + tag;
            IMapAssembler iMapAssembler = ((IObservable)observed).watchAll(globals,observerTag)
                    .filterItemChange(false)
                    .filterAction(new WatchActionFilter(observerTag))
                    .filter(iWatchKeyFilter)
                    .callback(iPropertyCallback);
            return CallBackWrap.obtain(iMapAssembler.getObserved(),iMapAssembler.getObservedTag());
        }
        return null;
    }




    /**
     * 更新数据
     *
     * @param observed
     * @param propertyTag
     * @param propertyValue
     */
    public void update(Object observed, String propertyTag, Object propertyValue) {
        mGetSet.set(observed, propertyTag, propertyValue);
    }


    /**
     * 获取数据
     *
     * @param observed
     * @param propertyTag
     * @return
     */
    public Object get(Object observed, String propertyTag) {
        return mGetSet.get(observed, propertyTag);
    }


    /**
     * 获取数组的大小
     * @param observed
     * @param tag
     * @return
     */
    public int arraySize(Object observed, String tag) {
        Object targetList = get(observed,tag);
        if(targetList == null) {
            return 0;
        }
        if(targetList instanceof ObservableList) {
            return ((ObservableList)targetList).size();
        } else if(targetList instanceof ObservableMap) {
            return ((ObservableMap) targetList).size();
        }else{
            throw new RuntimeException(tag + "must is list");
        }
    }


    /**
     * 移除观察者
     *
     * @param observed
     * @param callBackId
     * @param observerTag
     */
    public void removeObserver(final Object observed, String callBackId, String observerTag) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG, "removeObserver---" + observerTag);
        }
        String[] fieldTags = observerTag.split(Constants.SPOT_SPLIT);
        Object templeObj = observed;
        if (templeObj instanceof IObservable) {
            ((IObservable) templeObj).removeObserverByCallBackId(callBackId);
        }
        for (int i=1;i<fieldTags.length;i++) {
            templeObj = DataBindingEngine.getInstance().getGetSetAdapter().get(templeObj, fieldTags[i]);
            if (templeObj instanceof IObservable) {
                ((IObservable) templeObj).removeObserverByCallBackId(callBackId);
            }
        }
    }

}