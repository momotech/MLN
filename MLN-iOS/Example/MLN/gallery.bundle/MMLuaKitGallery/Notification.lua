
local _class = {
    _name = 'notification',
    _version = '1.0'
}

---@public
function _class:new()
    local o = {}
    setmetatable(o, { __index = self })
    self.dataList = Array()
    self.pageIndex = 1
    self.type = 1
    return o
end

---优先加载其他辅助文件
---@private
function _class:loadExtensions()
    require("MMLuaKitGallery.Constant")
end

---@public
function _class:rootView()
    if self.containerView then
        return self.containerView
    end

    self:loadExtensions()
    self:createSubviews()

    return self.containerView
end



---@private
function _class:createSubviews()
    self:setupContainerView()
    self:setupTitleView()
    self:contentView()
end

---容器视图
---@public
function _class:setupContainerView()
    self.containerView = LinearLayout(LinearType.VERTICAL)
    self.containerView:width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):bgColor(ColorConstants.White)
end


---导航栏视图
---@public
function _class:setupTitleView()
    --导航栏
    self.navigation = require("MMLuaKitGallery.NavigationBar"):new()
    self.navibar = self.navigation:bar("通知", nil)
    self.containerView:addView(self.navibar)

    --返回
    self.backBtn = ImageView():width(22):height(22):marginLeft(20):setGravity(MBit:bor(Gravity.LEFT, Gravity.CENTER_VERTICAL))
    self.backBtn:image("back")
    self.navibar:addView(self.backBtn)

end

-- 没有内容 视图
function _class:contentView()
    self.noContentView = require("MMLuaKitGallery.NoContentView"):new()
    self.containerView:addView(self.noContentView:contentView())
end


_class:new()
window:addView(_class:rootView())

return _class