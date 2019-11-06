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
    o.http = Http()
    o.http:setBaseUrl("http://api.immomo.com")
    o.postParams = Map()
    o.isCache = false
    return o
end

function _class:onCreate(contentView)

    local width = contentView:width()
    local height = contentView:height()

    local showLabel = Label()--显示结果
    local count = 0--监听数量
    --CachePolicy {
    --    API_ONLY = 0,               -- 不使用缓存,只从网络更新数据
    --    CACHE_THEN_API,             -- 先使用缓存，随后请求网络更新请求
    --    CACHE_OR_API,               -- 优先使用缓存，无法找到缓存时才连网更新
    --    CACHE_ONLY,                 -- 只读缓存
    --    REFRESH_CACHE_BY_API        -- 刷新网络后数据加入缓存
    --}




    ------------------------------Http 实践 Demo Start------------------------------
    ----
    function _class:sendRightUrl(url)

        showLabel:text("请求中...." .. tostring(self.postParams))

        self.http:post(url, self.postParams, function(success, resp, error)
            self.postParams = Map()
            if success and resp then
                print("keye keye", resp:get("__isCache"))
                if resp:get("__isCache") then
                    self.isCache = true
                end

                showLabel:text("cachePolicy：" .. tostring(self.postParams:get("cachePolicy")) .. "\n\nencType：" .. tostring(self.postParams:get("encType")) .. "\n\nUrl: " .. tostring(url) .. "\n\nsuccess: " .. tostring(success) .. "\n\nhasCache: " .. tostring(self.isCache) .. "\n\nreps: \n" .. tostring(resp))
            else
                showLabel:text("cachePolicy：" .. tostring(self.postParams:get("cachePolicy")) .. "\n\nencType：" .. tostring(self.postParams:get("encType")) .. "\n\nUrl: " .. tostring(url) .. "\n\nsuccess: " .. tostring(success) .. "\n\nerror: \n" .. tostring(error))
            end
        end)
    end

    ----
    ------------------------------Http 实践 Demo End------------------------------


    ----以下代码不用管，显示UI用的
    local btnInfo = { "正确请求", "错误请求", "空param" }

    --初始化view
    local Desc = Label():text("请用陌陌客户端扫码测试"):fontSize(19):setAutoFit(true):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):x(10):y(50)
    contentView:addView(Desc)
    contentView:addView(demoUtils:initShowLabel(showLabel, width, height))

    local tabsContainer = demoUtils:createCommonTabLinearLayout(contentView)
    local tabs = demoUtils:addTabFromData(btnInfo, tabsContainer)

    for i, v in pairs(tabs) do
        if i == btnInfo[1] then
            v:onClick(function()
                self.postParams:put("cachePolicy", 1)
                self.postParams:put("encType", EncType.NORMAL)
                self.http:setBaseUrl("http://api.immomo.com")
                self:sendRightUrl("v1/nearby/index")
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                self.postParams:put("cachePolicy", 1)
                self.postParams:put("encType", EncType.NORMAL)
                self.http:setBaseUrl("")
                self:sendRightUrl("www.baidu.com")
            end)
        elseif i == btnInfo[3] then
            v:onClick(function()
                self.postParams = nil
                self.http:setBaseUrl("http://api.immomo.com")
                self:sendRightUrl("v1/nearby/index")
            end)
        end
    end
end

return _class