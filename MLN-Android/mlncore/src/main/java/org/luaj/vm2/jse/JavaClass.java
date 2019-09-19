/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.jse;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.LuaApiUsed;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * luaj helper
 */
public final class JavaClass extends JavaInstance<Class> {
    public static final String LUA_CLASS_NAME = "__JavaClass";

    private Map<String, Field> fields;
    private Map<String, List<Method>> methods;
    private List<Constructor> constructors;
    private Map<String, Class> innerclasses;

    private static final Map<Class, JavaClass> classes = new HashMap<>();

    private JavaClass(Globals g, Object jud) {
        super(g, jud);
        jclass = this;
    }

    @Override
    protected String initLuaClassName(Globals g) {
        return LUA_CLASS_NAME;
    }

    @Override
    @LuaApiUsed
    protected void __onLuaGc() {
        if (globals.isDestroyed()) {
            if (fields != null) fields.clear();
            if (methods != null) methods.clear();
            if (constructors != null) constructors.clear();
            if (innerclasses != null) innerclasses.clear();
            classes.remove((Class) javaUserdata);
        }
        super.__onLuaGc();
    }

    static JavaClass forClass(Globals g, Class c) {
        JavaClass j = classes.get(c);
        if (j == null)
            classes.put(c, j = new JavaClass(g, c));
        return j;
    }

    final Field getField(String key) {
        if (fields == null) {
            Map<String, Field> m = new HashMap<>();
            Field[] f = ((Class) javaUserdata).getFields();
            for (Field fi : f) {
                if (Modifier.isPublic(fi.getModifiers())) {
                    m.put(fi.getName(), fi);
                    try {
                        if (!fi.isAccessible())
                            fi.setAccessible(true);
                    } catch (SecurityException ignore) {
                    }
                }
            }
            fields = m;
        }
        return fields.get(key);
    }

    final List<Method> getMethod(String key) {
        if (methods == null) {
            Map<String, List<Method>> namedlists = new HashMap<>();
            Method[] m = ((Class) javaUserdata).getMethods();
            for (Method mi : m) {
                if (Modifier.isPublic(mi.getModifiers())) {
                    String name = mi.getName();
                    List<Method> list = namedlists.get(name);
                    if (list == null)
                        namedlists.put(name, list = new ArrayList<>());
                    list.add(mi);
                }
            }
            methods = namedlists;
        }
        return methods.get(key);
    }

    final Class getInnerClass(String key) {
        if (innerclasses == null) {
            Map<String, Class> m = new HashMap<>();
            Class[] c = ((Class) javaUserdata).getClasses();
            for (Class ci : c) {
                String name = ci.getName();
                String stub = name.substring(Math.max(name.lastIndexOf('$'), name.lastIndexOf('.')) + 1);
                m.put(stub, ci);
            }
            innerclasses = m;
        }
        return innerclasses.get(key);
    }

    final List<Constructor> getConstructor() {
        if (constructors == null) {
            Constructor[] cs = ((Class) javaUserdata).getConstructors();
            constructors = new ArrayList<>(cs.length);
            constructors.addAll(Arrays.asList(cs));
        }
        return constructors;
    }
}