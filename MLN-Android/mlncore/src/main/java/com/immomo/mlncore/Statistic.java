package com.immomo.mlncore;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.Iterator;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020/6/28
 */
@LuaApiUsed
public class Statistic {
    private static final String TIME_KEY = "time";
    private static final String COUNT_KEY = "count";

    static MLNCore.StatisticCallback callback = null;

    @LuaApiUsed
    static void onBridgeCallback(String json) {
        if (callback != null)
            callback.onBridgeCallback(json);
    }

    @LuaApiUsed
    static void onRequireCallback(String json) {
        if (callback != null)
            callback.onRequireCallback(json);
    }

    //<editor-fold desc="Bridge statistic">

    /**
     * 将统计Bridge的json信息解析，输出{@link Info}
     *
     * @param json Bridge统计json信息，由{@link #onBridgeCallback(String)}提供
     * @param bsi  需要统计的信息以及信息输出对象
     * @return true 输出成功
     */
    public static boolean getBridgeInfo(@NonNull String json, @NonNull Info bsi) {
        double maxTime = bsi.maxTime;
        double allTime = 0;
        int count = 0;
        int overTimeCount = 0;
        List<String> overTimeMethods = bsi.overTimeInfo;
        try {
            JSONObject jo = new JSONObject(json);
            Iterator<String> classNames = jo.keys();
            while (classNames.hasNext()) {
                String className = classNames.next();
                JSONObject methodInfo = jo.optJSONObject(className);
                if (methodInfo == null)
                    continue;
                Iterator<String> methods = methodInfo.keys();
                while (methods.hasNext()) {
                    String method = methods.next();
                    JSONObject info = methodInfo.optJSONObject(method);
                    if (info == null)
                        continue;
                    double time = info.optDouble(TIME_KEY, 0);
                    int c = info.optInt(COUNT_KEY, 0);
                    allTime += time;
                    count += c;
                    double avTime = time / c;
                    if (maxTime > 0 && avTime > maxTime) {
                        overTimeCount += c;
                        if (overTimeMethods != null) {
                            overTimeMethods.add(className + "." + method);
                        }
                    }
                }
            }
            bsi.allCount = count;
            bsi.allTime = allTime;
            bsi.overTimeCount = overTimeCount;
            return true;
        } catch (JSONException e) {
            return false;
        }
    }


    /**
     * 将统计Bridge的json信息解析，输出{@link Info}
     *
     * @param json             Bridge统计json信息，由{@link #onBridgeCallback(String)}提供
     * @param bsi              需要统计的信息以及信息输出对象
     * @param methodNameFilter 过滤方法名
     * @return true 输出成功
     */
    public static boolean getBridgeInfoByMethod(@NonNull String json, @NonNull Info bsi, String methodNameFilter) {
        double maxTime = bsi.maxTime;
        double allTime = 0;
        int count = 0;
        int overTimeCount = 0;
        List<String> overTimeMethods = bsi.overTimeInfo;
        try {
            JSONObject jo = new JSONObject(json);
            Iterator<String> classNames = jo.keys();
            while (classNames.hasNext()) {
                String className = classNames.next();
                JSONObject methodInfo = jo.optJSONObject(className);
                if (methodInfo == null)
                    continue;
                Iterator<String> methods = methodInfo.keys();
                while (methods.hasNext()) {
                    String method = methods.next();
                    if (method.equals(methodNameFilter)) {
                        JSONObject info = methodInfo.optJSONObject(method);
                        if (info == null)
                            continue;
                        double time = info.optDouble(TIME_KEY, 0);
                        int c = info.optInt(COUNT_KEY, 0);
                        allTime += time;
                        count += c;
                        double avTime = time / c;
                        if (maxTime > 0 && avTime > maxTime) {
                            overTimeCount += c;
                            if (overTimeMethods != null) {
                                overTimeMethods.add(className + "." + method);
                            }
                        }
                        break;
                    }
                }
            }
            bsi.allCount = count;
            bsi.allTime = allTime;
            bsi.overTimeCount = overTimeCount;
            return true;
        } catch (JSONException e) {
            return false;
        }
    }

    /**
     * 将统计Bridge的json信息解析，输出{@link Info}
     *
     * @param json            Bridge统计json信息，由{@link #onBridgeCallback(String)}提供
     * @param bsi             需要统计的信息以及信息输出对象
     * @param classNameFilter 过滤方法名
     * @return true 输出成功
     */
    public static boolean getBridgeInfoByClass(@NonNull String json, @NonNull Info bsi, String classNameFilter) {
        double maxTime = bsi.maxTime;
        double allTime = 0;
        int count = 0;
        int overTimeCount = 0;
        List<String> overTimeMethods = bsi.overTimeInfo;
        try {
            JSONObject jo = new JSONObject(json);
            Iterator<String> classNames = jo.keys();
            while (classNames.hasNext()) {
                String className = classNames.next();
                if (className.equals(classNameFilter)) {
                    JSONObject methodInfo = jo.optJSONObject(className);
                    if (methodInfo == null)
                        continue;
                    bsi.otherInfo = methodInfo.toString();
                    Iterator<String> methods = methodInfo.keys();
                    while (methods.hasNext()) {
                        String method = methods.next();
                        JSONObject info = methodInfo.optJSONObject(method);
                        if (info == null)
                            continue;
                        double time = info.optDouble(TIME_KEY, 0);
                        int c = info.optInt(COUNT_KEY, 0);
                        allTime += time;
                        count += c;
                        double avTime = time / c;
                        if (maxTime > 0 && avTime > maxTime) {
                            overTimeCount += c;
                            if (overTimeMethods != null) {
                                overTimeMethods.add(className + "." + method);
                            }
                        }
                    }
                    bsi.allCount = count;
                    bsi.allTime = allTime;
                    bsi.overTimeCount = overTimeCount;
                    return true;
                }
            }
            return true;
        } catch (JSONException e) {
            return false;
        }
    }


    /**
     * 将统计Require的json信息解析，输出{@link Info}
     *
     * @param json Require统计json信息，由{@link #onRequireCallback(String)}提供
     * @param ri   需要统计的信息以及信息输出对象
     * @return true输出成功
     */
    public static boolean getRequireInfo(@NonNull String json, @NonNull Info ri) {
        double maxTime = ri.maxTime;
        int count = 0;
        double allTime = 0;
        int overTimeCount = 0;
        List<String> overTimeFiles = ri.overTimeInfo;
        try {
            JSONObject jo = new JSONObject(json);
            Iterator<String> types = jo.keys();
            while (types.hasNext()) {
                String type = types.next();
                JSONObject info = jo.optJSONObject(type);
                if (info == null)
                    continue;
                Iterator<String> files = info.keys();
                while (files.hasNext()) {
                    String file = files.next();
                    double ms = info.optDouble(file);// / 1000f;
                    allTime += ms;
                    count++;
                    if (maxTime > 0 && ms > maxTime) {
                        overTimeCount++;
                        if (overTimeFiles != null) {
                            overTimeFiles.add(type + "|" + file);
                        }
                    }
                }
            }
            ri.allCount = count;
            ri.allTime = allTime;
            ri.overTimeCount = overTimeCount;
            return true;
        } catch (JSONException e) {
            return false;
        }
    }

    /**
     * 获取统计信息
     *
     * @see #getBridgeInfo(String, Info)
     * @see #getRequireInfo(String, Info)
     */
    public static final class Info {
        /**
         * 时常超过设置时常，则统计超时次数
         * 单位ms
         * 若{@link #overTimeInfo}不为空，将超时信息加入
         */
        public final double maxTime;
        /**
         * 总共调用次数
         */
        public int allCount;
        /**
         * 总共调用时常
         * 单位ms
         */
        public double allTime;
        /**
         * 超时次数
         *
         * @see #maxTime
         */
        public int overTimeCount;
        /**
         * 超时名称
         *
         * @see #maxTime
         */
        public final List<String> overTimeInfo;
        /**
         * 其他信息
         */
        public String otherInfo;

        public Info() {
            this(0, null);
        }

        public Info(double maxTime) {
            this(maxTime, null);
        }

        public Info(double maxTime, List<String> overTimeInfo) {
            this.maxTime = maxTime;
            this.overTimeInfo = overTimeInfo;
        }

        @Override
        public String toString() {
            return "{" +
                    "maxTime=" + maxTime +
                    ", allCount=" + allCount +
                    ", allTime=" + allTime +
                    ", overTimeCount=" + overTimeCount +
                    ", overTimeInfo=" + overTimeInfo +
                    ", otherInfo=" + otherInfo +
                    '}';
        }
    }
    //</editor-fold>
}
