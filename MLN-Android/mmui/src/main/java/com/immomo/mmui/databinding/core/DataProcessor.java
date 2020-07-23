/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.core;

import com.immomo.mls.fun.weight.IPriorityObserver;
import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.databinding.DataBinding;
import com.immomo.mmui.databinding.DataBindingEngine;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.interfaces.IGetSet;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.ObserverUtils;
import com.immomo.mmui.databinding.utils.DataBindUtils;
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
     * @param iPropertyCallback
     */
    public void watch(Globals globals, final Object observed, String tag, IPropertyCallback iPropertyCallback) {
        if(observed instanceof IObservable) {
            String[] tags = tag.split(Constants.SPOT_SPLIT);
            int finalNumIndex = getFinalNumFromTag(tags);
            if (finalNumIndex == -1) { //表示没有数字
                String newTag = new StringBuilder(Constants.GLOBAL).append(Constants.SPOT).append(tag).toString();
                if (DataBinding.isLog) {
                    LogUtil.d("watch:" + newTag);
                }
                addObserver(globals, observed, true, true, newTag, iPropertyCallback);
            } else {
                String beforeNumTag = getBeforeStr(tags, finalNumIndex);
                String newTag;
                if (beforeNumTag.length() != tag.length()) {
                    String afterNumTag = tag.substring(beforeNumTag.length() + 1);
                    newTag = new StringBuilder(beforeNumTag.replace(Constants.SPOT, "")).append(Constants.SPOT).append(afterNumTag).toString();
                } else {
                    newTag = beforeNumTag.replace(Constants.SPOT, "");
                }
                Object observer = get(observed, beforeNumTag);
                if (DataBinding.isLog) {
                    LogUtil.d("watch item:" + tag);
                }
                addObserver(globals, observer, true, true, newTag, iPropertyCallback);
            }
        }
    }


    /**
     * 获取数组中最后一个数字的index
     *
     * @param tags
     * @return -1表示返回无数字
     */
    private int getFinalNumFromTag(String[] tags) {
        int numIndex = -1;
        for (int i = tags.length - 1; i > 0; i--) {
            if (DataBindUtils.isNumber(tags[i])) {
                numIndex = i;
                break;
            }
        }
        return numIndex;
    }


    private String getBeforeStr(String[] tags, int index) {
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i <= index; i++) {
            stringBuilder.append(stringBuilder.length() == 0 ? "" : Constants.SPOT).append(tags[i]);
        }
        return stringBuilder.toString();
    }


    /**
     * 添加观察者
     * @param globals
     * @param observed
     * @param observedTag
     * @param iPropertyCallback
     */
    public void addObserver(Globals globals, final Object observed, boolean isSelfObserved,boolean isItemChanged,final String observedTag, IPropertyCallback iPropertyCallback) {
        if(observed instanceof IObservable) {
            globals.addOnDestroyListener(new Globals.OnDestroyListener() {
                @Override
                public void onDestroy(Globals g) {
                    ObserverUtils.removeObserver(g.hashCode(),observed,observedTag);
                }
            });
            ((IObservable)observed).watch(globals.hashCode(),observedTag,isSelfObserved,isItemChanged,iPropertyCallback);
        }
    }



    /**
     * 更新数据
     *
     * @param observed
     * @param propertyTag
     * @param propertyValue
     */
    public void update(Object observed, String propertyTag, Object propertyValue) {
        if (DataBinding.isLog) {
            LogUtil.e("update " + propertyTag);
        }
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
        if (DataBinding.isLog) {
            LogUtil.d("get " + propertyTag);
        }
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
     * @param observableId
     * @param observerTag
     */
    public void removeObserver(final Object observed, String observableId, String observerTag) {
        if (DataBinding.isLog) {
            LogUtil.d("removeObserver" + observerTag);
        }
        String[] fieldTags = observerTag.split(Constants.SPOT_SPLIT);
        Object templeObj = observed;
        if (templeObj instanceof IObservable) {
            ((IObservable) templeObj).removeObserverByCallBackId(observableId);
        }
        for (String fieldTag : fieldTags) {
            templeObj = DataBindingEngine.getInstance().getGetSetAdapter().get(observed, fieldTag);
            if (templeObj instanceof IObservable) {
                ((IObservable) templeObj).removeObserverByCallBackId(observableId);
            }
        }
    }

}