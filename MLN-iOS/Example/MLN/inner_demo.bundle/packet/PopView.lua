---
--- PopView是Lua中，用于在lua的window上，弹出各种toast、progress、loadding、dialog的基础组件。
--- Created by zhang.ke
--- DateTime: 2020-04-20 17:43
---

local _class = {}
_class._type = 'ui'
_class._version = '1.0'
_class._classname = 'PopView'

function PopView(o)
   return _class:new(o)
end

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.contentView = nil
    self.mGravity = Gravity.CENTER
    self.mMarginLeft = 0
    self.mMarginBottom = 0
    self.mMarginRight = 0
    self.mMarginTop = 0
    return o
end

----Factory Method
function _class:toast(msg, duration)
    if duration > 3 then
        duration = 3;
    end

    local gravity = MBit:bor(Gravity.CENTER_HORIZONTAL, Gravity.BOTTOM)
    local marginBottom = (window:height() == 0) and 80 or window:height() * 0.1
    local verPadding = 8
    local horPadding = 14
    local corner = 6

    local toastContent = Label():text(msg):textAlign(TextAlign.CENTER):padding(verPadding, horPadding, verPadding, horPadding)
                                :cornerRadius(corner):textColor(Color(255, 255, 255))
                                :bgColor(Color(0, 0, 0, 0.8))
    --绑定自定义视图
    self:setContent(toastContent)
    self:setGravity(gravity)
    self:marginBottom(marginBottom)
    --show的时候触发动画
    self:willAppear(function(content)
        local anim = AlphaAnimation(0, 1)
        anim:setDuration(0.3)
        anim:setEndCallback(function(isFinished)

            System:setTimeOut(function()
                local animout = AlphaAnimation(1, 0)
                animout:setDuration(0.3)
                animout:setEndCallback(function()
                    self:hide()
                end)
                content:startAnimation(animout)
            end, duration)
        end)
        content:startAnimation(anim)

    end)
    self:show()
end

function _class:buildLoading(path)
    --容器view
    local loadingContent = ImageView():width(50):height(50):image(path)
    --绑定自定义视图
    self:setContent(loadingContent)
    self:setGravity(Gravity.CENTER)
    --show的时候触发动画
    self:willAppear(function(content)
        self.anim = RotateAnimation(0, 360)
        self.anim:setDuration(1)
        self.anim:setRepeat(RepeatType.FROM_START, -1)
        content:startAnimation(self.anim)
    end)
    self:willDisappear(function(content)
        if self.anim then
           self.anim:cancel()
        end
    end)
    return self
end

function _class:buildDialog()
    self:willAppear(
            function(content)
                local anim = AlphaAnimation(0, 1)
                anim:setDuration(0.1)
                content:startAnimation(anim)
            end)

    --创建阴影容器
    self.dialogContainer = View():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):bgColor(Color(0, 0, 0, 0.5))
    self.dialogContainer:onClick(function()
        self:hide()
    end)
    function self:setContent(contentView)
        --重写方法，让contentView指向阴影容器, 用户的contentView放入阴影容器内
        self.contentView = contentView;
        self.contentView:onClick(function()
        end)
        return self
    end

    function self:show(notAdd)--notAdd不添加到window， 兼容mlnui的 ui{} 自动add到window
        if self.dialogContainer then
            self.dialogContainer:removeFromSuper()
            self.contentView:removeFromSuper()

            self:setProperties()
            if not notAdd then
                self.dialogContainer:addView(self.contentView)
                window:addView(self.dialogContainer)
            end
            if self.appearBlock then
                self.appearBlock(self.dialogContainer)
            end
        else
            print("No contentView in PopView")
        end
        return self
    end

    --隐藏
    function self:hide()
        if self.dialogContainer then
            if self.disappearBlock then
                self.disappearBlock(self.dialogContainer)
            end
            self.dialogContainer:removeFromSuper()
        end
        return self
    end

    function self:setProperties()
        --重写方法，让setGravity指向dialogContentView
        if self.contentView then
            self.contentView:marginLeft(self.mMarginLeft)
            self.contentView:marginBottom(self.mMarginBottom)
            self.contentView:marginRight(self.mMarginRight)
            self.contentView:marginTop(self.mMarginTop)
        end
        if self.dialogContentView then
            self.dialogContentView:setGravity(self.mGravity)
        end
    end
    return self
end

---- Factory Method END


----Basic Method
--显示
function _class:show()
    if self.contentView then
        self.contentView:removeFromSuper()
        self:setProperties()
        window:addView(self.contentView)
        if self.appearBlock then
            self.appearBlock(self.contentView)
        end
    else
        print("No contentView in PopView")
    end
    return self
end

--隐藏
function _class:hide()
    if self.contentView then
        if self.disappearBlock then
            self.disappearBlock(self.contentView)
        end
        self.contentView:removeFromSuper()
    end
    return self
end

--显示的内容-设置提示的内容
function _class:setContent(contentView)
    self.contentView = contentView;
    return self
end

--对其枚举-设置对齐方向
function _class:setGravity(gravity)
    self.mGravity = gravity
    return self
end

--外间距-设置Left外间距
function _class:marginLeft(value)
    self.mMarginLeft = value
    return self
end

--外间距-设置Top外间距
function _class:marginTop(value)
    self.mMarginTop = value
    return self
end

--外间距-设置Right外间距
function _class:marginRight(value)
    self.mMarginRight = value
    return self
end

--外间距-设置Bottom外间距
function _class:marginBottom(value)
    self.mMarginBottom = value
    return self
end

--显示回调
function _class:willAppear(appearBlock)
    self.appearBlock = appearBlock;
    return self
end

--消失回调
function _class:willDisappear(disappearBlock)
    self.disappearBlock = disappearBlock;
    return self
end

function _class:setProperties()
    if self.contentView then
        self.contentView:marginLeft(self.mMarginLeft)
        self.contentView:marginBottom(self.mMarginBottom)
        self.contentView:marginRight(self.mMarginRight)
        self.contentView:marginTop(self.mMarginTop)
        self.contentView:setGravity(self.mGravity)
    end
end

return _class
