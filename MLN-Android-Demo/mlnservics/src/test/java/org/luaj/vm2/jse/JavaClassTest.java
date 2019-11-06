package org.luaj.vm2.jse;

import com.immomo.mls.Log;

/**
 * Created by Xiong.Fangyu on 2019-07-01
 */
public class JavaClassTest {

    public int aInt = 2;

    public float aFloat = 1.1f;

    public static int A_STATIC_INT = 3;

    public static int getInt() {
        return 1;
    }

    public static void doSomeThing(String s) {
        Log.i(s);
    }
}
