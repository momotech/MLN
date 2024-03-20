package com.immomo.mmui.databinding.utils.vmParse;

import android.text.TextUtils;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mmui.MMUIAutoFillCApi;
import com.immomo.mmui.databinding.bean.ObservableField;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;

import org.json.JSONException;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by wang.yang on 2020/8/14.
 */
public class AutoFillUtil {

    // Lua返回可变参数个数
    private static final int LUA_MULTRET = -1;

    private final static String SET_PRE = "set";
    private final static String GET_PRE = "get";

    /**
     * 将jsonString转成LuaTable
     *
     * @param jsonString
     * @return
     */
    private static LuaValue toLuaTable(Globals g, String jsonString) {
        return AutoFillConvertUtils.toLuaTable(g, jsonString);
    }

    /**
     * 将ViewModule转成LuaTable
     *
     * @param vm
     * @return
     */
    public static LuaValue toLuaTable(Globals g, Object vm) {
        return AutoFillConvertUtils.toLuaValue(g, vm);
    }

    /**
     * 异步自动装配数据
     *
     * @param function 装配规则函数
     * @param origin   json 数据格式
     * @param vm       新的VM生成方式，一定是继承ObservableField，ObservableField中只包含ObservableMap和ObservableList，不会包含ObservableField
     * @param extra    额外数据
     * @param callback 回调
     */
    public static void autoFillByStringAsyn(final String function, final String origin, final KeypathCompareInterface vm, final Object extra, final SingleThreadExecutor.ExecuteCallback callback) {
        final boolean finalCompareSwitch = KeypathCompareUtil.getCompareSwitch(vm);

        SingleThreadExecutor.execute(new Runnable() {
            @Override
            public void run() {
                if (vm == null || TextUtils.isEmpty(function)) {
                    return;
                }
                try {
                    Globals globals = SingleThreadExecutor.getGlobals();
                    LuaValue originTable;
                    if (TextUtils.isEmpty(origin)) {
                        originTable = LuaTable.create(globals);
                    } else {
                        originTable = toLuaTable(globals, origin);
                    }
                    LuaValue vmTable = toLuaTable(globals, vm);
                    LuaValue extraValue = toLuaValue(globals, extra);
                    StringBuilder functionStringBuilder = new StringBuilder(function);
                    if (finalCompareSwitch) {
                        functionStringBuilder.insert(0, "\n" + KeypathCompareUtil.luaTableKeyPathTrackCode);
                    }
                    // 装配规则函数 返回约定一定是LuaTable
                    final LuaValue[] luaValues = MMUIAutoFillCApi._autoFill(globals.getL_State(), functionStringBuilder.toString(), finalCompareSwitch, LuaValue.varargsOf(originTable, vmTable, extraValue), LUA_MULTRET);
                    for (int i = 0; i < luaValues.length; i++) {
                        if (i == 0) {
                            LuaTable dataTable = (LuaTable) luaValues[0];
                            final AutoFillData data = AutoFillConvertUtils.toAutoData(dataTable);// 防止多线程操作VM，因此先用map作为中间数据存储对象
                            final Map middle = data.getData();
                            final Map<Object, Object> update = data.getUpdate();
                            if (MLSEngine.DEBUG) {
                                LogUtil.d(middle.toString());
                            }
                            if (MainThreadExecutor.isMainThread()) {
                                mainThreadAutoFill(middle, update, vm, callback);
                            } else {
                                MainThreadExecutor.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        mainThreadAutoFill(middle, update, vm, callback);
                                    }
                                });
                            }
                        }

                        if (MLSEngine.DEBUG) {
                            if (i == 1) {
                                final LuaTable dataTable = (LuaTable) luaValues[i];
                                final Map map = AutoFillConvertUtils.toMap(dataTable);
                                MainThreadExecutor.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        KeypathCompareUtil.mainThreadCompareKeyPath(map, vm);
                                    }
                                });
                            }
                        }
                    }

                } catch (RuntimeException e) {
                    dealError(callback, e);
                } catch (IllegalAccessException e) {
                    dealError(callback, new RuntimeException(e));
                }
            }
        });
    }

    /**
     * 将 obj 转成 LuaValue
     * @param obj
     * @return
     * @throws IllegalAccessException
     */
    private static LuaValue toLuaValue(Globals globals, Object obj) throws IllegalAccessException {
        if (Translator.isPrimitiveLuaData(obj)) {
            return Translator.translatePrimitiveToLua(obj);
        }
        if (obj == null)
            return LuaValue.Nil();
        if (obj instanceof LuaValue)
            return (LuaValue) obj;
        if (obj instanceof ILView) {
            return ((ILView) obj).getUserdata();
        }
        if (obj instanceof Map) {
            return ConvertUtils.toTable(globals, (Map<String, Object>) obj);
        } else if (obj instanceof List) {
            return ConvertUtils.toTable(globals, (List) obj);
        } else {
            Map<String, Object> map = toMap(obj);
            return ConvertUtils.toTable(globals, map);
        }
    }

    /**
     * 将 obj 转成 map
     * @param obj
     * @return
     * @throws IllegalAccessException
     * @throws JSONException
     */
    private static Map<String, Object> toMap(Object obj) throws IllegalAccessException {
        Map<String, Object> map = new HashMap<>();
        Field[] declaredFields = obj.getClass().getDeclaredFields();
        for (Field field : declaredFields) {
            field.setAccessible(true);
            map.put(field.getName(), field.get(obj));
        }
        return map;
    }

    /**
     * 主线程处理VM的赋值操作
     *
     * @param callback 回调
     */
    private static void mainThreadAutoFill(Map middle, Map update, Object vm, SingleThreadExecutor.ExecuteCallback callback) {
        try {
            autoFill(middle, update, vm);
            dealComplete(callback);
        } catch (IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
            dealError(callback, new RuntimeException(e));
        }
    }

    /**
     * 处理成功回调
     *
     * @param callback 回调
     */
    private static void dealComplete(final SingleThreadExecutor.ExecuteCallback callback) {
        if (callback != null) {
            if (MainThreadExecutor.isMainThread()) {
                callback.onComplete();
            } else {
                MainThreadExecutor.post(new Runnable() {
                    @Override
                    public void run() {
                        callback.onComplete();
                    }
                });
            }
        }
    }

    /**
     * 处理失败回调
     *
     * @param callback 回调
     */
    private static void dealError(final SingleThreadExecutor.ExecuteCallback callback, final RuntimeException e) {
        if (callback != null) {
            if (MainThreadExecutor.isMainThread()) {
                callback.onError(e);
            } else {
                MainThreadExecutor.post(new Runnable() {
                    @Override
                    public void run() {
                        callback.onError(e);
                    }
                });
            }
        }
    }

    /**
     * 通过table填充VM的数据
     *
     * @param middle 数据map，不会为空
     * @param update 模拟lua元表，针对每个table的生成类（map或者list）关联对应的元表生成类（map或者list）具体见{@link AutoFillData#update}
     * @param vm     待填充的VM。 新的VM生成方式，一定是继承ObservableField，ObservableField中只包含ObservableMap和ObservableList，不会包含ObservableField
     */
    private static void autoFill(Map middle, Map update, Object vm) throws IllegalAccessException, NoSuchMethodException, InvocationTargetException {
        // ObservableField 字段确定，以其为标准，填充
        final ObservableField vmField = (ObservableField) vm;
        // 类似获取对应的元表, 必定不为空
        Map<String, Integer> updateMap = (Map<String, Integer>) update.get(middle);
        if (updateMap == null) { // 若没有元表，则什么数据也没有，不用装配
            return;
        }
        Map<String, BoundField> maps = getBoundFields(vmField.getClass());
        for (Map.Entry<String, BoundField> entry : maps.entrySet()) {
            String key = entry.getKey();
            BoundField value = entry.getValue();
            Class<?> type = value.getType();
            Method setMethod = vmField.getClass().getDeclaredMethod(setMethodName(key), type);
            Method getMethod = vmField.getClass().getDeclaredMethod(getMethodName(key));
            setMethod.setAccessible(true);
            if (updateMap.get(key) == null) { // 原始数据如果没有，则对应的元表也没有该数据
                continue;
            }
            int updateIndex = updateMap.get(key);
            if (type.isAssignableFrom(String.class)
                    || type.isAssignableFrom(int.class) || type.isAssignableFrom(Integer.class)
                    || type.isAssignableFrom(long.class) || type.isAssignableFrom(Long.class)
                    || type.isAssignableFrom(short.class) || type.isAssignableFrom(Short.class)
                    || type.isAssignableFrom(float.class) || type.isAssignableFrom(Float.class)
                    || type.isAssignableFrom(double.class) || type.isAssignableFrom(Double.class)
                    || type.isAssignableFrom(boolean.class) || type.isAssignableFrom(Boolean.class)) {
                if (updateIndex != AutoFillData.DATA_DEFAULT) {
                    setMethod.invoke(vmField, middle.get(key));
                }
            } else if (type.isAssignableFrom(ObservableMap.class)) {
                Map map = (Map) middle.get(key);
                if (updateIndex != AutoFillData.DATA_DEFAULT) {
                    ObservableMap data = AutoFillConvertUtils.toFastObservableMap(map);
                    setMethod.invoke(vmField, data);
                } else {
                    ObservableMap data = (ObservableMap) getMethod.invoke(vmField);
                    autoSubFill(map, update, data);
                }
            } else if (type.isAssignableFrom(ObservableList.class)) {
                List list = (List) middle.get(key);
                if (updateIndex != AutoFillData.DATA_DEFAULT) {
                    ObservableList data = AutoFillConvertUtils.toFastObservableList(list);
                    setMethod.invoke(vmField, data);
                } else {
                    ObservableList data = (ObservableList) getMethod.invoke(vmField);
                    autoSubFill(list, update, data);
                }
            } else {
                throw new RuntimeException("Illegal type. ViewModel can't have custom object：" + type);
            }
        }
    }

    /**
     * 循环对ObservableMap 和 ObservableList 进行赋值； ObservableList没有单项赋值，只有循环找下一层ObservableMap 和 ObservableList
     * @param middle 数据map，不会为空
     * @param update 模拟lua元表，针对每个table的生成类（map或者list）关联对应的元表生成类（map或者list）具体见{@link AutoFillData#update}
     * @param vm     待填充的VM。 新的VM生成方式，一定是继承ObservableField，ObservableField中只包含ObservableMap和ObservableList，不会包含ObservableField
     */
    private static void autoSubFill(Object middle, Map update, Object vm) {
        if (vm instanceof ObservableMap) {
            final ObservableMap vmMap = (ObservableMap) vm;
            final Map<String, Object> middleMap = (Map) middle;
            // 类似获取对应的元表, 必定不为空
            Map<String, Integer> updateMap = (Map<String, Integer>) update.get(middle);
            for (Map.Entry<String, Integer> entry : updateMap.entrySet()) {
                String key = entry.getKey();
                int updateIndex = entry.getValue();
                Object data = middleMap.get(key);
                switch (updateIndex) {
                    case AutoFillData.DATA_UPDATE:
                        // 重新生成新数据
                        if (data instanceof Map) {
                            data = AutoFillConvertUtils.toFastObservableMap((Map<Object, Object>) data);
                        } else if (data instanceof List) {
                            data = AutoFillConvertUtils.toFastObservableList((List) data);
                        }
                        vmMap.put(key, data);
                        break;
                    case AutoFillData.DATA_DEFAULT:
                        if (data instanceof Map || data instanceof List) {
                            autoSubFill(data, update, vmMap.get(key));
                        }
                    default:
                        break;
                }
            }
        } else if (vm instanceof ObservableList) {
            final ObservableList vmList = (ObservableList) vm;
            final List middleList = (List) middle;
            for (int i = 0; i < vmList.size(); i++) {
                Object data = vmList.get(i);
                if (data instanceof ObservableMap || data instanceof ObservableList) {
                    autoSubFill(middleList.get(i), update, data);
                }
            }
        }
    }

    /**
     * 获取Class 的所有字段信息
     *
     * @param clazz
     * @return
     */
    private static Map<String, BoundField> getBoundFields(Class<?> clazz) throws NoSuchMethodException, IllegalAccessException {
        Map<String, BoundField> result = new LinkedHashMap<String, BoundField>();
        if (clazz.isInterface()) {
            return result;
        }
        Field[] fields = clazz.getDeclaredFields();
        for (Field field : fields) {
            boolean serialize = excludeField(field, true);
            boolean deserialize = excludeField(field, true);
            if (!serialize && !deserialize) {
                continue;
            }
            field.setAccessible(true);
            String name = (String) field.get(null);
            Method getMethod = clazz.getDeclaredMethod(getMethodName(name));
            getMethod.setAccessible(true);
            Class<?> type = getMethod.getReturnType();
            BoundField boundField = new BoundField(type, serialize, deserialize);
            result.put(name, boundField);
        }
        return result;
    }

    /**
     * 通过字段名称获取对应的set方法名称
     *
     * @param fieldName
     * @return
     */
    private static String setMethodName(String fieldName) {
        return SET_PRE + captureName(fieldName);
    }

    /**
     * 通过字段名称获取对应的get方法名称
     *
     * @param fieldName
     * @return
     */
    private static String getMethodName(String fieldName) {
        return GET_PRE + captureName(fieldName);
    }

    /**
     * 首字母大写
     */
    private static String captureName(String name) {
        char[] cs = name.toCharArray();
        cs[0] -= 32;
        return String.valueOf(cs);
    }

    /**
     * 设置序列化权限
     *
     * @param f         f
     * @param serialize 是否序列化/反序列化
     * @return
     */
    private static boolean excludeField(Field f, boolean serialize) {
        return true;
    }

    /**
     * 创建实例
     *
     * @param clazz
     * @return
     */
    private static Object newInstance(Class<?> clazz) {
        try {
            final Constructor<?> constructor = clazz.getDeclaredConstructor();
            boolean flag = constructor.isAccessible();
            if (!flag) {
                constructor.setAccessible(true);
            }
            try {
                Object instance = constructor.newInstance();
                if (!flag) {
                    constructor.setAccessible(false);
                }
                return instance;
            } catch (InstantiationException e) {
                // TODO: JsonParseException ?
                throw new RuntimeException("Failed to invoke " + constructor + " with no args", e);
            } catch (InvocationTargetException e) {
                // TODO: don't wrap if cause is unchecked!
                // TODO: JsonParseException ?
                throw new RuntimeException("Failed to invoke " + constructor + " with no args",
                        e.getTargetException());
            } catch (IllegalAccessException e) {
                throw new AssertionError(e);
            }
        } catch (NoSuchMethodException e) {
            return null;
        }
    }
}
