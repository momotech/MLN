/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.ArrayList;
import java.util.List;
import static com.xfy.shell.CharArrayUtils.*;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class Parser {
    private static final String ANNOTATION = "@LuaApiUsed";
    private static final String PACKAGE = "package";
    private static final String IMPORT = "import";
    private static final String CLASS = "class";
    private static final String STATIC = "static";
    private static final String LCN = "LUA_CLASS_NAME";
    private static final char Sem = ';';
    private static final char Comma = ',';
    private static final char LeftBrackets = '(';
    private static final char RightBrackets = ')';
    private static final char BlockStart = '{';
    private static final char BlockEnd = '}';
    private static final char Quot = '"';
    private static final char SQuot = '\'';
    private static final char Special = '\\';
    private static final char AT = '@';
    private static final String[] Modifys = {
            "public", "protected", "private"
    };
    private static final String FINAL = "final";
    private static final String NATIVE = "native";

    private String className;
    private String luaClassName;
    private String packageName;
    private final List<Method> methods;
    private final List<String> imports;
    private final List<String> classAnnotation;
    private boolean isStatic;

    private boolean importIsRead;

    public Parser(String classContent) throws Exception {
        methods = new ArrayList<>();
        imports = new ArrayList<>();
        classAnnotation = new ArrayList<>();
        parse(classContent);
        setMethodPackageAndCheck();
    }

    public String getClassName() {
        return className;
    }

    public String getLuaClassName() {
        return luaClassName;
    }

    public String getPackageName() {
        return packageName;
    }

    public List<Method> getMethods() {
        return methods;
    }

    public boolean isStatic() {
        return isStatic;
    }

    private void setMethodPackageAndCheck() throws Exception {
        if (methods.isEmpty())
            return;
        Boolean isStatic = null;
        for (Method m : methods) {
            if (m.containAnnotation(ANNOTATION)) {
                if (isStatic == null) {
                    isStatic = m.isStatic;
                } else if (isStatic != m.isStatic) {
                    throw new Exception("所有的bridge方法必须都是静态或非静态");
                }
            }
            setTypePackage(m.returnType);
            for (Type t : m.params) {
                setTypePackage(t);
            }
        }
        this.isStatic = isStatic != null ? isStatic : false;
    }

    private void setTypePackage(Type type) {
        if (!type.needAddPackage())
            return;
        String name = type.name;
        for (String im : imports) {
            if (im.endsWith(name)) {
                type.name = im;
                return;
            }
        }
        type.name = packageName + "." + name;
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
        char[] BlankAndSem = combine(Blank, Sem);
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
                i = afterBlank(chars, i);
                int start = i;
                i = afterNotChars(chars, BlankAndSem, i, chars.length);

                int e = chars[i] == Sem ? i - 1 : i;
                e = beforeBlank(chars, e);
                packageName = new String(chars, start, e - start + 1);
                i ++;
                continue;
            }
            /// 读取import
            int lastImportEnd = 0;
            if (!importIsRead) {
                int importStart = i;
                i = find(chars, i, CLASS);
                if (i == -1)
                    break;
                lastImportEnd = importStart;
                importStart = find(chars, importStart, i, IMPORT);
                while (importStart >= 0) {
                    importStart += IMPORT.length();
                    importStart = afterBlank(chars, importStart);
                    int rs = importStart;
                    importStart = afterNotChars(chars, BlankAndSem, importStart, chars.length);
                    int re = chars[importStart] == Sem ? importStart - 1 : importStart;
                    imports.add(new String(chars, rs, re - rs + 1));
                    lastImportEnd = importStart;
                    importStart = find(chars, importStart + 1, i, IMPORT);
                }
                importIsRead = true;
            }
            /// 读类名
            if (className == null) {
                /// i 指向class
                int preClass = beforeNotBlank(chars, i, lastImportEnd);
                ///查找注解
                while (preClass != -1) {
                    int keyStart = beforeNotBlank(chars, preClass, lastImportEnd);
                    if (keyStart != -1 && chars[keyStart + 1] == AT) {
                        classAnnotation.add(new String(chars, keyStart + 2, preClass - keyStart - 1));
                    }
                    preClass = beforeBlank(chars, keyStart, lastImportEnd);
                }
                int cs = i;
                i = cs + CLASS.length();
                i = afterBlank(chars, i);
                cs = i;
                i = afterNotChars(chars, combine(Blank, BlockStart), i, chars.length);
                int ce = beforeBlank(chars, i);
                className = new String(chars, cs, ce - cs + 1);
                i ++;

                /// 读lua 类名
                cs = find(chars, i, LCN);
                if (cs == -1)
                    continue;
                i = cs + LCN.length();
                while (isBlank(chars[i]) || chars[i] != Quot) {
                    i ++;
                }
                cs = ++i;
                i = afterNotChar(chars, Quot, i, chars.length);
                luaClassName = new String(chars, cs, i - cs);
                continue;
            }
            /// 读方法
            i = parseMethod(chars, i);
            if (i < 0)
                break;
        }
    }

    private int parseMethod(char[] chars, int i) {
        int min = i;
        i = afterChar(chars, LeftBrackets, i, chars.length);
        if (i < 0)
            return -1;
        int[] se = {min, i - 1};
        String methodName = getKeyWordFromEnd(chars, se);
        se[1] = se[0];
        se[0] = min;
        String returnName = getKeyWordFromEnd(chars, se);
        int methodEnd = getMethodEnd(chars, i + 1);
        if (returnName.isEmpty() || isModify(returnName)) {
            return methodEnd;
        }
        se[1] = se[0];
        se[0] = min;
        int preModifyCount = 3;
        boolean isStatic = false;
        boolean isNative = false;
        String modify = null;
        while (preModifyCount >= 0) {
            modify = getKeyWordFromEnd(chars, se);
            if (isModify(modify)) {
                se[1] = se[0];
                se[0] = min;
                preModifyCount--;
                continue;
            }
            if (FINAL.equals(modify)) {
                se[1] = se[0];
                se[0] = min;
                preModifyCount--;
                continue;
            }
            if (NATIVE.equals(modify)) {
                se[1] = se[0];
                se[0] = min;
                isNative = true;
                preModifyCount--;
                continue;
            }
            if (STATIC.equals(modify)) {
                se[1] = se[0];
                se[0] = min;
                isStatic = true;
                preModifyCount--;
                continue;
            }
            break;
        }
        List<String> annotations = null;
        while (se[0] != min && chars[se[0] + 1] == AT) {
            if (annotations == null) annotations = new ArrayList<>();
            annotations.add(modify);
            se[1] = se[0];
            se[0] = min;
            modify = getKeyWordFromEnd(chars, se);
        }

        /// 读方法参数
        i ++;//指向括号后一个字符
        min = i;
        se[0] = i;
        int end = i;
        char c;
        ArrayList<Type> params = new ArrayList<>();
        while (true) {
            c = chars[i];
            if (c == Comma || c == RightBrackets) {
                end = i;
                i --;
                if (i < min) {
                    break;
                }
                /// 过滤空白
                i = beforeBlank(chars, i);
                /// 过滤参数名
                i = beforeNotBlank(chars, i);
                /// 跳过了最后一个关键字
                se[1] = i;
                String tn = getKeyWordFromEnd(chars, se);
                if (!tn.isEmpty()) {
                    params.add(Type.getType(tn));
                }
                i = end + 1;
                se[0] = end;
                if (c == RightBrackets)
                    break;
            } else {
                i ++;
            }
        }
        Method m = new Method();
        m.name = methodName;
        m.returnType = Type.getType(returnName);
        m.params = params.toArray(new Type[0]);
        m.isStatic = isStatic;
        m.isNative = isNative;
        m.annotations = annotations;
        methods.add(m);
        return methodEnd;
    }

    private int getMethodEnd(char[] chars, int s) {
        s = afterChar(chars, RightBrackets, s, chars.length);
        if (s < 0)
            return -1;
        int semIndex = afterChar(chars, Sem, s, chars.length);
        int BlockStartIndex = afterChar(chars, BlockStart, s, chars.length);
        /// 不实现的方法
        if (semIndex > 0 && BlockStartIndex > 0 && semIndex < BlockStartIndex)
            return semIndex + 1;
        if (BlockStartIndex < 0 && semIndex > 0)
            return semIndex + 1;
        if (BlockStartIndex < 0)
            return -1;
        boolean inQuot = false;
        boolean inSQuot = false;
        int blockCount = 0;
        for (s = BlockStartIndex + 1; s < chars.length; s ++) {
            char c = chars[s];
            if (c == Quot) {
                if (chars[s - 1] != Special && !inSQuot) {
                    inQuot = !inQuot;
                }
                continue;
            } else if (c == SQuot) {
                if (chars[s - 1] != Special && !inQuot) {
                    inSQuot = !inSQuot;
                }
                continue;
            }
            if (inQuot || inSQuot)
                continue;
            if (c == BlockStart) {
                blockCount ++;
                continue;
            }
            if (c == BlockEnd) {
                blockCount --;
                if (blockCount == -1)
                    return s;
            }
        }
        return -1;
    }

    private String getKeyWordFromEnd(char[] chars, int[] se) {
        int ks, ke;
        int start = se[0];
        int end = se[1];
        end = beforeBlank(chars, end, start);
        if (end == -1) {
            end = start;
        }
        ke = end;
        end = beforeNotBlank(chars, end, start);
        if (end == -1) {
            end = start;
            ks = end;
        } else {
            ks = end + 1;
        }
        se[0] = end;
        return new String(chars, ks, ke - ks + 1);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        for (String s : classAnnotation) {
            sb.append(s).append('\n');
        }
        sb.append(packageName).append('.').append(className).append('\n');
        for (String s : imports) {
            sb.append("import ").append(s).append('\n');
        }
        sb.append("lua class name:").append(luaClassName).append('\n');
        for (Method m : methods) {
            sb.append(m).append('\n');
        }
        return sb.toString();
    }

}
