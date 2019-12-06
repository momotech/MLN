local _class = {
    _name = 'CustomerService',
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
    self.navibar = self.navigation:bar("私聊", nil)
    self.containerView:addView(self.navibar)

    --返回
    self.backBtn = ImageView():width(22):height(22):marginLeft(20):setGravity(MBit:bor(Gravity.LEFT, Gravity.CENTER_VERTICAL))
    self.backBtn:image("https://s.momocdn.com/w/u/others/custom/20191107/wutianlong/x9.png")
    self.navibar:addView(self.backBtn)

    --客服
    self.customer = ImageView():width(22):height(22):marginRight(20):setGravity(MBit:bor(Gravity.RIGHT, Gravity.CENTER_VERTICAL))
    self.customer:image("https://s.momocdn.com/w/u/others/2019/09/01/1567316383469-minshare.png")
    --self.navibar:addView(self.customer)

end

-- 没有内容 视图
function _class:contentView()
    self.noContentView = require("MMLuaKitGallery.NoContentView"):new()
    self.containerView:addView(self.noContentView:contentView())
end


_class:new()
window:addView(_class:rootView())

return _class