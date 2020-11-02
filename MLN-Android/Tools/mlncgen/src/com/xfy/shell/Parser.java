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
    private static final char LeftAngleBrackets = '<';
    private static final char RightAngleBrackets = '>';
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
    private List<String> luaClassName;
    private String packageName;
    private final List<Method> methods;
    private final List<String> imports;
    private final List<Annotation> classAnnotation;
    private boolean isStatic;
    private boolean isAbstract;

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

    public String getSimpleClassName() {
        int idx = className.lastIndexOf('.');
        if (idx >= 0) {
            return className.substring(idx + 1);
        }
        return className;
    }

    public boolean isAbstract() {
        return isAbstract;
    }

    public List<String> getLuaClassName() {
        return luaClassName;
    }

    public String getFirstLuaClassName() {
        return luaClassName.get(0);
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
            if (m.containLuaApiUsed()) {
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
        for (String im : imports) {
            if (type.setImportPackage(im)) {
                return;
            }
        }
        type.setPackage(packageName);
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
                i = CharArrayUtils.findAfter(chars, BlankAndSem, i, chars.length);

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
                    importStart = CharArrayUtils.findAfter(chars, BlankAndSem, importStart, chars.length);
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
                int preClass = findBlankBefore(chars, i, lastImportEnd);
                ///查找注解
                while (preClass != -1) {
                    int keyStart = findBlankBefore(chars, preClass, lastImportEnd);
                    if (keyStart != -1) {
                        if (chars[keyStart + 1] == 'a') {
                            String modi = new String(chars, keyStart + 1, preClass - keyStart);
                            isAbstract = modi.equals("abstract");
                        } else if (chars[keyStart + 1] == AT) {
                            classAnnotation.add(
                                    Annotation.parse(
                                            new String(chars, keyStart + 1, preClass - keyStart)));
                        }
                    }
                    preClass = beforeBlank(chars, keyStart, lastImportEnd);
                }
                int cs = i;
                i = cs + CLASS.length();
                i = afterBlank(chars, i);
                cs = i;
                i = CharArrayUtils.findAfter(chars, combine(Blank, BlockStart), i, chars.length);
                int ce = beforeBlank(chars, i);
                className = new String(chars, cs, ce - cs + 1);
                int lcidx = className.indexOf('<');
                if (lcidx > 0)
                    className = className.substring(0, lcidx);
                i ++;

                /// 读lua 类名
                cs = find(chars, i, LCN);
                if (cs == -1)
                    continue;
                i = cs + LCN.length();
                int lcnEnd = findAfter(chars, Sem, i, chars.length);
                while ((i = findAfter(chars, Quot, i, lcnEnd)) > 0) {
                    int end = findAfter(chars, Quot, i + 1, lcnEnd);
                    if (end < 0)
                        break;
                    String n = new String(chars, i + 1, end - i - 1);
                    if (luaClassName == null)
                        luaClassName = new ArrayList<>();
                    luaClassName.add(n);
                    i = end + 1;
                }
                i = lcnEnd + 1;
                continue;
            }
            /// 读方法
            i = parseMethod(chars, i + 1);
            if (i < 0)
                break;
        }
    }

    private void parseConstructor(char[] chars, int start, int nameIndex, int end) {
        List<Annotation> annotations = Annotation.parseMultiAnnotation(new String(chars, start, nameIndex - start));
        start = nameIndex + className.length();
        Method m = new Method();
        m.name = className + "<init>";
        m.returnType = Type.getType("void");
        m.params = parseMethodParams(chars, start, end).toArray(new Type[0]);
        m.annotations = annotations;
        m.isConstructor = true;
        methods.add(m);
    }

    private int parseMethod(char[] chars, int i) {
        i = afterBlank(chars, i);
        int min = i;
        boolean setMin = false;
        String methodName;
        int[] se = {min, i - 1};
        while (true) {
            i = findAfter(chars, LeftBrackets, i, chars.length);
            if (i < 0)
                return -1;
            se[1] = i - 1;
            methodName = getKeyWordFromEnd(chars, se);
            if (methodName.charAt(0) == AT) {
                i ++;
                if (!setMin) {
                    setMin = true;
                    min = se[0];
                }
                continue;
            }
            break;
        }
        se[1] = se[0];
        se[0] = min;
        String returnName = getKeyWordFromEnd(chars, se);
        int methodEnd = getMethodEnd(chars, i + 1);
        if (returnName.isEmpty() || isModify(returnName)) {
            if (className.equals(methodName)) {
                parseConstructor(chars, min, i - methodName.length(), methodEnd);
            }
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
        int firstAt = 0;
        while ((firstAt = findBefore(chars, AT, se[0], min)) > 0) {
            se[0] = firstAt - 1;
            if (firstAt == min) {
                break;
            }
        }
        if (chars[min] != AT)
            min = se[0] + 1;

        List<Annotation> annotations = Annotation.parseMultiAnnotation(new String(chars, min, i - min-2));

        /// 读方法参数
        List<Type> params = parseMethodParams(chars, i, methodEnd);

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

    public static List<Type> parseMethodParams(char[] chars, int bStart, int max) {
        int bEnd = ++bStart;
        while (chars[bEnd] != RightBrackets) {
            bEnd ++;
        }
        List<Type> ret = new ArrayList<>();
        if (bEnd > max)
            return ret;
        int i = bStart;
        int inBrackets = 0;
        while (i < bEnd) {
            char c = chars[i];
            if (c == LeftAngleBrackets) {
                inBrackets ++;
            } else if (c == RightAngleBrackets) {
                inBrackets --;
                i ++;
                continue;
            } else if ((c == Comma || i == (bEnd - 1)) && inBrackets == 0) {
                int next = i + 1;
                ///跳过最后的空白
                int j = beforeBlank(chars, c == Comma ? i - 1 : i, bStart);
                if (j == -1)
                    break;
                ///跳过参数名称
                j = findBlankBefore(chars, j, bStart);
                if (j == -1)
                    break;
                ///跳过参数名称前的空白
                j = beforeBlank(chars, j, bStart);
                if (j == -1)
                    break;
                ///j->参数类型最后一个字符
                ///跳过开头空白
                bStart = afterBlank(chars, bStart, j);
                if (bStart == -1)
                    break;
                /// 如果有范型>结尾，则去掉范型
                if (chars[j] == RightAngleBrackets) {
                    j = findAfter(chars, LeftAngleBrackets, bStart, j);
                    if (j == -1)
                        break;
                    j --;
                }
                /// 如果有其他修饰符，如final，去掉
                int tidx;
                while ((tidx = findBlankAfter(chars, bStart, j)) != -1) {
                    bStart = tidx + 1;
                }
                Type t = Type.getType(new String(chars, bStart, j - bStart + 1));
                ret.add(t);
                bStart = next;
            }
            i ++;
        }
        return ret;
    }

    private int getMethodEnd(char[] chars, int s) {
        s = findAfter(chars, RightBrackets, s, chars.length);
        if (s < 0)
            return -1;
        int semIndex = findAfter(chars, Sem, s, chars.length);
        int BlockStartIndex = findAfter(chars, BlockStart, s, chars.length);
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
        end = findBlankBefore(chars, end, start);
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
        for (Annotation s : classAnnotation) {
            sb.append(s).append('\n');
        }
        if (isAbstract)
            sb.append("abstract ");
        sb.append("class ")
                .append(packageName).append('.').append(className).append('\n');
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
