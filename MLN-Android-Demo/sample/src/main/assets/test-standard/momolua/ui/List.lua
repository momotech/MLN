---
--- UI层
--- Created by zhang.ke.
--- DateTime: 2018/11/20 上午11:11
---


local _class = {}
_class._version = '1.0'
_class._classname = 'Ui'
_class.contentView = View()

local dataSource = { "momolua.ui.demo.NewGridView", "momolua.ui.demo.NewListView" , "momolua.ui.demo.NewRecyclerView" , "momolua.ui.demo.TestHCollectionView" }

local tabsContainer = demoUtils:createCommonTabLinearLayout(_class.contentView, Color(0, 0, 0, 1))
local demoContainer = View():y(60):height(screen_h - 60):width(screen_w)
_class.contentView:addView(demoContainer)


local tabs = demoUtils:addTabFromData(dataSource, tabsContainer)

for i, v in pairs(tabs) do
    v:onClick(function()
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