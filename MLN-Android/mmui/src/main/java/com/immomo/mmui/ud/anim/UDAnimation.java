/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.anim.animations.ObjectAnimation;
import com.immomo.mmui.anim.animations.SpringAnimation;
import com.immomo.mmui.anim.animations.ValueAnimation;
import com.immomo.mmui.anim.base.Animation;
import com.immomo.mmui.anim.base.PropertyName;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ud.constants.AnimProperty;
import com.immomo.mmui.ud.constants.Timing;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaClass
public class UDAnimation extends UDBaseAnimation {

    public static final String LUA_CLASS_NAME = "ObjectAnimation";

    private int duration;
    private int property;
    private UDView target;
    private List<Object> froms = new ArrayList<>();
    private List<Object> tos = new ArrayList<>();


    private final static String VELOCITY = "Velocity";
    private final static String BOUNCINESS = "Bounciness";
    private final static String SPEED = "Speed";
    private final static String TENSION = "Tension";
    private final static String FRICTION = "Friction";
    private final static String MASS = "Mass";

    // 必须有此构造函数
    public UDAnimation(Globals globals, LuaValue[] init) {
        super(globals, init);
        property = init[0].toInt();
        target = (UDView) init[1].toUserdata();
    }

    // lua虚拟机清除相关userdata时，会调用此方法，可无
    public void __onLuaGc() {
    }

    @Override
    protected Animation defaultAnimation() {
        ObjectAnimation animation = new ObjectAnimation(target.getView(), convertProperty(property));
        animation.setDuration(duration);
        animation.setTimingFunction(Animation.TimingFunction.DEFAULT);
        return animation;
    }

    @LuaBridge(alias = "duration", type = BridgeType.GETTER)
    public int getDuration() {
        return duration;
    }

    @LuaBridge(alias = "duration", type = BridgeType.SETTER)
    public void setDuration(int duration) {
        this.duration = duration;
    }

    @LuaBridge
    public UDView target() {
        return target;
    }

    @LuaBridge
    public void timing(int timing, LuaTable table) {
        if (timing == Timing.Spring) {
            SpringAnimation springAnimation = new SpringAnimation(target.getView(), convertProperty(property));
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
            animation = springAnimation;
        } else {
            ObjectAnimation objectAnimation = new ObjectAnimation(target.getView(), convertProperty(property));
            objectAnimation.setTimingFunction(convertTiming(timing));
            animation = objectAnimation;
        }
    }

    @Override
    public Animation getAnimation() {
        super.getAnimation();
        if (animation instanceof ObjectAnimation) {
            ((ObjectAnimation) animation).setDuration(duration);
        }
        int fSize = froms.size();
        int tSize = tos.size();
        int size = Math.max(fSize, tSize);
        if (size == 1 && tos.get(0) instanceof UDColor) {
            if (fSize == 1) {
                ((ValueAnimation) animation).setColorFromValue(((UDColor) froms.get(0)).getColor());
            }
            ((ValueAnimation) animation).setColorToValue(((UDColor) tos.get(0)).getColor());
        } else if (size == 1) {
            if (fSize == 1) {
                ((ValueAnimation) animation).setFromValue(value(froms, 0));
            }
            ((ValueAnimation) animation).setToValue(value(tos, 0));
        } else if (size == 2) {
            if (fSize == 2) {
                ((ValueAnimation) animation).setFromValue(value(froms, 0), value(froms, 1));
            }
            if (tSize == 2) {
                ((ValueAnimation) animation).setToValue(value(tos, 0), value(tos, 1));
            }
        } else {
            if (fSize == 4) {
                ((ValueAnimation) animation).setFromValue(value(froms, 0), value(froms, 1), value(froms, 2), value(froms, 3));
            }
            if (tSize == 4) {
                ((ValueAnimation) animation).setToValue(value(tos, 0), value(tos, 1), value(tos, 2), value(tos, 3));
            }
        }
        return animation;
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

    @LuaBridge
    public int property() {
        return property;
    }

    @LuaBridge
    public void from(LuaValue value1, Float value2, Float value3, Float value4) {
        froms.clear();
        if (value1 != null) {
            if (value1.isNumber()) {
                froms.add(value1.toFloat());
            } else if (value1.isUserdata()) {
                froms.add(value1.toUserdata());
            }
        }
        if (value2 != null) {
            froms.add(value2);
        }
        if (value3 != null) {
            froms.add(value3);
        }
        if (value4 != null) {
            froms.add(value4);
        }
    }

    @LuaBridge
    public void to(LuaValue value1, Float value2, Float value3, Float value4) {
        tos.clear();
        if (value1 != null) {
            if (value1.isNumber()) {
                tos.add(value1.toFloat());
            } else if (value1.isUserdata()) {
                tos.add(value1.toUserdata());
            }
        }
        if (value2 != null) {
            tos.add(value2);
        }
        if (value3 != null) {
            tos.add(value3);
        }
        if (value4 != null) {
            tos.add(value4);
        }
    }

    @LuaBridge
    public void addInteractiveBehavior(UDInteractiveBehavior interactiveBehavior) {
        interactiveBehavior.setAnimation((ObjectAnimation) getAnimation());
    }

    @Override
    public void repeat(Animation animation, int count) {
        if (repeatCallback != null) {
            repeatCallback.call(this, count);
        }
    }

    private String convertProperty(int property) {
        String p = "";
        switch (property) {
            case AnimProperty.Alpha:
                p = PropertyName.K_MLAVIEW_ALPHA;
                break;
            case AnimProperty.Color:
                p = PropertyName.K_MLAVIEW_COLOR;
                break;
            case AnimProperty.Position:
                p = PropertyName.K_MLAVIEW_POSITION;
                break;
            case AnimProperty.PositionX:
                p = PropertyName.K_MLAVIEW_POSITION_X;
                break;
            case AnimProperty.PositionY:
                p = PropertyName.K_MLAVIEW_POSITION_Y;
                break;
            case AnimProperty.Scale:
                p = PropertyName.K_MLAVIEW_SCALE;
                break;
            case AnimProperty.ScaleX:
                p = PropertyName.K_MLAVIEW_SCALE_X;
                break;
            case AnimProperty.ScaleY:
                p = PropertyName.K_MLAVIEW_SCALE_Y;
                break;
            case AnimProperty.Rotation:
                p = PropertyName.K_MLAVIEW_ROTATION;
                break;
            case AnimProperty.RotationX:
                p = PropertyName.K_MLAVIEW_ROTATION_X;
                break;
            case AnimProperty.RotationY:
                p = PropertyName.K_MLAVIEW_ROTATION_Y;
                break;
            default:
                break;
        }
        return p;
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