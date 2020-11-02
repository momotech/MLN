/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2020/9/8
 */
public class CGenerate extends Annotation {
    private static final String PARAMS = "params";
    private static final String RETURN = "returnType";
    private static final String DEFAULT_CON = "defaultConstructor";
    private static final String ALIAS = "alias";

    public CGenerate(Annotation a) {
        this.simpleName = a.simpleName;
        this.packageName = a.packageName;
        this.values = a.values;
    }

    public static enum SpecialType {
        Normal,
        Function,
        Table,
        Userdata,
        Globals;

        public static SpecialType parse(char c) {
            switch (c) {
                case 'U':
                    return Userdata;
                case 'F':
                    return Function;
                case 'T':
                    return Table;
                case 'G':
                    return Globals;
                default:
                    return Normal;
            }
        }
    }

    private String getParams() {
        Map<String, Value> vs = getValues();
        if (vs == null)
            return null;
        Value v = vs.get(PARAMS);
        if (v != null)
            return v.realValue;
        return null;
    }
    private String getReturn() {
        Map<String, Value> vs = getValues();
        if (vs == null)
            return null;
        Value v = vs.get(RETURN);
        if (v != null)
            return v.realValue;
        return null;
    }

    public boolean isDefaultConstructor() {
        Map<String, Value> vs = getValues();
        if (vs == null)
            return false;
        Value v = vs.get(DEFAULT_CON);
        if (v == null)
            return false;
        return Boolean.parseBoolean(v.realValue);
    }

    public String alias() {
        Map<String, Value> vs = getValues();
        if (vs == null)
            return null;
        Value v = vs.get(ALIAS);
        if (v != null)
            return v.realValue;
        return null;
    }

    public SpecialType[] getParamType() {
        String s = getParams();
        if (s == null || s.isEmpty())
            return null;
        int len = s.length();
        SpecialType[] ret = new SpecialType[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = SpecialType.parse(s.charAt(i));
        }
        return ret;
    }

    public int getParamGlobalCount() {
        String s = getParams();
        if (s == null || s.isEmpty())
            return 0;
        int len = s.length();
        int count = 0;
        for (int i = 0; i < len; i ++) {
            if (s.charAt(i) == 'G')
                count ++;
        }
        return count;
    }

    public SpecialType getReturnType() {
        String s = getReturn();
        if (s == null || s.isEmpty())
            return null;
        return SpecialType.parse(s.charAt(0));
    }
}
