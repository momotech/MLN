---
--- PopView是Lua中，用于在lua的window上，弹出各种toast、progress、loadding、dialog的基础组件。
--- Created by zhang.ke
--- DateTime: 2020-04-20 17:43
---

local _class = {}
_class._type = 'ui'
_class._version = '1.0'
_class._classname = 'PopView'
_class.__argoui_autoadd = false --argoui ui{}中，不自动添加到window开关。

function PopView(o)
    return _class:new(o)
end

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.contentView = nil
    self.crossAxis = CrossAxis.CENTER
    self.mMarginLeft = 0
    self.mMarginBottom = 0
    self.mMarginRight = 0
    self.mMarginTop = 0

    self.mPositionLeft = 0
    self.mPositionBottom = 0
    self.mPositionRight = 0
    self.mPositionTop = 0

    self.hasPositionLeft = nil
    self.hasPositionBottom = nil
    self.hasPositionRight = nil
    self.hasPositionTop = nil

    return o
end

----Factory Method
function _class:toast(msg, duration)
    if duration > 3 then
        duration = 3;
    end

    local crossAxis = CrossAxis.CENTER
    local positionBottom = (window:height() == 0) and 80 or window:height() * 0.1
    local verPadding = 8
    local horPadding = 14
    local corner = 6

    local toastContent = Label():text(msg):textAlign(TextAlign.CENTER):padding(verPadding, horPadding, verPadding, horPadding)
                                :cornerRadius(corner):textColor(Color(255, 255, 255))
                                :bgColor(Color(0, 0, 0, 0.8))
    --绑定自定义视图
    self:setContent(toastContent)
    self:crossSelf(crossAxis)
    self:positionBottom(positionBottom)
    --show的时候触发动画
    self:willAppear(function(content)
        local anim = ObjectAnimation(AnimProperty.Alpha, content)
        anim:from(0)
        anim:to(1)
        anim:duration(0.3)
        anim:finishBlock(function()
            local result = pcall(function()
                System:setTimeOut(function()
                    local animout = ObjectAnimation(AnimProperty.Alpha, content)
                    animout:from(1)
                    animout:to(0)
                    animout:duration(0.3)
                    animout:finishBlock(function()
                        self:hide()

                    end)
                    animout:start()
                end, duration)
            end)
            if not result then
                self:hide()
            end
        end)
        anim:start()

    end)
    self:show()
end

function _class:buildLoading(path)
    --容器view
    local loadingContent = ImageView():width(50):height(50):image(path)
                                      :bgColor(Color(123,123,123))
    self:positionTop(20)
    --绑定自定义视图
    self:setContent(loadingContent)
    self:crossSelf(CrossAxis.CENTER)
    --show的时候触发动画
    self:willAppear(function(content)
        self.anim = ObjectAnimation(AnimProperty.Rotation, content)
        self.anim:from(0)
        self.anim:to(360)
        self.anim:duration(1)
        self.anim:repeatForever(true)
        self.anim:autoReverses(false)
        self.anim:start()
    end)
    self:willDisappear(function(content)
        if self.anim then
            self.anim:stop()
        end
    end)
    return self
end

function _class:buildDialog()
    self:willAppear(
            function(content)
                local anim = ObjectAnimation(AnimProperty.Alpha, content)
                anim:from(0)
                anim:to(1)
                anim:duration(0.1)
                anim:start()
            end)

    --创建阴影容器
    self.dialogContainer = VStack():positionType(PositionType.ABSOLUTE)
                                   :widthPercent(100):heightPercent(100):bgColor(Color(0, 0, 0, 0.5))
    self.dialogContainer:onClick(function()
        self:hide()
    end)
    function self:setContent(contentView)
        --重写方法，让contentView指向阴影容器, 用户的contentView放入阴影容器内
        self.contentView = contentView;
        self.contentView:positionType(PositionType.ABSOLUTE)
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
        --重写方法，让crossSelf指向dialogContainer
        if self.contentView then
            self.contentView:marginLeft(self.mMarginLeft)
            self.contentView:marginBottom(self.mMarginBottom)
            self.contentView:marginRight(self.mMarginRight)
            self.contentView:marginTop(self.mMarginTop)

            if self.hasPositionLeft then
                self.contentView:positionLeft(self.mPositionLeft)
            end
            if self.hasPositionBottom then
                self.contentView:positionBottom(self.mPositionBottom)
            end
            if self.hasPositionRight then
                self.contentView:positionRight(self.mPositionRight)
            end
            if self.hasPositionTop then
                self.contentView:positionTop(self.mPositionTop)
            end
        end
        if self.dialogContainer then
            self.dialogContainer:crossSelf(self.crossAxis)
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
    self.contentView:positionType(PositionType.ABSOLUTE)
    return self
end

--对其枚举-设置对齐方向
function _class:crossSelf(crossAxis)
    self.crossAxis = crossAxis
    return self
end

---Margin
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

---Position 
--外间距-设置Left外间距
function _class:positionLeft(value)
    self.mPositionLeft = value
    self.hasPositionLeft = true;
    return self
end

--外间距-设置Top外间距
function _class:positionTop(value)
    self.mPositionTop = value
    self.hasPositionTop = true;
    return self
end

--外间距-设置Right外间距
function _class:positionRight(value)
    self.mPositionRight = value
    self.hasPositionRight = true;
    return self
end

--外间距-设置Bottom外间距
function _class:positionBottom(value)
    self.mPositionBottom = value
    self.hasPositionBottom = true;
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

        if self.hasPositionLeft then
            self.contentView:positionLeft(self.mPositionLeft)
        end
        if self.hasPositionBottom then
            self.contentView:positionBottom(self.mPositionBottom)
        end
        if self.hasPositionRight then
            self.contentView:positionRight(self.mPositionRight)
        end
        if self.hasPositionTop then
            self.contentView:positionTop(self.mPositionTop)
        end

        self.contentView:crossSelf(self.crossAxis)
    end
end

return _class