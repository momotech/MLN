/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.lua;

import com.alibaba.fastjson.JSONObject;

import java.util.*;

/**
 * Created by Xiong.Fangyu on 2020/7/28
 */
public class BridgeInfo {
    private static final String TIME_KEY = "time";
    private static final String COUNT_KEY = "count";

    private final List<ClassInfo> classInfo;

    public BridgeInfo(JSONObject jo) {
        classInfo = new ArrayList<>();
        for (Map.Entry<String, Object> entry : jo.entrySet()) {
            JSONObject methodInfo = (JSONObject) entry.getValue();
            ClassInfo classInfo = new ClassInfo(entry.getKey());
            classInfo.setMethodInfo(methodInfo);
            this.classInfo.add(classInfo);
        }
        classInfo.sort(Comparator.naturalOrder());
    }

    public void add(BridgeInfo other) {
        List<ClassInfo> needAdd = new ArrayList<>();
        for (ClassInfo ci : other.classInfo) {
            int i = classInfo.indexOf(ci);
            if (i < 0) {
                needAdd.add(ci);
            } else {
                classInfo.get(i).add(ci);
            }
        }
        classInfo.addAll(needAdd);
    }

    @Override
    public String toString() {
        return "BridgeInfo{" +
                "classInfo=" + classInfo +
                '}';
    }

    public List<ClassInfo> getClassInfo() {
        return classInfo;
    }

    public static final class ClassInfo implements Comparable<ClassInfo> {
        private final String name;
        private int allBridgeCount;
        private float allTime;
        private final List<MethodInfo> methodInfo;

        ClassInfo(String name) {
            this.name = name;
            methodInfo = new ArrayList<>();
        }

        private void setMethodInfo(JSONObject jo) {
            allBridgeCount = 0;
            allTime = 0;
            for (Map.Entry<String, Object> entry : jo.entrySet()) {
                MethodInfo mi = new MethodInfo(entry.getKey(), (JSONObject) entry.getValue());
                methodInfo.add(mi);
                allBridgeCount += mi.allCount;
                allTime += mi.allTime;
            }
            methodInfo.sort(Comparator.naturalOrder());
        }

        private void add(ClassInfo other) {
            this.allBridgeCount += other.allBridgeCount;
            this.allTime += other.allTime;
            List<MethodInfo> needAdd = new ArrayList<>();
            for (MethodInfo mi : other.methodInfo) {
                int i = methodInfo.indexOf(mi);
                if (i < 0) {
                    needAdd.add(mi);
                } else {
                    methodInfo.get(i).add(mi);
                }
            }
            methodInfo.addAll(needAdd);
        }

        @Override
        public int compareTo(ClassInfo o) {
            return name.compareTo(o.name);
        }

        public String getName() {
            return name;
        }

        public int getAllBridgeCount() {
            return allBridgeCount;
        }

        public float getAllTime() {
            return allTime;
        }

        public List<MethodInfo> getMethodInfo() {
            return methodInfo;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof ClassInfo)) return false;
            ClassInfo classInfo = (ClassInfo) o;
            return name.equals(classInfo.name);
        }

        @Override
        public int hashCode() {
            return Objects.hash(name);
        }

        @Override
        public String toString() {
            return name + "={" +
                    "allBridgeCount=" + allBridgeCount +
                    ", allTime=" + allTime +
                    ", methodInfo=" + methodInfo +
                    '}';
        }
    }

    public static final class MethodInfo implements Comparable<MethodInfo> {
        private final String name;
        private int allCount;
        private float allTime;
        private float avTime;

        MethodInfo(String name, JSONObject info) {
            this.name = name;
            allCount = info.getIntValue(COUNT_KEY);
            allTime = (float) info.getDoubleValue(TIME_KEY);
            avTime = allTime / allCount;
        }

        private void add(MethodInfo other) {
            this.allCount += other.allCount;
            this.allTime += other.allTime;
            this.avTime = this.allTime / this.allCount;
        }

        public String getName() {
            return name;
        }

        public int getAllCount() {
            return allCount;
        }

        public float getAllTime() {
            return allTime;
        }

        public float getAvTime() {
            return avTime;
        }

        @Override
        public int compareTo(MethodInfo o) {
            return name.compareTo(o.name);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof MethodInfo)) return false;
            MethodInfo that = (MethodInfo) o;
            return name.equals(that.name);
        }

        @Override
        public int hashCode() {
            return Objects.hash(name);
        }

        @Override
        public String toString() {
            return name + "={" +
                    "allCount=" + allCount +
                    ", allTime=" + allTime +
                    ", avTime=" + avTime +
                    '}';
        }
    }
}
