---
--- Generated by Momo 
--- Created by MOMO.
--- DateTime: 2018/11/21
---

local _class = {}
_class._version = '1.0'
_class._classname = 'LocationManagerDemo'

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function _class:onCreate(contentView)

    local width = contentView:width()
    local height = contentView:height()

    local scrollView = ScrollView():height(height - 60):width(width):y(60)
    local Desc = Label():text("请用陌陌客户端扫码测试"):fontSize(19):setAutoFit(true):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):x(10)
    contentView:addView(Desc)
    local showLabel = Label()--显示结果
    showLabel = demoUtils:initShowLabel(showLabel, width, height)
    showLabel:setAutoFit(true):y(0)
    scrollView:addView(showLabel)
    contentView:addView(scrollView)

    local showText = "";

    if System:Android() then
        print(" >>>>定位bridge在客户端，请用客户端扫码\n\n")
        showText = showText .. " >>>>定位bridge在客户端，请用客户端扫码\n\n"
        showLabel:text(showText)
    end

    local point = LocationManager:userLocation()

    print("pointX:", point:x(), " pointY:", point:y())
    showText = showText .. "userLocation:\npointX: " .. tostring(point:x()) .. " pointY: " .. tostring(point:y()) .. "\n\n"
    showLabel:text(showText)

    LocationManager:updateLocation(function(paramDict)
        print("paramDic:", paramDict)
        showText = showText .. "updateLocation:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    LocationManager:getLocationCacheWithType(1, function(paramDict)
        print("paramDict1:", paramDict)
        showText = showText .. "getLocationCacheWithType:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    LocationManager:getLocationCacheWithType(2, function(paramDict)
        print("paramDict2:", paramDict)
        showText = showText .. "getLocationCacheWithType:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    LocationManager:getLocationCacheWithType(3, function(paramDict)
        print("paramDict3:", paramDict)
        showText = showText .. "getLocationCacheWithType:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    LocationManager:getLocationCacheWithType(4, function(paramDict)
        print("paramDict4:", paramDict)
        showText = showText .. "getLocationCacheWithType:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    LocationManager:getLocationCacheWithType(5, function(paramDict)
        print("paramDict5:", paramDict)
        showText = showText .. "getLocationCacheWithType:" .. tostring(paramDict) .. "\n\n"
        showLabel:text(showText)
    end)

    local map = Map()
    map:put("state", "定位失败了")

    LocationManager:showLocationErrorAlert(map)

end

return _class