package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public final class Method {
    String name;
    Type returnType;
    Type[] params;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder(returnType.toString()).append(' ').append(name).append('(');
        for (Type t : params) {
            sb.append(t).append(',');
        }
        if (params.length > 0)
            sb.setLength(sb.length() - 1);
        sb.append(')');
        return sb.toString();
    }
}
