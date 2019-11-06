package com.immomo.mls;

import org.luaj.vm2.utils.SizeOfUtils;

import org.junit.Test;

/**
 * Created by Xiong.Fangyu on 2019-09-24
 */
public class SizeOfTest {

    @Test
    public void testClass() {
        final Class[] types = new Class[] {
                String.class,
                Object.class
        };

        for (Class clz : types) {
            Log.i("sizeof(" + clz + ") = " + SizeOfUtils.sizeof(clz));
        }
    }

    @Test
    public void testObject() {
        Runtime runtime = Runtime.getRuntime();
        A a;
        String str;
        long start, end;
        start = runtime.freeMemory();
        str = "abcdadkls;gjskl;gjakls;djglkasdjflk;asdjflk;adsk;fjaldks;jflk;adsjf";
        a = new A(new char[] {1,2,3,4});
        end = runtime.freeMemory();
        Log.i("sizeof(\"abcd\") = " + SizeOfUtils.sizeof(str) +
                " sizeof(a) = " + SizeOfUtils.sizeof(a) +
                " real size: " + start + " " + end);
    }

    final class A {
        char[] chars;
        A(char[] chars) {
            this.chars = chars;
        }
    }
}
