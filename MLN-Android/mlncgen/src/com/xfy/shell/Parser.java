package com.xfy.shell;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class Parser {
    private static final String ANNOTATION = "@LuaApiUsed";
    private static final String PACKAGE = "package";
    private static final String IMPORT = "import";
    private static final String CLASS = "class";
    private static final char[] Blank = {
            ' ', '\t', '\n'
    };
    private static final char Sem = ';';
    private static final char Comma = ',';
    private static final char LeftBrackets = '(';
    private static final char RightBrackets = ')';
    private static final char BlockStart = '{';
    private static final String[] Modifys = {
            "public", "protected", "private"
    };

    private String className;
    private String packageName;
    private List<Method> methods;
    private List<String> imports;

    public Parser(String classContent) {
        methods = new ArrayList<>();
        imports = new ArrayList<>();
        parse(classContent);
        setMethodPackage();
    }

    public String getClassName() {
        return className;
    }

    public String getPackageName() {
        return packageName;
    }

    public List<Method> getMethods() {
        return methods;
    }

    private void setMethodPackage() {
        for (Method m : methods) {
            setTypePackage(m.returnType);
            for (Type t : m.params) {
                setTypePackage(t);
            }
        }
    }

    private void setTypePackage(Type type) {
        if (type.isVoid || type.isPrimitive)
            return;
        String name = type.name;
        for (String im : imports) {
            if (im.endsWith(name)) {
                type.name = im;
                break;
            }
        }
        type.name = packageName + "." + name;
    }

    private boolean isBlank(char c) {
        for (char b : Blank) {
            if (b == c)
                return true;
        }
        return false;
    }

    private boolean isModify(String s) {
        for (String m : Modifys) {
            if (m.equals(s))
                return true;
        }
        return false;
    }

    private static int find(char[] chars, int start, String key) {
        return find(chars, start, chars.length, key);
    }

    private static int find(char[] chars, int start, int end, String key) {
        char[] keys = key.toCharArray();
        int klen = keys.length;
        int ki = 0;
        for (; start < end; start ++) {
            if (chars[start] == keys[ki]) {
                ki ++;
            } else {
                ki = 0;
            }
            if (ki == klen)
                return start - klen + 1;
        }
        return -1;
    }

    private void parse(String content) {
        char[] chars = content.toCharArray();
        int i = 0;
        while (true) {
            /// 读取包名
            if (packageName == null) {
                int ps = find(chars, i, PACKAGE);
                if (ps == -1) {
                    packageName = "";
                    continue;
                }
                i = ps + PACKAGE.length();
                while (isBlank(chars[i])) {
                    i ++;
                }
                int start = i;
                while (chars[i] != Sem && !isBlank(chars[i])) {
                    i ++;
                }
                int e = chars[i] == Sem ? i - 1 : i;
                while (isBlank(chars[e])) {
                    e --;
                }
                packageName = new String(chars, start, e - start + 1);
                i ++;
                continue;
            }
            int importStart = i;
            i = find(chars, i, ANNOTATION);
            if (i == -1)
                break;
            /// 读取import
            importStart = find(chars, importStart, i, IMPORT);
            while (importStart >= 0) {
                importStart += IMPORT.length();
                while (isBlank(chars[importStart])) {
                    importStart++;
                }
                int rs = importStart;
                while (chars[importStart] != Sem && !isBlank(chars[importStart])) {
                    importStart ++;
                }
                int re = chars[importStart] == Sem ? importStart - 1 : importStart;
                imports.add(new String(chars, rs, re - rs + 1));
                importStart = find(chars, importStart + 1, i, IMPORT);
            }
            i += ANNOTATION.length();
            /// 读类名
            if (className == null) {
                int cs = find(chars, i, CLASS);
                if (cs == -1)
                    break;
                i = cs + CLASS.length();
                while (isBlank(chars[i])) {
                    i ++;
                }
                cs = i;
                while (chars[i] != BlockStart && !isBlank(chars[i])) {
                    i ++;
                }
                int ce = i;
                while (isBlank(chars[ce])) {
                    ce --;
                }
                className = new String(chars, cs, ce - cs + 1);
                i ++;
                continue;
            }
            /// 读方法
            int ms = i;
            while (chars[i] != LeftBrackets) {
                i ++;
            }
            i --;
            int[] se = {ms, i};
            String methodName = getKeyWordFromEnd(chars, se);
            se[1] = se[0];
            se[0] = ms;
            String returnName = getKeyWordFromEnd(chars, se);
            if (returnName.isEmpty() || isModify(returnName)) {
                continue;
            }
            i += 2;
            se[0] = i - 1;
            int end = i;
            char c;
            ArrayList<Type> params = new ArrayList<>();
            while (true) {
                c = chars[i];
                if (c == Comma || c == RightBrackets) {
                    end = i;
                    i --;
                    while (isBlank(chars[i])) {
                        i --;
                    }
                    while (!isBlank(chars[i])) {
                        i --;
                    }
                    /// 跳过了最后一个关键字
                    se[1] = i;
                    String tn = getKeyWordFromEnd(chars, se);
                    if (!tn.isEmpty())
                        params.add(new Type(tn));
                    i = end + 1;
                    if (c == RightBrackets)
                        break;
                } else {
                    i ++;
                }
            }
            Method m = new Method();
            m.name = methodName;
            m.returnType = new Type(returnName);
            m.params = params.toArray(new Type[0]);
            methods.add(m);
        }
    }

    private String getKeyWordFromEnd(char[] chars, int[] se) {
        int ks, ke;
        int start = se[0];
        int end = se[1];
        while (isBlank(chars[end]) && end > start) {
            end --;
        }
        ke = end;
        while (!isBlank(chars[end]) && end > start) {
            end --;
        }
        ks = end + 1;
        se[0] = end;
        return new String(chars, ks, ke - ks + 1);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder(packageName).append('.').append(className).append('\n');
        for (String s : imports) {
            sb.append("import ").append(s).append('\n');
        }
        for (Method m : methods) {
            sb.append(m).append('\n');
        }
        return sb.toString();
    }

}
