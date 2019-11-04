---
--- 数据层 & lua-native通讯 / GlobalEvent(全局事件通知，可跨环境)
--- 实现案例
--- Created by zhang.ke.
--- DateTime: 2018/11/20 上午11:11
---

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

    local count = 0--监听数量
    local showLabel = Label()--显示结果

    ------------------------------GlobalEvent 实践 Demo Start------------------------------
    local KEY_GLOBALEVENT_TEST_EVENT = "key_globalevent_test_event"

    ----添加监听
    function addListener()
        GlobalEvent:addListener(KEY_GLOBALEVENT_TEST_EVENT, function(responeMap)
            showLabel:text("监听数量：" .. count .. " \n 接收到Event \n key: " .. KEY_GLOBALEVENT_TEST_EVENT .. "\n value: " .. tostring(responeMap))
            print(Tag, "接收到Event \n key: " .. KEY_GLOBALEVENT_TEST_EVENT, "\n value: " .. tostring(responeMap))
        end)
    end

    ----发送Event
    function sendEvent()
        local params = Map()
        params:put("dst_l_evn", "lua")--固定key，标识event来源
        local msg = Map()
        msg:put('key1', 'value1')
        msg:put("momolua", "data.lua")
        msg:put("luasdk", "globalEvent")
        params:put('event_msg', msg)--固定key，标识event msg
        GlobalEvent:postEvent(KEY_GLOBALEVENT_TEST_EVENT, params)
    end

    ----移除监听
    function removeLinster()
        GlobalEvent:removeEventListener(KEY_GLOBALEVENT_TEST_EVENT)
    end
    ------------------------------GlobalEvent 实践 Demo End------------------------------

    ----以下代码不用管，显示UI用的
    local btnInfo = { "添加监听", "发送Event", "移除监听" }

    --初始化view
    local Desc = Label():text("请用陌陌客户端扫码测试"):fontSize(19):setAutoFit(true):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):x(10):y(50)
    contentView:addView(Desc)
    contentView:addView(demoUtils:initShowLabel(showLabel, width, height))

    local tabsContainer = demoUtils:createCommonTabLinearLayout(contentView,nil)
    local tabs = demoUtils:addTabFromData(btnInfo, tabsContainer)

    for i, v in pairs(tabs) do
        if i == btnInfo[1] then
            v:onClick(function()
                addListener()
                count = count + 1
                showLabel:text("监听数量：" .. count)
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                sendEvent()
                if count > 0 then
                    showLabel:text("监听数量：" .. count)
                else
                    showLabel:text("监听数量：" .. count .. " 未监听")
                end
            end)
        elseif i == btnInfo[3] then
            v:onClick(function()
                removeLinster()
                if count > 0 then
                    count = count - 1
                end
                removeLinster()
                showLabel:text("监听数量：" .. count)
            end)
        end
    end

end
return _class