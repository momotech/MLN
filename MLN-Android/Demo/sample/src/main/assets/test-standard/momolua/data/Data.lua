---
--- 数据层 & lua-native通讯
--- Created by zhang.ke.
--- DateTime: 2018/11/20 上午11:11
---


local _class = {}
_class._version = '1.0'
_class._classname = 'Data'
_class.contentView = View()

local dataSource = { "momolua.data.demo.Http", "momolua.data.demo.GlobalEvent", "momolua.data.demo.File", "momolua.data.demo.DBUtils" , "momolua.data.demo.PreferenceUtils" }

local tabsContainer = demoUtils:createCommonTabLinearLayout(_class.contentView, Color(0, 0, 0, 1))
local demoContainer = View():y(60):height(screen_h - 60):width(screen_w)
_class.contentView:addView(demoContainer)


local tabs = demoUtils:addTabFromData(dataSource, tabsContainer)

for i, v in pairs(tabs) do
    v:onClick(function()
        print("keye",i)
        local model = require(i)
        local demo = model:new()
        demoContainer:removeAllSubviews()
        demo:onCreate(demoContainer)
    end)
end

function _class:setCommonBackBtn(commonBackBtn)
    commonBackBtn:removeFromSuper()
    tabsContainer:insertView(commonBackBtn,0)
end

--
--httpDemoModle = require("momolua.demo.Http")
--
--local httpDemo = httpDemoModle:new()
--httpDemo:onCreate(demoContainer)
return _class