package com.immomo.mls;


import com.immomo.mls.databinding.utils.ReflectUtils;

import org.junit.Test;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */

public class ExampleUnitTest {
    @Test
    public void testHashCast() throws Exception {
        Student student = new Student();
        student.name = "中北大学";


       //"com.xfy.demo.bean.School"

        System.out.println(ReflectUtils.getObjectByStr(student,"student.school.name"));

    }

}