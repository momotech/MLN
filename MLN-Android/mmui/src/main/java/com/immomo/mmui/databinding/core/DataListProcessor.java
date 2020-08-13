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
import com.immomo.mmui.databinding.bean.BindCell;
import com.immomo.mmui.databinding.bean.DataSource;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.interfaces.IListChangedCallback;
import com.immomo.mmui.databinding.interfaces.IObservable;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.DataBindUtils;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ud.recycler.UDBaseRecyclerAdapter;
import com.immomo.mmui.ud.recycler.UDRecyclerView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.List;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-06-01 15:59
 */
public class DataListProcessor {
    private DataProcessor mDataProcessor;


    public DataListProcessor(DataProcessor dataProcessor) {
        mDataProcessor = dataProcessor;
    }

    public void bindListView(final Globals globals, final Object source, final String tag, final UDView udView) {
        final String newTag = new StringBuilder(Constants.List).append(Constants.SPOT).append(tag).toString();


        //自身赋值监控
        mDataProcessor.addObserver(globals, source, true, false, newTag, new IPropertyCallback() {
            @Override
            public void callBack(Object old, Object news) {
                if (udView instanceof UDRecyclerView) {
                    LuaValue[] luaValues = ((UDRecyclerView) udView).adapter(new LuaValue[0]);
                    UDBaseRecyclerAdapter udBaseRecyclerAdapter = (UDBaseRecyclerAdapter) luaValues[0].toUserdata();
                    udBaseRecyclerAdapter.reload();
                    removeBindObserver(source,newTag,newTag);
                    bindListView(globals, source, tag, udView);
                }
            }
        });

        final ObservableList observableList = (ObservableList) mDataProcessor.get(source, tag);

        if(observableList == null){
            return;
        }

        if (DataBindUtils.isDoubleList(observableList)) {
            final ObservableList doubleList = (ObservableList<ObservableList>) observableList;
            final IListChangedCallback outsIListChangedCallback = new IListChangedCallback() {
                @Override
                public void notifyChange(int type, int start, int count) {
                    //刷新cell
                    if (udView instanceof UDRecyclerView) {
                        LuaValue[] luaValues = ((UDRecyclerView) udView).adapter(new LuaValue[0]);
                        UDBaseRecyclerAdapter udBaseRecyclerAdapter = (UDBaseRecyclerAdapter) luaValues[0].toUserdata();
                        switch (type) {
                            case ObservableList.CHANGED:
                                udBaseRecyclerAdapter.reloadAtSection(start, false);
                                break;
                            case ObservableList.INSERTED:
                            case ObservableList.REMOVED:
                                udBaseRecyclerAdapter.reload();
                                break;
                        }
                        doubleList.removeListChangeCallback(this);
                        bindListView(globals, source, tag, udView);
                    }
                }
            };

            //移除
            globals.addOnDestroyListener(new Globals.OnDestroyListener() {
                @Override
                public void onDestroy(Globals g) {
                    doubleList.removeListChangeCallback(outsIListChangedCallback);
                }
            });

            doubleList.addListChangedCallback(outsIListChangedCallback);
            for (int i = 0; i < doubleList.size(); i++) {
                final ObservableList singleObservable = (ObservableList) doubleList.get(i);
                final int sectionIndex = i;
                final IListChangedCallback interIListChangedCallback = new IListChangedCallback() {
                    @Override
                    public void notifyChange(int type, int start, int count) {
                        //刷新row
                        if (udView instanceof UDRecyclerView) {
                            LuaValue[] luaValues = ((UDRecyclerView) udView).adapter(new LuaValue[0]);
                            UDBaseRecyclerAdapter udBaseRecyclerAdapter = (UDBaseRecyclerAdapter) luaValues[0].toUserdata();
                            switch (type) {
                                case ObservableList.CHANGED:
                                    udBaseRecyclerAdapter.reloadAtRow(sectionIndex, start, false);
                                    break;
                                case ObservableList.INSERTED:
                                    udBaseRecyclerAdapter.insertCellsAtSection(sectionIndex, start, count);
                                    break;
                                case ObservableList.REMOVED:
                                    udBaseRecyclerAdapter.deleteCellsAtSection(sectionIndex, start, count);
                                    break;
                            }
                            singleObservable.removeListChangeCallback(this);
                            bindListView(globals, source, tag, udView);
                        }
                    }
                };

                //移除
                globals.addOnDestroyListener(new Globals.OnDestroyListener() {
                    @Override
                    public void onDestroy(Globals g) {
                        singleObservable.removeListChangeCallback(interIListChangedCallback);
                    }
                });

                singleObservable.addListChangedCallback(interIListChangedCallback);
            }
        } else {
            final IListChangedCallback outsIListChangedCallback = new IListChangedCallback() {
                @Override
                public void notifyChange(int type, int start, int count) {
                    //刷新cell
                    if (udView instanceof UDRecyclerView) {
                        LuaValue[] luaValues = ((UDRecyclerView) udView).adapter(new LuaValue[0]);
                        UDBaseRecyclerAdapter udBaseRecyclerAdapter = (UDBaseRecyclerAdapter) luaValues[0].toUserdata();
                        switch (type) {
                            case ObservableList.CHANGED:
                                udBaseRecyclerAdapter.reloadAtRow(0, start, false);
                                break;
                            case ObservableList.INSERTED:
                                udBaseRecyclerAdapter.insertCellsAtSection(0, start, count);
                                break;
                            case ObservableList.REMOVED:
                                udBaseRecyclerAdapter.deleteCellsAtSection(0, start, count);
                                break;
                        }

                        observableList.removeListChangeCallback(this);
                        bindListView(globals, source, tag, udView);
                    }
                }
            };
            observableList.addListChangedCallback(outsIListChangedCallback);
            globals.addOnDestroyListener(new Globals.OnDestroyListener() {
                @Override
                public void onDestroy(Globals g) {
                    observableList.removeListChangeCallback(outsIListChangedCallback);
                }
            });
        }
    }


    public int getSectionCount(Object source, String tag) {
        Object target = mDataProcessor.get(source, tag);
        if(target == null) {
            return 1;
        }
        if(target instanceof  ObservableList) {
            ObservableList observableList = (ObservableList) target;
            if (DataBindUtils.isDoubleList(observableList)) {
                return observableList.size();
            } else {
                return 1;
            }
        } else {
            throw new RuntimeException(tag + " must is list");
        }
    }


    public int getRowCount(Object source, String tag, int section) {
        Object target = mDataProcessor.get(source, tag);
        if(target == null) {
            return 0;
        }

        if(target instanceof  ObservableList) {
            ObservableList observableList = (ObservableList)target;
            if (DataBindUtils.isDoubleList(observableList)) {
                return ((ObservableList) observableList.get(section)).size();
            } else {
                return observableList.size();
            }
        } else {
            throw new RuntimeException(tag + " must is list");
        }
    }


    public void insert(Object source, String tag, int index, Object object) {
        Object observer = mDataProcessor.get(source, tag);

        if (observer instanceof ObservableList) {
            if(index == -1) {
                ((ObservableList) observer).add(object);
            } else {
                ((ObservableList) observer).add(index-1, object);
            }
        } else {
            throw new RuntimeException(tag + " must is list");
        }
    }


    public void remove(Object source,String tag,int index) {
        Object observer = mDataProcessor.get(source, tag);
        if (observer instanceof ObservableList) {
            ObservableList observableList = (ObservableList) observer;
            if(observableList.size() == 0) { //与ios 统一不报错
                return;
            }
            if(index == -1) {
                ((ObservableList) observer).remove(observableList.size()-1);
            } else {
                ((ObservableList) observer).remove(index-1);
            }
        } else {
            throw new RuntimeException(tag + "must is list");
        }
    }


    /**
     * bindCell
     * @param globals
     * @param dataSource
     * @param tag
     * @param section
     * @param row
     * @param bindProperties
     */
    public void bindCell(final Globals globals, DataSource dataSource, String tag, final int section, final int row, List<String> bindProperties) {

        ObservableList observableList = (ObservableList) mDataProcessor.get(dataSource.getSource(),tag);
        String lastTag;
        if(DataBindUtils.isDoubleList(observableList)) {
            lastTag = new StringBuilder(tag).append(Constants.SPOT).append(section).append(Constants.SPOT).append(row).toString();
        } else{
            lastTag = new StringBuilder(tag).append(Constants.SPOT ).append(row).toString();
        }

        Object cell = mDataProcessor.get(dataSource.getSource(),lastTag);


        BindCell bindCell = BindCell.obtain(section,row,cell.hashCode(),bindProperties);

        if(dataSource.isContainBindCell(tag,bindCell)) {
            if(DataBinding.isLog) {
                Log.d(DataBinding.TAG,"bindCell已绑定");
            }
            return;
        }

        dataSource.addBindCell(tag,bindCell);

        final UDView udView = dataSource.getListView(tag);

        for(String bindProperty: bindProperties) {
            String newProperty = Constants.CELL + lastTag.replace(Constants.SPOT,"") + Constants.SPOT + bindProperty;
            // 移除之前的bindCell 的监听
            removeBindObserver(cell,bindProperty,newProperty);
            mDataProcessor.addObserver(globals,  cell,true,false,newProperty, new IPropertyCallback() {
                @Override
                public void callBack(Object old, Object news) {
                    if (udView instanceof UDRecyclerView) {
                        LuaValue[] luaValues = ((UDRecyclerView) udView).adapter(new LuaValue[0]);
                        UDBaseRecyclerAdapter udBaseRecyclerAdapter = (UDBaseRecyclerAdapter) luaValues[0].toUserdata();
                        udBaseRecyclerAdapter.reloadAtRow(section-1, row-1, false);
                    }
                }
            });
        }
    }


    /**
     * 移除之前添加的监听
     * @param observed
     * @param observedTag
     * @param cellTag
     */
    public static void removeBindObserver(final Object observed, final String observedTag,String cellTag) {
        final String[] fields = observedTag.split(Constants.SPOT_SPLIT);
        Object templeObserver = observed;
        for(int i = 1; i<= fields.length-1;i++) {
            if(templeObserver instanceof IObservable) {
                ((IObservable)templeObserver).removeObserver(cellTag);
            }
            templeObserver = DataBindingEngine.getInstance().getGetSetAdapter().get(templeObserver,fields[i]);
        }
    }


}