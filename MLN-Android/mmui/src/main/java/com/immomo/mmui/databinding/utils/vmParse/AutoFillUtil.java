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
                            final Map middle = AutoFillConvertUtils.toMap(dataTable);// 防止多线程操作VM，因此先用map作为中间数据存储对象
                            if (MLSEngine.DEBUG) {
                                LogUtil.d(middle.toString());
                            }
                            if (MainThreadExecutor.isMainThread()) {
                                mainThreadAutoFill(middle, vm, callback);
                            } else {
                                MainThreadExecutor.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        mainThreadAutoFill(middle, vm, callback);
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
    private static void mainThreadAutoFill(Map middle, Object vm, SingleThreadExecutor.ExecuteCallback callback) {
        try {
            autoFill(middle, vm);
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
     * @param vm     待填充的VM。 新的VM生成方式，一定是继承ObservableField，ObservableField中只包含ObservableMap和ObservableList，不会包含ObservableField
     */
    private static void autoFill(Map middle, Object vm) throws IllegalAccessException, NoSuchMethodException, InvocationTargetException {
        // ObservableField 字段确定，以其为标准，填充
        final ObservableField vmField = (ObservableField) vm;
        Map<String, BoundField> maps = getBoundFields(vmField.getClass());
        for (Map.Entry<String, BoundField> entry : maps.entrySet()) {
            String key = entry.getKey();
            BoundField value = entry.getValue();
            Class<?> type = value.getType();
            Method setMethod = vmField.getClass().getDeclaredMethod(setMethodName(key), type);
            setMethod.setAccessible(true);
            if (!middle.containsKey(key)) {
                continue;
            }
            if (type.isAssignableFrom(String.class)
                    || type.isAssignableFrom(int.class) || type.isAssignableFrom(Integer.class)
                    || type.isAssignableFrom(long.class) || type.isAssignableFrom(Long.class)
                    || type.isAssignableFrom(short.class) || type.isAssignableFrom(Short.class)
                    || type.isAssignableFrom(float.class) || type.isAssignableFrom(Float.class)
                    || type.isAssignableFrom(double.class) || type.isAssignableFrom(Double.class)
                    || type.isAssignableFrom(boolean.class) || type.isAssignableFrom(Boolean.class)) {
                setMethod.invoke(vmField, middle.get(key));
            } else if (type.isAssignableFrom(ObservableMap.class)) {
                Map map = (Map) middle.get(key);
                ObservableMap data = AutoFillConvertUtils.toFastObservableMap(map);
                setMethod.invoke(vmField, data);
            } else if (type.isAssignableFrom(ObservableList.class)) {
                List list = (List) middle.get(key);
                ObservableList data = AutoFillConvertUtils.toFastObservableList(list);
                setMethod.invoke(vmField, data);
            } else {
                throw new RuntimeException("Illegal type. ViewModel can't have custom object：" + type);
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
