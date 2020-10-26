/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.anim.animations.ObjectAnimation;
import com.immomo.mmui.anim.animations.SpringAnimation;
import com.immomo.mmui.anim.animations.ValueAnimation;
import com.immomo.mmui.anim.base.Animation;
import com.immomo.mmui.ud.UDLabel;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ud.constants.AnimProperty;
import com.immomo.mmui.ud.constants.Timing;
import com.immomo.mmui.ud.recycler.UDRecyclerView;

import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaApiUsed
public class UDAnimation extends UDBaseAnimation {

    public static final String LUA_CLASS_NAME = "ObjectAnimation";

    private float duration;
    private final int property;
    private UDView target;
    private List<Object> froms = new ArrayList<>();
    private List<Object> tos = new ArrayList<>();

    private final static String VELOCITY = "Velocity";
    private final static String BOUNCINESS = "Bounciness";
    private final static String SPEED = "Speed";
    private final static String TENSION = "Tension";
    private final static String FRICTION = "Friction";
    private final static String MASS = "Mass";

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDAnimation(long L, int property, UDView target) {
        super(L);
        this.property = property;
        this.target = target;
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    @Override
    protected Animation defaultAnimation() {
        ObjectAnimation animation = new ObjectAnimation(target.getView(), property);
        animation.setDuration(duration);
        animation.setTimingFunction(Animation.TimingFunction.DEFAULT);
        return animation;
    }

    @LuaApiUsed
    public float getDuration() {
        return duration;
    }

    @LuaApiUsed
    public void setDuration(float duration) {
        this.duration = duration;
    }

    @LuaApiUsed
    public UDView target() {
        return target;
    }

    @LuaApiUsed
    public void timing(int timing, LuaTable table) {
        if (timing == Timing.Spring) {
            SpringAnimation springAnimation = new SpringAnimation(target.getView(), property);
            if (table != null) {
                LuaValue velocity = table.get(VELOCITY);
                LuaValue bounciness = table.get(BOUNCINESS);
                LuaValue speed = table.get(SPEED);
                LuaValue tension = table.get(TENSION);
                LuaValue friction = table.get(FRICTION);
                LuaValue mass = table.get(MASS);
                if (!velocity.isNil()) {
                    LuaTable luaTable = velocity.toLuaTable();
                    if (luaTable.size() == 2) {
                        springAnimation.setCurrentVelocityS(luaTable.get(1).toFloat(), luaTable.get(2).toFloat());
                    }
                    if (luaTable.size() == 1) {
                        springAnimation.setCurrentVelocityS(luaTable.get(1).toFloat());
                    }
                }
                if (!bounciness.isNil()) {
                    springAnimation.setSpringBounciness(bounciness.toFloat());
                }
                if (!speed.isNil()) {
                    springAnimation.setSpringSpeed(speed.toFloat());
                }
                if (!tension.isNil()) {
                    springAnimation.setTension(tension.toFloat());
                }
                if (!friction.isNil()) {
                    springAnimation.setFriction(friction.toFloat());
                }
                if (!mass.isNil()) {
                    springAnimation.setMass(mass.toFloat());
                }
            }
            javaUserdata = springAnimation;
        } else {
            ObjectAnimation objectAnimation = new ObjectAnimation(target.getView(), property);
            objectAnimation.setTimingFunction(convertTiming(timing));
            javaUserdata = objectAnimation;
        }
    }

    @Override
    public Animation getJavaUserdata() {
        super.getJavaUserdata();
        if (javaUserdata instanceof ObjectAnimation) {
            ((ObjectAnimation) javaUserdata).setDuration(duration);
        }
        int fSize = froms.size();
        int tSize = tos.size();
        int size = Math.max(fSize, tSize);
        if (size == 1) {
            if (fSize == 1) {
                ((ValueAnimation) javaUserdata).setFromValue(value(froms, 0));
            }
            ((ValueAnimation) javaUserdata).setToValue(value(tos, 0));
        } else if (size == 2) {
            if (fSize == 2) {
                ((ValueAnimation) javaUserdata).setFromValue(value(froms, 0), value(froms, 1));
            }
            if (tSize == 2) {
                ((ValueAnimation) javaUserdata).setToValue(value(tos, 0), value(tos, 1));
            }
        } else if (size == 4 && (property == AnimProperty.Color || property == AnimProperty.TextColor)) {
            if (fSize == 4) {
                ((ValueAnimation) javaUserdata).setFromValue(value(froms, 3) * 255, value(froms, 0), value(froms, 1), value(froms, 2));
            }
            ((ValueAnimation) javaUserdata).setToValue(value(tos, 3) * 255, value(tos, 0), value(tos, 1), value(tos, 2));
        } else {
            if (fSize == 4) {
                ((ValueAnimation) javaUserdata).setFromValue(value(froms, 0), value(froms, 1), value(froms, 2), value(froms, 3));
            }
            if (tSize == 4) {
                ((ValueAnimation) javaUserdata).setToValue(value(tos, 0), value(tos, 1), value(tos, 2), value(tos, 3));
            }
        }
        if (property == AnimProperty.ContentOffset && (!(target instanceof UDRecyclerView) && !(target instanceof UDScrollView))) {
            ErrorUtils.debugUnsupportError("The ContentOffset animation type is only valid for ScrollView、TableView、ViewPager and CollectionView.");
        }
        if (property == AnimProperty.TextColor && !(target instanceof UDLabel)) {
            ErrorUtils.debugUnsupportError("The TextColor animation type is only valid for Label.");
        }
        return javaUserdata;
    }

    private float value(List<Object> list, int index) {
        float value = 0;
        if (list.size() > index && list.get(index) != null) {
            Object o = list.get(index);
            if (o instanceof Float) {
                value = (float) o;
            }
            if (property == AnimProperty.Position || property == AnimProperty.PositionX || property == AnimProperty.PositionY) {
                value = DimenUtil.dpiToPx(value);
            }
        }
        return value;
    }

    @LuaApiUsed
    public int property() {
        return property;
    }

    @LuaApiUsed
    public void from(LuaValue value1, LuaValue value2, LuaValue value3, LuaValue value4) {
        froms.clear();
        if (value1 != null) {
            if (value1.isNumber()) {
                froms.add(value1.toFloat());
            } else if (value1.isUserdata()) {
                froms.add(value1.toUserdata());
            }
        }
        if (value2 != null && value2.isNumber()) {
            froms.add(value2.toFloat());
        }
        if (value3 != null && value3.isNumber()) {
            froms.add(value3.toFloat());
        }
        if (value4 != null && value4.isNumber()) {
            froms.add(value4.toFloat());
        }
    }

    @LuaApiUsed
    public void to(LuaValue value1, LuaValue value2, LuaValue value3, LuaValue value4) {
        tos.clear();
        if (value1 != null) {
            if (value1.isNumber()) {
                tos.add(value1.toFloat());
            } else if (value1.isUserdata()) {
                tos.add(value1.toUserdata());
            }
        }
        if (value2 != null && value2.isNumber()) {
            tos.add(value2.toFloat());
        }
        if (value3 != null && value3.isNumber()) {
            tos.add(value3.toFloat());
        }
        if (value4 != null && value4.isNumber()) {
            tos.add(value4.toFloat());
        }
    }

    @LuaApiUsed
    public void addInteractiveBehavior(InteractiveBehavior interactiveBehavior) {
        interactiveBehavior.getJavaUserdata().setAnimation(this);
    }

    @Override
    public void repeat(Animation animation, int count) {
        if (repeatBlock != null) {
            repeatBlock.invoke(varargsOf(this, LuaNumber.valueOf(count)));
        }
    }

    private Animation.TimingFunction convertTiming(int timing) {
        Animation.TimingFunction function;
        switch (timing) {
            case Timing.Linear:
                function = Animation.TimingFunction.LINEAR;
                break;
            case Timing.EaseIn:
                function = Animation.TimingFunction.EASEIN;
                break;
            case Timing.EaseOut:
                function = Animation.TimingFunction.EASEOUT;
                break;
            case Timing.EaseInEaseOut:
                function = Animation.TimingFunction.EASEINOUT;
                break;
            default:
                function = Animation.TimingFunction.DEFAULT;
                break;
        }
        return function;
    }
}