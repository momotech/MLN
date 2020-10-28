/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.weight.newui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by zhang.ke
 * on 2020-03-11
 * 占位View，配合VStack、ZStack使用
 */
public class Spacer extends View implements ISpacer {
    private boolean isHorExPand = true;
    private boolean isVerExPand = true;

    public Spacer(Context context) {
        super(context);
    }

    public Spacer(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public Spacer(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    public void setHorExPand(boolean horExPand) {
        isHorExPand = horExPand;
    }

    public void setVerExPand(boolean verExPand) {
        isVerExPand = verExPand;
    }

    @Override
    public boolean isVerExpand() {
        return isVerExPand;
    }

    @Override
    public boolean isHorExpand() {
        return isHorExPand;
    }
}
