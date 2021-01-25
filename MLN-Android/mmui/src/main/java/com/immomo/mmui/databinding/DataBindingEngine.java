/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding;


import android.text.TextUtils;

import com.immomo.mmui.databinding.bean.CallBackWrap;
import com.immomo.mmui.databinding.bean.DataSource;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.core.DataListProcessor;
import com.immomo.mmui.databinding.core.DataProcessor;
import com.immomo.mmui.databinding.core.GetSetMapAdapter;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.interfaces.IGetSet;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.DataBindUtils;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-20 18:25
 */
public class DataBindingEngine {

    private static volatile DataBindingEngine instance;
    //存储基本数据
    private Map<Globals, DataSource> gKeyValueMaps = new HashMap<>();


    private DataProcessor dataProcessor;
    private IGetSet iGetSet;
    private DataListProcessor dataListProcessor;


    private DataBindingEngine() {
//        iGetSet = new GetSetReflexAdapter();
        iGetSet = new GetSetMapAdapter();
        dataProcessor = new DataProcessor(iGetSet);
        dataListProcessor = new DataListProcessor(dataProcessor);
    }

    public DataProcessor getDataProcessor() {
        return dataProcessor;
    }

    public static DataBindingEngine getInstance() {
        if (instance == null) {
            synchronized (DataBindingEngine.class) {
                if (instance == null) {
                    instance = new DataBindingEngine();
                }
            }
        }
        return instance;
    }

    public IGetSet getGetSetAdapter() {
        return iGetSet;
    }

    /**
     * 绑定基本数据（原生调用）
     *
     * @param globals
     * @param key
     * @param value
     */
    public void bindData(Globals globals, String key, Object value) {
        DataSource dataSource;
        if (gKeyValueMaps.containsKey(globals)) {
            dataSource = gKeyValueMaps.get(globals);
        } else {
            dataSource = new DataSource();
            gKeyValueMaps.put(globals, dataSource);
        }

        dataSource.addDataSource(key, value);
    }

    /**
     * 绑定属性
     *
     * @param globals
     * @param tag
     * @param iPropertyCallback
     */
    public String watchValue(Globals globals, String tag, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        String callBackId = String.valueOf(iPropertyCallback.hashCode());
        if (TextUtils.isEmpty(tag)) {
            return callBackId;
        }

        DataSource dataSource = gKeyValueMaps.get(globals);
        if (dataSource != null && dataSource.getSource() != null) {
            CallBackWrap callBackWrap = dataProcessor.watchValue(globals, dataSource.getSource(), getLastTag(dataSource,tag),iWatchKeyFilter,iPropertyCallback);
            if (callBackWrap != null) {
                dataSource.addCallbackId(callBackId, callBackWrap);
            }
        } else {
            throw new RuntimeException("before watch you must bind data");
        }

        return callBackId;
    }


    /**
     * 绑定行为属性
     *
     * @param globals
     * @param tag
     * @param iPropertyCallback
     * @return
     */
    public String watch(Globals globals, String tag, IWatchKeyFilter iWatchKeyFilter, IPropertyCallback iPropertyCallback) {
        String callBackId = String.valueOf(iPropertyCallback.hashCode());
        if (TextUtils.isEmpty(tag)) {
            return callBackId;
        }

        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource != null && dataSource.getSource() != null) {
            CallBackWrap callBackWrap = dataProcessor.watch(globals, dataSource.getSource(), getLastTag(dataSource,tag), iWatchKeyFilter,iPropertyCallback);
            if (callBackWrap != null) {
                dataSource.addCallbackId(callBackId, callBackWrap);
            }
        } else {
            throw new RuntimeException("before watchAction you must bind data");
        }

        return callBackId;
    }


    /**
     * 列表插入数据
     *
     * @param globals
     * @param tag
     * @param index
     * @param object
     */
    public void insert(Globals globals, String tag, int index, Object object) {
        if (TextUtils.isEmpty(tag)) {
            return;
        }
        Object source = getSource(globals);
        if (source != null) {
            dataListProcessor.insert(source, tag, index, object);
        } else {
            throw new RuntimeException("before insert you must bind data");
        }
    }


    /**
     * 移除数据
     *
     * @param globals
     * @param tag
     * @param index
     */
    public void remove(Globals globals, String tag, int index) {
        if (TextUtils.isEmpty(tag)) {
            return;
        }
        Object source = getSource(globals);

        if (source != null) {
            dataListProcessor.remove(source, tag, index);
        } else {
            throw new RuntimeException("before remove you must bind data");
        }

    }


    /**
     * 获取数据源（key，value）
     *
     * @param globals
     * @return
     */
    private Object getSource(Globals globals) {
        DataSource source = gKeyValueMaps.get(globals);

        if (source == null) {
            return null;
        }

        return source.getSource();
    }


    /**
     * 更新数据
     *
     * @param globals
     * @param tag
     * @param propertyValue
     */
    public void update(Globals globals, String tag, Object propertyValue) {
        if (TextUtils.isEmpty(tag)) {
            return;
        }

        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource != null && dataSource.getSource() != null) {
            dataProcessor.update(dataSource.getSource(), getLastTag(dataSource, tag), propertyValue);
        } else {
            throw new RuntimeException("before update you must bind data");
        }

    }


    /**
     * 获取分析之后的tag
     *
     * @param dataSource
     * @param tag
     * @return
     */
    public String getLastTag(DataSource dataSource, String tag) {
        String listTag = dataSource.getListKey(tag);
        if (!TextUtils.isEmpty(listTag)) { // tag中 包含list
            if (listTag.equals(tag)) {
                return tag;
            }
            String restTag = tag.substring(listTag.length() + 1);
            String[] restTags = restTag.split(Constants.SPOT_SPLIT);
            ObservableList observableList = (ObservableList) dataProcessor.get(dataSource.getSource(), listTag);
            if (!DataBindUtils.isDoubleList(observableList) && restTags.length > 1 && DataBindUtils.isNumber(restTags[1])) { // 如果是一维数组，且第二个是数字，去掉第一位
                return listTag + Constants.SPOT + restTag.substring(restTag.indexOf(Constants.SPOT) + 1);
            } else {
                return tag;
            }
        } else {
            return tag;
        }
    }


    /**
     * 获取数据
     *
     * @param globals
     * @param tag
     * @return
     */
    public Object get(Globals globals, String tag) {
        if (TextUtils.isEmpty(tag)) {
            return null;
        }

        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource != null && dataSource.getSource() != null) {
            return dataProcessor.get(dataSource.getSource(), getLastTag(dataSource, tag));
        } else {
            return null;
        }

    }


    /**
     * mock 基本数据
     *
     * @param globals
     * @param tag
     * @param observableMap
     */
    public void mock(Globals globals, String tag, ObservableMap<String, Object> observableMap) {
        bindData(globals, tag, observableMap);
    }


    /**
     * 注销
     *
     * @param globals
     */
    public void unbind(Globals globals) {
        gKeyValueMaps.remove(globals);
    }


    /**
     * 绑定ListView控件
     *
     * @param globals
     * @param tag
     * @param udView
     */
    public void bindListView(final Globals globals, final String tag, final UDView udView) {
        if (TextUtils.isEmpty(tag)) {
            return;
        }

        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null || dataSource.getSource() == null) {
            throw new RuntimeException("before bindListView you must bind data");
        }

        dataSource.addListKey(getLastTag(dataSource,tag), udView);

        dataListProcessor.bindListView(globals, dataSource.getSource(), getLastTag(dataSource,tag), udView);
    }


    /**
     * 获取section的数量
     *
     * @param globals
     * @param tag
     * @return
     */
    public int getSectionCount(Globals globals, String tag) {
        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null || dataSource.getSource() == null) {
            throw new RuntimeException("before getSectionCount you must bind data");
        }

        return dataListProcessor.getSectionCount(dataSource.getSource(), getLastTag(dataSource,tag));
    }


    /**
     * 获取row的数量
     *
     * @param globals
     * @param tag
     * @param section
     * @return
     */
    public int getRowCount(Globals globals, String tag, int section) {
        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null || dataSource.getSource() == null) {
            throw new RuntimeException("before getRowCount you must bind data");
        }

        return dataListProcessor.getRowCount(dataSource.getSource(), getLastTag(dataSource,tag), section);
    }


    /**
     * 获取数组的size
     *
     * @param globals
     * @param tag
     * @return
     */
    public int arraySize(Globals globals, String tag) {
        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null || dataSource.getSource() == null) {
            throw new RuntimeException("before arraySize you must bind data");
        }
        return dataProcessor.arraySize(dataSource.getSource(), getLastTag(dataSource, tag));
    }


    /**
     * mock 数据
     *
     * @param globals
     * @param propertyTag
     * @param list
     * @param map
     */
    public void mockArray(Globals globals, String propertyTag, ObservableList list, final Map map) {

    }


    /**
     * 列表绑定cell
     *
     * @param globals
     * @param tag
     * @param section
     * @param row
     * @param bindProperties
     */
    public void bindCell(Globals globals, String tag, int section, int row, List<String> bindProperties) {
        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null || dataSource.getSource() == null) {
            throw new RuntimeException("before bindCell you must bind data");
        }

        dataListProcessor.bindCell(globals, dataSource, getLastTag(dataSource,tag), section, row, bindProperties);
    }


    public void removeObservableId(Globals globals, String callBackId) {
        if (TextUtils.isEmpty(callBackId)) {
            return;
        }
        DataSource dataSource = gKeyValueMaps.get(globals);

        if (dataSource == null) {
            return;
        }

        CallBackWrap callBackWrap = dataSource.getObservableTag(callBackId);

        if (callBackWrap != null) {
            dataProcessor.removeObserver(callBackWrap.getObserver(), callBackId, callBackWrap.getObservableTag());
        }
    }

}