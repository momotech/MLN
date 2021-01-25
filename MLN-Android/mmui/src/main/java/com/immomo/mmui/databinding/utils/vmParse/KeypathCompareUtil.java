package com.immomo.mmui.databinding.utils.vmParse;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class KeypathCompareUtil {
    /**
     * 获取是否要对 viewModel 和 服务器返回的数据的 keypath 进行对比的条件。
     * @param obj 从 ArgoUI 里面导出的 viweModel，默认有 isCompareKeyPath 这个方法。
     * @return true, 进行对比，false，不进行对比， release 下，即使是true，也不进行对比。
     */
    public static boolean getCompareSwitch(KeypathCompareInterface obj) {
        boolean compareSwitch = false;
        if (MLSEngine.DEBUG) {
            compareSwitch = obj.isCompareKeyPath();
        }
        return compareSwitch;
    }

    /**
     * 主线程对比VM的keyPath赋值情况
     * @param originMap 从lua代码里面获取到的含有服务器返回数据的字段map
     * @param obj viewModel，从 ArgoUI 里面导出的viweModel，默认有 KeyPaths 这个方法。
     */
    public static void mainThreadCompareKeyPath(Map originMap, KeypathCompareInterface obj) {
        final ObservableMap keyPaths = obj.KeyPaths();
        diffBetween(originMap, keyPaths, "");
    }

    public static void diffBetween(Map originMap, ObservableMap standardMap, String pk) {
        if (originMap == null) {
            if (MLSEngine.DEBUG) {
                LogUtil.d("keypath compare: " + pk + " 没有赋值");
            }
            return;
        }

        String dot = pk.length() > 0 ? "." : "";
        Iterator iterator = standardMap.keySet().iterator();
        while (iterator.hasNext()) {
            Object key = iterator.next();
            if (standardMap.get(key).getClass() == ObservableList.class) {
                if (originMap.get(key) != null) {
                    for (int i = 0; i < ((List) originMap.get(key)).size(); i++) {
                        diffBetween(((Map) ((List) originMap.get(key)).get(i)), (ObservableMap) ((ObservableList) standardMap.get(key)).get(0), pk + dot + key + "." + i);
                    }
                } else {
                    if (MLSEngine.DEBUG) {
                        LogUtil.d("keypath compare: " + pk + dot + key + " 没有赋值");
                    }
                }
            } else if (standardMap.get(key).getClass() == ObservableMap.class) {
                diffBetween(((Map) originMap.get(key)), (ObservableMap) standardMap.get(key), pk + dot + key);
            } else {
                if (!originMap.containsKey(key)) {
                    if (MLSEngine.DEBUG) {
                        LogUtil.d("keypath compare: " + pk + dot + key + " 没有赋值");
                    }

                }
            }
        }
    }

    static final String luaTableKeyPathTrackCode =   "        \n" +
                "        KeyPathMap = {}\n" +
                "    local function isArrayTable(t)\n" +
                "        if type(t) ~= \"table\" then\n" +
                "            return false\n" +
                "        end\n" +
                "        local n = #t\n" +
                "        for i, v in pairs(t) do\n" +
                "            if type(i) ~= \"number\" then\n" +
                "                return false\n" +
                "            end\n" +
                "            if i > n then\n" +
                "                return false\n" +
                "            end\n" +
                "        end\n" +
                "        return true\n" +
                "    end\n" +
                "    local function checkType(t)\n" +
                "        local type = type(t);\n" +
                "        if type == \"userdata\" then\n" +
                "            return t;\n" +
                "        end\n" +
                "        if type == \"number\" then\n" +
                "            if math.floor(t) < t then\n" +
                "                return \"float\";\n" +
                "            else\n" +
                "                return \"int\";\n" +
                "            end\n" +
                "        end\n" +
                "        if type ~= \"table\" then\n" +
                "            return type;\n" +
                "        end\n" +
                "        if isArrayTable(t) then\n" +
                "            return \"array\";\n" +
                "        end\n" +
                "        return \"map\";\n" +
                "    end\n" +
                "    \n" +
                "    viewModelMT = {\n" +
                "        __index = function(t, k)\n" +
                "            if rawget(t, k) == nil then\n" +
                "                t[k] = {}\n" +
                "            end\n" +
                "            return rawget(t, k)\n" +
                "        end,\n" +
                "    \n" +
                "        __newindex = function(t, k, v)\n" +
                "            _innerSet(t, k, v, \"\")\n" +
                "        end\n" +
                "    }\n" +
                "    \n" +
                "    function _innerSet(t, k, v, pk)\n" +
                "    \n" +
                "        if checkType(v) == \"array\" and #v == 0 then\n" +
                "            rawset(t, k, v)\n" +
                "            return\n" +
                "        end\n" +
                "    \n" +
                "        if checkType(v) == \"array\" and #v > 0 then\n" +
                "            local es = _innerArraySet(t, k, v, k)\n" +
                "            KeyPathMap[k] = es\n" +
                "        elseif checkType(v) == \"map\" then\n" +
                "            local es = _innerMapSet(t, k, v, k)\n" +
                "            KeyPathMap[k] = es\n" +
                "        else\n" +
                "            rawset(t, k, v)\n" +
                "            local kp = k\n" +
                "            KeyPathMap[k] = k\n" +
                "        end\n" +
                "    end\n" +
                "    \n" +
                "    function _innerArraySet(t, k, v, pk)\n" +
                "        local elementKeys = {}\n" +
                "        if t[k] == nil then\n" +
                "            rawset(t, k, {})\n" +
                "        end\n" +
                "        for index, value in ipairs(v) do\n" +
                "            local kp = pk .. \".\" .. \"array\"\n" +
                "            if checkType(value) == \"array\" then\n" +
                "                local es = _innerArraySet(t[k], index, value, kp)\n" +
                "                table.insert(elementKeys, #elementKeys + 1, es)\n" +
                "            elseif checkType(value) == \"map\" then\n" +
                "                local es = _innerMapSet(t[k], index, value, kp)\n" +
                "                table.insert(elementKeys, #elementKeys + 1, es)\n" +
                "            else\n" +
                "                rawset(t[k], index, value)\n" +
                "            end\n" +
                "        end\n" +
                "        return elementKeys\n" +
                "    end\n" +
                "    \n" +
                "    function _innerMapSet(t, k, v, pk)\n" +
                "        local elementKeys = {}\n" +
                "        if t[k] == nil then\n" +
                "            rawset(t, k, {})\n" +
                "        end\n" +
                "        for key, value in pairs(v) do\n" +
                "            if checkType(value) == \"array\" then\n" +
                "                local es = _innerArraySet(t[k], key, value, pk .. \".\" .. tostring(key))\n" +
                "                elementKeys[key] = es\n" +
                "            elseif checkType(value) == \"map\" then\n" +
                "                local es = _innerMapSet(t[k], key, value, pk .. \".\" .. tostring(key))\n" +
                "                elementKeys[key] = es\n" +
                "            else\n" +
                "                elementKeys[key] = key\n" +
                "                rawset(t[k], key, value)\n" +
                "            end\n" +
                "        end\n" +
                "        return elementKeys\n" +
                "    end\n" +
                "    function getAllKeyPath(viewModel)\n" +
                "        KeyPathMap = {}\n" +
                "        local tmp = {}\n" +
                "        setmetatable(tmp, viewModelMT)\n" +
                "        for i, v in pairs(viewModel) do\n" +
                "            tmp[i] = v\n" +
                "        end\n" +
                "    end\n\n\n";
}
