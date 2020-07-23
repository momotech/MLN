/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.utils;

import android.text.TextUtils;

import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObserverWrap;
import com.immomo.mmui.databinding.DataBindingEngine;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;

import java.util.Iterator;
import java.util.List;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-26 20:42
 */
public class ObserverUtils {
    /**
     * 被观察者添加观察者(供ObservableField，ObservableMap调用)
     *
     * @param observed
     * @param observerId        Global的hashCode
     * @param wholeTag          整个tag
     * @param isItemChange      如是list和map,内部增删改查是否通知观察者
     * @param iPropertyCallback 改变回调
     */
    public static void subscribe(Object observed, int observerId, String wholeTag, boolean isSelfObserved, final boolean isItemChange, IPropertyCallback iPropertyCallback) {

        final String[] allBindProperties = wholeTag.split(Constants.SPOT_SPLIT);

        StringBuilder bindProperty = new StringBuilder(allBindProperties[0]);
        Object bindClass = observed;

        //第一层ObservableMap添加监听
        if (isSelfObserved) {
            final ObserverWrap observerWrap = ObserverWrap.obtain(observerId, wholeTag, allBindProperties[0], isItemChange, iPropertyCallback);
            if (observed instanceof IObservable) {
                ((IObservable) observed).addObserver(observerWrap);
            }
        }

        //存储中间节点的实例以及该实例之前已经绑定的tag
        for (int i = 1; i < (isItemChange ? allBindProperties.length : allBindProperties.length - 1); i++) {
            bindClass = DataBindingEngine.getInstance().getGetSetAdapter().get(bindClass, allBindProperties[i]);
            bindProperty.append(bindProperty.length() == 0 ? "" : Constants.SPOT).append(allBindProperties[i]);
            ObserverWrap restObservedProperty = ObserverWrap.obtain(observerId, wholeTag, bindProperty.toString(), isItemChange, iPropertyCallback);
            if (bindClass instanceof IObservable) {
                ((IObservable) bindClass).addObserver(restObservedProperty);
            }
        }

        //判断最后节点是否为二维数组,若为二维数组，循环二维数组进行绑定
        if (isItemChange && bindClass instanceof ObservableList && ((ObservableList) bindClass).size() > 0 && ((ObservableList) bindClass).get(0) instanceof ObservableList) {
            for (ObservableList list : (ObservableList<ObservableList>) bindClass) {
                ObserverWrap itemObserverWrap = ObserverWrap.obtain(observerId, wholeTag, wholeTag, isItemChange, iPropertyCallback);
                list.addObserver(itemObserverWrap);
            }
        }

    }


    /**
     * 属性改变执行回调
     *
     * @param observerWraps
     * @param fieldName
     * @param older
     * @param newer
     */
    public static void notifyPropertyChanged(List<ObserverWrap> observerWraps, String fieldName, Object older, Object newer) {
        if (observerWraps == null || observerWraps.size() == 0) {
            return;
        }

        for (ObserverWrap observerWrap : observerWraps) {
            IPropertyCallback iPropertyCallback = observerWrap.getPropertyListener();
            int observerId = observerWrap.getObserverId();
            String sourceTag = observerWrap.getSourceTag();
            boolean isItemChange = observerWrap.isItemChangeNotify();

            Object finalOlder;
            Object finalNewer;

            String changeProperty;
            if (TextUtils.isEmpty(observerWrap.getBindTag())) {
                changeProperty = fieldName;
            } else if (TextUtils.isEmpty(fieldName)) {
                changeProperty = observerWrap.getBindTag();
            } else {
                changeProperty = observerWrap.getBindTag() + Constants.SPOT + fieldName;
            }

            // 两边加点是排除 a.abc 与a.ab 的情况
            if ((observerWrap.getSourceTag()+ Constants.SPOT).startsWith(changeProperty + Constants.SPOT)) {
                if (observerWrap.getSourceTag().length() == changeProperty.length()) {

                    observerWrap.getPropertyListener().callBack(older, newer);
                    finalOlder = older;
                    finalNewer = newer;

                    if (finalOlder instanceof ObservableList) {
                        ((IObservable) finalOlder).removeObserver(iPropertyCallback);
                    }
                    if (finalNewer instanceof ObservableList) {

                        ((IObservable) finalNewer).addObserver(ObserverWrap.obtain(observerId, sourceTag, sourceTag, isItemChange, iPropertyCallback));
                    }


                } else {
                    String restBindProperty = observerWrap.getSourceTag().substring(changeProperty.length() + 1);
                    String[] restBindProperties = restBindProperty.split(Constants.SPOT_SPLIT);

                    StringBuilder bindProperty = new StringBuilder();

                    //移除旧值绑定的所有监听  并添加新值需要绑定的实例
                    Object oldClass = older;
                    Object newClass = newer;

                    for (int i = 0; i < (isItemChange ? restBindProperties.length : restBindProperties.length - 1); i++) {
                        oldClass = DataBindingEngine.getInstance().getGetSetAdapter().get(oldClass, restBindProperties[i]);
                        newClass = DataBindingEngine.getInstance().getGetSetAdapter().get(newClass, restBindProperties[i]);

                        if (oldClass instanceof IObservable) {
                            ((IObservable) oldClass).removeObserver(iPropertyCallback);
                        }

                        if (newClass instanceof IObservable) {
                            bindProperty.append(bindProperty.length() == 0 ? "" : Constants.SPOT).append(restBindProperties[i]);
                            ObserverWrap restObservedProperty = ObserverWrap.obtain(observerId, sourceTag, bindProperty.toString(), isItemChange, iPropertyCallback);
                            ((IObservable) oldClass).addObserver(restObservedProperty);
                        }
                    }


                    //获取新值和旧值的改变
                    if (!isItemChange) {
                        Object olderValue = DataBindingEngine.getInstance().getGetSetAdapter().get(oldClass, restBindProperties[restBindProperties.length - 1]);
                        Object newerValue = DataBindingEngine.getInstance().getGetSetAdapter().get(newClass, restBindProperties[restBindProperties.length - 1]);
                        observerWrap.getPropertyListener().callBack(olderValue, newerValue);
                    } else {
                        observerWrap.getPropertyListener().callBack(oldClass, newClass);
                    }

                    finalOlder = oldClass;
                    finalNewer = newClass;

                }

                //判断最后节点是否为二维数组,若为二维数组，循环二维数组进行绑定
                if (isItemChange && finalOlder instanceof ObservableList && ((ObservableList) finalOlder).size() > 0 && ((ObservableList) finalOlder).get(0) instanceof ObservableList) {
                    for (ObservableList list : (ObservableList<ObservableList>) finalOlder) {
                        list.removeObserver(iPropertyCallback);
                    }
                }

                if (isItemChange && finalNewer instanceof ObservableList && ((ObservableList) finalNewer).size() > 0 && ((ObservableList) finalNewer).get(0) instanceof ObservableList) {
                    for (ObservableList list : (ObservableList<ObservableList>) finalNewer) {
                        ObserverWrap itemObserverWrap = ObserverWrap.obtain(observerId, sourceTag, sourceTag, isItemChange, iPropertyCallback);
                        list.addObserver(itemObserverWrap);
                    }
                }
            }

        }

    }


    /**
     * 移除观察者
     *
     * @param observerWraps
     * @param observableId
     */
    public static void removeObserver(List<ObserverWrap> observerWraps, int observableId) {
        if (observerWraps == null) {
            return;
        }
        Iterator<ObserverWrap> iterator = observerWraps.iterator();
        while (iterator.hasNext()) {
            ObserverWrap observerWrap = iterator.next();
            if (observerWrap.getObserverId() == observableId) {
                iterator.remove();
            }
        }
    }


    /**
     * 添加观察者
     *
     * @param observerWraps
     * @param observerWrap
     */
    public static void addObserver(List<ObserverWrap> observerWraps, ObserverWrap observerWrap) {
        observerWraps.add(observerWrap);

    }


    /**
     * 移除观察者
     *
     * @param observerWraps
     * @param iPropertyCallback 观察者回调
     */
    public static void removeObserver(List<ObserverWrap> observerWraps, IPropertyCallback iPropertyCallback) {
        if (observerWraps == null) {
            return;
        }
        Iterator<ObserverWrap> iterator = observerWraps.iterator();
        while (iterator.hasNext()) {
            ObserverWrap observerWrap = iterator.next();
            if (observerWrap.getPropertyListener() == iPropertyCallback) {
                iterator.remove();//删除操作
            }
        }
    }


    /**
     * 移除观察者
     *
     * @param observerId
     * @param observed
     * @param observedTag
     */
    public static void removeObserver(int observerId, final Object observed, final String observedTag) {
        if (!observedTag.contains(Constants.SPOT)) {
            if (observed instanceof IObservable) {
                ((IObservable) observed).removeObserver(observerId);
            }
        } else {
            String fieldTag = observedTag.substring(observedTag.indexOf(Constants.SPOT) + 1);
            final String[] fields = fieldTag.split(Constants.SPOT_SPLIT);
            Object templeObserver = observed;
            for (String field : fields) {
                if (templeObserver instanceof IObservable) {
                    ((IObservable) templeObserver).removeObserver(observerId);
                }
                templeObserver = DataBindingEngine.getInstance().getGetSetAdapter().get(templeObserver, field);
            }
        }
    }


    /**
     * @param observerWraps
     * @param observedTag
     */
    public static void removeObserver(List<ObserverWrap> observerWraps, String observedTag) {
        if (observerWraps == null) {
            return;
        }
        Iterator<ObserverWrap> iterator = observerWraps.iterator();
        while (iterator.hasNext()) {
            ObserverWrap observerWrap = iterator.next();
            String sourceTag = observerWrap.getSourceTag();
            if (sourceTag.equals(observedTag)) {
                iterator.remove();//删除操作
            }
        }
    }


    /**
     * 根据CallbackId移除观察者
     * @param observerWraps
     * @param callBackId
     */
    public static void removeObserverByCallBackId(List<ObserverWrap> observerWraps, String callBackId) {
        if (observerWraps == null) {
            return;
        }
        Iterator<ObserverWrap> iterator = observerWraps.iterator();
        while (iterator.hasNext()) {
            ObserverWrap observerWrap = iterator.next();
            String callbackId = String.valueOf(observerWrap.getPropertyListener().hashCode());
            if (callbackId.equals(callBackId)) {
                iterator.remove();//删除操作
            }
        }
    }




}