package com.immomo.mls;

import com.immomo.mls.util.FileUtil;

import org.junit.Assert;
import org.junit.Test;
import org.luaj.vm2.utils.MemoryMonitor;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019-05-17
 */
public class OtherTest {

    @Test
    public void testMemoryStr() {
        long memory = 123634612534154l;
        String s = MemoryMonitor.getMemorySizeString(memory);
        Log.i(s);
    }

    @Test
    public void testFile() {
        final String parents[] = {
                "a/b/c",            //0
                "a/b/c/",           //1
                "../a/b/c",         //2
                "a/b/c",            //3
                "a/b/c",            //4
                "a/b/c",            //5
                "a/b/c",            //6
                "a/b/c",            //7
                "a/b/c",            //8
                "",                 //9
                "a",
        };
        final String names[] = {
                "d/e",              //0
                "/d/e",             //1
                "./d/e",            //2
                "../d/e",           //3
                "../../d/e",        //4
                "../../../d/e",     //5
                "../../../../d/e",  //6
                "../d/../e",        //7
                "d/../e",           //8
                "../d/e",           //9
                "../d"
        };
        final String aspects[] = {
                "a/b/c/d/e",        //0
                "a/b/c/d/e",        //1
                "../a/b/c/d/e",     //2
                "a/b/d/e",          //3
                "a/d/e",            //4
                "d/e",              //5
                "../d/e",           //6
                "a/b/e",            //7
                "a/b/c/e",          //8
                "../d/e",           //9
                "d"
        };
        for (int i = 0; i < parents.length; i ++) {
            System.out.println("time:" + i);
            Assert.assertEquals(aspects[i], FileUtil.dealRelativePath(parents[i], names[i]));
        }
    }
}
