package com.immomo.mls;

import com.immomo.mls.util.ColorUtils;

import org.junit.Assert;
import org.junit.Test;

/**
 * Created by Xiong.Fangyu on 2019/4/24
 */
public class ColorTest {

    @Test
    public void testHexString() {
        final int color = 0xff3456ff;
        final String hexColorString = "#ff3456ff";
        final String iosColorString = "rgba(52,86,255,1)";
        Assert.assertEquals(hexColorString, ColorUtils.toHexColorString(color));

        Assert.assertEquals(iosColorString, ColorUtils.toRGBAColorString(color));
    }
}
