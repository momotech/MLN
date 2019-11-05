package com.immomo.mls;

import org.junit.Test;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class ExampleUnitTest {
    @Test
    public void testHashCast() throws Exception {
        final String s = "askldfjaklg";
        final byte[] data = s.getBytes();
        final int len = data.length;
        int h;
        long start = now();
        long end;
        h = new String(data).hashCode();
        end = now();
        Log.i("java string hash code cast: " + (end - start));
        start = now();
        h = hashCode(data, len);
        end = now();
        Log.i("hash code cast: " + (end - start));
    }

    private static int hashCode(byte[] m_bytes, int m_length) {
        int h = m_length;  /* seed */
        int step = (m_length>>5)+1;  /* if string is too long, don't hash all its chars */
        for (int l1=m_length; l1>=step; l1-=step)  /* compute hash */
            h = h ^ ((h<<5)+(h>>2)+(((int) m_bytes[l1-1] ) & 0x0FF ));
        return h;
    }

    private static long now() {
        return System.nanoTime();
    }
}