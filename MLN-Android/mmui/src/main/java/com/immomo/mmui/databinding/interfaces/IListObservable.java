package com.immomo.mmui.databinding.interfaces;

import android.app.Activity;
import android.app.Fragment;

import com.immomo.mmui.databinding.bean.ObserverListWrap;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/6 下午10:34
 */
public interface IListObservable<T> extends IObservable {
    /**
     * 根据属性变量名注册观察者
     *
     * @param activity 在activity中watch
     */
    IListAssembler watch(Activity activity);


    /**
     * 根据属性变量名注册观察者
     *
     * @param fragment 在fragment中watch
     */
    IListAssembler watch(Fragment fragment);


    /**
     * 添加list内部改变监听
     *
     * @param observerListWrap
     */
    void addListChangedCallback(ObserverListWrap observerListWrap);


    /**
     * 根据iListChangedCallback移除list中监听
     *
     * @param iListChangedCallback
     */
    void removeListChangeCallback(IListChangedCallback iListChangedCallback);


    /**
     * 根据observerId移除list中监听
     *
     * @param observerId
     */
    void removeListChangeCallback(int observerId);

    /**
     * 在lua层调用
     * 对应于{@link com.immomo.mmui.databinding.bean.ObservableList#add(Object)}
     * @param object
     * @return
     */
    boolean addInLua(T object);


    /**
     * 在lua层调用
     * 对应于{@link com.immomo.mmui.databinding.bean.ObservableList#add(int, Object)}
     *
     * @param index
     * @param object
     */
    void addInLua(int index, T object);


    /**
     * 在lua层调用
     * 对应于{@link com.immomo.mmui.databinding.bean.ObservableList#remove(int)}
     * @param index
     * @return
     */
    T removeInLua(int index);


    /**
     * 在lua层调用
     * 对应于{@link com.immomo.mmui.databinding.bean.ObservableList#set(int, Object)}
     * @param index
     * @param object
     * @return
     */
    T setInLua(int index, T object);


}
