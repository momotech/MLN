---
--- Http
--- 实现案例
--- Created by zhang.ke.
--- DateTime: 2018/11/20 上午11:11
---'
local _class = {}
_class._version = '1.0'
_class._classname = ''
_class.http = nil
_class.postParams = nil
_class.isCache = nil

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function _class:onCreate(contentView)

    local width = contentView:width()
    local height = contentView:height()

    local showLabel = Label()--显示结果
    ------------------------------PreferenceUtils 实践 Demo Start------------------------------
    function _class:save(key, value)
        PreferenceUtils:save(key, value)
        showLabel:text("Save\n\nkey: " .. key .. "\n\nvalue: " .. value)
    end

    function _class:get(key, default)
        local value = PreferenceUtils:get(key, default)
        showLabel:text("Get\n\nkey: " .. key .. "\n\nvalue: " .. value.. "\n\ndefault: " .. default)
    end
    ------------------------------PreferenceUtils 实践 Demo End------------------------------


    ----以下代码不用管，显示UI用的
    local btnInfo = { "save", "get" }

    --初始化view
    local Desc = Label():text("Info"):fontSize(19):setAutoFit(true):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):x(10):y(50)
    contentView:addView(Desc)
    local editLabal = EditTextView():text("value 23333"):fontSize(19):setAutoFit(true):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):x(10):y(75)
    contentView:addView(editLabal)
    local msgEdit = EditTextView():text("default 23333"):fontSize(19):setAutoFit(true):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):x(10):y(105)
    contentView:addView(msgEdit)
    contentView:addView(demoUtils:initShowLabel(showLabel, width, height*0.6))

    local tabsContainer = demoUtils:createCommonTabLinearLayout(contentView)
    local tabs = demoUtils:addTabFromData(btnInfo, tabsContainer)

    for i, v in pairs(tabs) do
        if i == btnInfo[1] then
            v:onClick(function()
                _class:save("momo",editLabal:text())
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                _class:get("momo",msgEdit:text())
            end)
        end
    end
end

return _class