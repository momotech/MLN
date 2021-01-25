package com.immomo.mls;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/8/4 上午10:54
 */
public class MapTest {
    @Test
    public void testHashCast() throws Exception {
        ViewModel viewModel = new ViewModel();
        System.out.println("float--->" + viewModel.a + "byte--->" + viewModel.b + "long---->" + viewModel.c + "short---->" + viewModel.d
        +"double--->" + viewModel.e + "boolean---->" + viewModel.f + "int----->" + viewModel.g + "char--->" + viewModel.z);

    }

    public class ViewModel {
        public float a;
        public byte b;
        public long c;
        public short d;
        public double e;
        public boolean f;
        public int g;
        public char z;

        Map<String,Object> map = new HashMap<>();
        public String getAge() {
           Object age = map.get("age");
           return (String)age;
        }
    }

}
