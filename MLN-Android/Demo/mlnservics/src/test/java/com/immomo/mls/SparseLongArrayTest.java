package com.immomo.mls;

import com.immomo.mls.utils.sparse.SparseLongArray;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

/**
 * Created by Xiong.Fangyu on 2019-05-20
 */
public class SparseLongArrayTest {

    private SparseLongArray array;

    @Before
    public void init() {
        array = new SparseLongArray();
        array.put(2, 2);
        array.put(1, 1);
        array.put(3,3);
        array.put(4,4);
        array.put(5,5);
        array.put(6, 111);
    }

    @Test
    public void testRemove() {
        final int len = array.size();
        array.delete(10);
        assertEquals(len, array.size());
        array.delete(1);
        assertEquals(len - 1, array.size());
    }

    @Test
    public void testRemoveFrom() {
        final int len = array.size();
        array.removeFrom(4);
        assertEquals(4, array.size());
    }
}
