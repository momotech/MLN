package com.immomo.demo;

import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.annotation.MLN;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.Map;

@MLN(convertClass = UDCameraSetting.class)
@LuaClass
public class UDCameraSetting {
    public static final String LUA_CLASS_NAME = "CameraSetting";

    public int bitRate;
    public int frameRate;
    public int resolution;
    public int videoScale;

    @LuaBridge(alias = "bitRate", type = BridgeType.GETTER)
    public int getBitRate() {
        return bitRate;
    }

    @LuaBridge(alias = "bitRate", type = BridgeType.SETTER)
    public void setBitRate(int bitRate) {
        this.bitRate = bitRate;
    }

    @LuaBridge(alias = "frameRate", type = BridgeType.GETTER)
    public int getFrameRate() {
        return frameRate;
    }

    @LuaBridge(alias = "frameRate", type = BridgeType.SETTER)
    public void setFrameRate(int frameRate) {
        this.frameRate = frameRate;
    }

    @LuaBridge(alias = "resolution", type = BridgeType.GETTER)
    public int getResolution() {
        return resolution;
    }

    @LuaBridge(alias = "resolution", type = BridgeType.SETTER)
    public void setResolution(int resolution) {
        this.resolution = resolution;
    }

    @LuaBridge(alias = "videoScale", type = BridgeType.GETTER)
    public int getVideoScale() {
        return videoScale;
    }

    @LuaBridge(alias = "videoScale", type = BridgeType.SETTER)
    public void setVideoScale(int videoScale) {
        this.videoScale = videoScale;
    }

    public static final ILuaValueGetter<UDCameraSetting_udwrapper, UDCameraSetting> G = new ILuaValueGetter<UDCameraSetting_udwrapper, UDCameraSetting>() {
        @Override
        public UDCameraSetting_udwrapper newInstance(Globals g, UDCameraSetting obj) {
            return new UDCameraSetting_udwrapper(g, obj);
        }
    };

    public static final IJavaObjectGetter<LuaValue, UDCameraSetting> J = new IJavaObjectGetter<LuaValue, UDCameraSetting>() {
        @Override
        public UDCameraSetting getJavaObject(LuaValue lv) {
//            if (lv.isTable())
//                return table 转 setting);
            return ((UDCameraSetting_udwrapper) lv).getJavaUserdata();
        }
    };
}
