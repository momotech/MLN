---
--- ViewPager是Lua中，用于在lua的window上，一个可以滚动可翻页的基础组件。
--- Created by wang.yang
--- DateTime: 2020-07-24
---

local _class = {}
_class._type = 'ui'
_class._version = '1.0'
_class._classname = 'ViewPager'
--- 定义常量
_class.JUMP_TYPE_GESTURE = 1
_class.JUMP_TYPE_INTERFACE = 2
_class.ANIM_TIME = 0.2
_class.MAX_SHAKE = 30 -- 防止抖动

function ViewPager()
    _class.HALF_SIZE = window:width() / 2 --- 计算padding
    _class.MAX_SIZE = window:width() / 2 --- 滑动翻页的阈值
    return _class:new()
end

function _class:new()
    local obj = {}
    setmetatable(obj, self)
    --    self.__index = self
    obj.contentView = obj:initCollectionView()
    obj.setScrollDirection = ScrollDirection.HORIZONTAL
    obj.layout = obj:initCollectionViewGridLayout()
    obj.itemSpace = 0
    obj.cellSize = window:width()
    obj.lastTime = 0
    obj.lastDis = 0
    obj.offDist = 0
    obj.offTime = 0
    obj.currentPage = 1
    obj.nextPage = obj.currentPage
    obj.position = Point(0, 0)
    obj.nextPoint = position
    obj.jumpType = 0
    obj.anim = nil
    obj.selected = nil
    obj.changeSelectedCallback = nil
    obj.tabScrollingListener = nil
    obj.segmentSelectedPage = nil
    obj.segmentScrollingListenrer = nil
    return obj
end

--- Factory Method

--- 初始化CollectionView
function _class:initCollectionView()
    local collectionView = CollectionView(false, false, true):scrollDirection(ScrollDirection.HORIZONTAL):showScrollIndicator(false):disallowFling(true):i_bounces(false)
    collectionView:setScrollBeginCallback(function(x, y)
        self.jumpType = self.JUMP_TYPE_GESTURE
        -- 先停止上一次滚动
        self:stopAnim()
    end)
    collectionView:setScrollingCallback(function(x, y)
        if self:isHorizontal() then
            self.offDist = x - self.lastDis
            self.lastDis = x
            self:percent(x)
        else
            self.offDist = y - self.lastDis
            self.lastDis = y
            self:percent(y)
        end
        self.offTime = self:time() - self.lastTime
        self.lastTime = self:time()
    end)
    collectionView:setScrollEndCallback(function(x, y)
        local flingDis = self:flingDistance(self.offDist, self.offTime)
        local offD
        local startX = self.position:x()
        local startY = self.position:y()
        local correctD
        local startD
        if self:isHorizontal() then
            correctD = self:correct(startX, x)
            startD = startX
        else
            correctD = self:correct(startY, y)
            startD = startY
        end
        if correctD < startD then
            offD = correctD - startD - flingDis
        elseif correctD > startD then
            offD = correctD - startD + flingDis
        else
            offD = 0
        end
        self:jumpPage(offD)
        if self.segmentSelectedPage then
            self.segmentSelectedPage(self.currentPage, self.nextPage)
        end
    end)
    collectionView:layoutComplete(function()
        self:initSize()
    end)
    return collectionView
end

--- 初始化CollectionViewGridLayout
function _class:initCollectionViewGridLayout()
    local collectionLayout = CollectionLayout()
    collectionLayout:spanCount(1)
    return collectionLayout
end

--- 工具
function _class:time()
    return mmos.time() * 1000
end

--- 计算
function _class:pageSize()
    return self.cellSize + self.itemSpace
end

--- 需要的padding
function _class:layoutPadding()
    return self.cellSize / 2 - self.HALF_SIZE
end

--- 防抖动纠偏处理，手势滑动到边，有抖动的可能
function _class:correct(start, current)
    if math.abs(current - start) <= self.MAX_SHAKE then
        return start
    else
        return current
    end
end

--- 惯性算法
_class.FLING_FRICTION = 500 --- Fling friction
-- 通过初始速度获取最终滑动距离
function _class:flingDistance(offDist, offTime)
    local velocity = offDist / offTime * 1000
    return (velocity * velocity) / (2 * self.FLING_FRICTION)
end

--- 翻页算法
function _class:offPage(offDist)
    if math.abs(offDist) <= self.MAX_SIZE then
        return 0
    elseif offDist < 0 then
        return - 1
    else
        return 1
    end
end

--- 停止动画
function _class:stopAnim()
    if self.anim ~= nil then
        self.anim:stop()
    end
end

--- 翻页动画（从当前位置移动到指定位置）
function _class:startAnim(duration)
    -- 先停止上一次滚动
    self:stopAnim()
    self.anim = ObjectAnimation(AnimProperty.ContentOffset, self.contentView)
    self.anim:to(self.nextPoint:x(), self.nextPoint:y())
    if duration == nil then
        self.anim:duration(self.ANIM_TIME)
    else
        self.anim:duration(duration)
    end
    self.anim:finishBlock(function()
        -- 滚动页改变回调
        self:pageChanged(self.currentPage, self.nextPage)
        self.position = self.nextPoint
        self.currentPage = self.nextPage
        -- 滚动结束回调
        if self.selected ~= nil then
            self.selected(self.currentPage)
        end
        -- 滚动结束回调给adapter
        if self.adapterv.adapter ~=nil then
            self.adapterv:onPagerSelected(self.currentPage);
        end
    end)
    self.anim:start()
end

--- 翻页逻辑
function _class:jumpPage(offDist)
    -- 手动翻页的目前也打开懒加载模式
    self:lazy(true)
    local off = self:offPage(offDist);
    self.nextPage = self.currentPage + off
    local positionX = self.position:x()
    local positionY = self.position:y()
    if off ~= 0 then
        if offDist < 0 then
            if self:isHorizontal() then
                self.nextPoint = Point(positionX - self:pageSize(), positionY)
            else
                self.nextPoint = Point(positionX, positionY - self:pageSize())
            end
        else
            if self:isHorizontal() then
                self.nextPoint = Point(positionX + self:pageSize(), positionY)
            else
                self.nextPoint = Point(positionX, positionY + self:pageSize())
            end
        end
    else
        self.nextPoint = self.position
    end
    self:startAnim()
end

--- 滚动百分比逻辑
function _class:percent(pos)
    local fromIndex = self.currentPage
    local toIndex
    local percent
    local positionX = self.position:x()
    local positionY = self.position:y()
    local correctPos = pos -- 不进行边界防抖动处理
    local off
    if self:isHorizontal() then
        off = correctPos - positionX
    else
        off = correctPos - positionY
    end
    if self.jumpType == self.JUMP_TYPE_GESTURE then
        -- 翻页只有手势和接口两种形式
        if off > 0 then
            toIndex = self.currentPage + 1
        elseif off < 0 then
            toIndex = self.currentPage - 1
        else
            toIndex = nil
        end
        percent = math.abs(off / self:pageSize())
    else
        toIndex = self.nextPage
        percent = math.abs(off / (self:pageSize() * math.abs(toIndex - fromIndex)))
    end
    if toIndex ~= nil and percent ~= nil and percent >= 0 and percent <= 1 then
        if self.tabScrollingListener ~= nil then
            self.tabScrollingListener(percent, fromIndex, toIndex)
        end
        if self.segmentScrollingListenrer then
            self.segmentScrollingListenrer(percent, fromIndex, toIndex)
        end
    end
end

function _class:pageChanged(from, to)
    if from ~= to and self.changeSelectedCallback ~= nil then
        self.changeSelectedCallback(to)
    end
end

--- 初始化相关数据
function _class:initSize()
    if self.adapterv ~= nil then
        -- adapterv没有设置高度时，等collectionView布局完成之后再设置高度和自适应
        if self.adapterv.cellSize == nil then
            self.adapterv:sizeForCell(function()
                return Size(self.contentView:width(), self.contentView:height())
            end)
        end
        self.contentView:adapter(self.adapterv.adapter)
        if self:isHorizontal() then
            self.cellSize = self.adapterv.cellSize:width()
            self.HALF_SIZE = self.contentView:width() / 2
            self.MAX_SIZE = window:width() / 2
            -- 初始化相关配置
            if self:layoutPadding() < 0 then
                self.layout:layoutInset(0, math.abs(self:layoutPadding()), 0, math.abs(self:layoutPadding()))
            end
            if self:layoutPadding() > 0 then
                self.position = Point(math.abs(self:layoutPadding()), 0)
                self.contentView:pagerContentOffset(self.position)
            end
            self.layout:itemSpacing(self.itemSpace)
        else
            self.cellSize = self.adapterv.cellSize:height()
            self.HALF_SIZE = self.contentView:height() / 2
            self.MAX_SIZE = window:height() / 2
            -- 初始化相关配置
            if self:layoutPadding() < 0 then
                self.layout:layoutInset(math.abs(self:layoutPadding()), 0, math.abs(self:layoutPadding()), 0)
            end
            if self:layoutPadding() > 0 then
                self.position = Point(0, math.abs(self:layoutPadding()))
                self.contentView:pagerContentOffset(self.position:x(), self.position:y())
            end
            self.layout:lineSpacing(self.itemSpace)
        end
    end
end

function _class:isHorizontal()
    return self.setScrollDirection == ScrollDirection.HORIZONTAL
end

-- 设置数据是否开启懒加载
function _class:lazy(isLy)
    if self.adapterv ~= nil then
        self.adapterv.isLazy = isLy
    end
end

--- Factory Method END

--- Basic Method
function _class:adapter(adapter)
    if adapter == nil then
        return self.adapterv
    else
        self.adapterv = adapter
        self.contentView:layout(self.layout)
        -- adapter延后加入
        if self.adapterSelectedFunc then
            self:setPageClickListener(self.adapterSelectedFunc)
            self.adapterSelectedFunc = nil
        end
        if self.adapterReuseEnable ~= nil then
            self:reuseEnable(self.adapterReuseEnable)
            self.adapterReuseEnable = nil
        end
        return self
    end
end

--- 获取ViewPager当前页的页数
function _class:getCurrentPage()
    return self.currentPage
end

--- 滚动停止，页面选中回调
function _class:onSelected(callback)
    self.selected = callback
    return self
end

--- 滑动后选中具体页面位置回调 (如果还是在当前Page页面，则不会回调，只有页面position发生变化后才会回调)
function _class:onChangeSelected(callback)
    self.changeSelectedCallback = callback
    return self
end

--- 滚动到具体页
function _class:scrollToPage(pageIndex, duration)
    -- 代码跳转的开启懒加载模式
    self:lazy(true)
    self.jumpType = self.JUMP_TYPE_INTERFACE
    self.nextPage = pageIndex
    if self:isHorizontal() then
        self.nextPoint = Point(self:pageSize() * (pageIndex - 1), 0)
    else
        self.nextPoint = Point(0, self:pageSize() * (pageIndex - 1))
    end
    self:startAnim(duration)
end

--- 设置是否可以滚动
function _class:setScrollEnable(enable)
    self.contentView:setScrollEnable(enable)
    return self
end

--- 设置滚动百分比回调
function _class:setTabScrollingListener(listener)
    self.tabScrollingListener = listener
    return self
end

--- 设置每一页之间的距离
function _class:spacing(spacing)
    if self:isHorizontal() then
        self.layout:itemSpacing(spacing)
    else
        self.layout:lineSpacing(spacing)
    end
    self.itemSpace = spacing
    return self
end

--- 设置点击了某一页的回调
function _class:setPageClickListener(callback)
    if self.adapterv ~= nil then
        self.adapterv.adapter:selectedRow(function(table, section, row)
            callback(row)
        end)
    else
        self.adapterSelectedFunc = callback
    end
    return self
end

--- 设置/获取滚动方向
function _class:scrollDirection(direction)
    if direction ~= nil then
        self.setScrollDirection = direction
        self.contentView:scrollDirection(direction)
        return self
    else
        return self.setScrollDirection
    end
end

--设置/获取是否禁止复用
function _class:reuseEnable(enable)
    if enable == nil then
        return self.adapterv.isReuseEnable
    else
        if self.adapterv ~= nil then
            self.adapterv.isReuseEnable = enable
        else
            self.adapterReuseEnable = enable
        end
        return self
    end
end

_class.__index = function(t, k)
    local method = _class[k]
    if method ~= nil then
        return method
    end
    local contentView = rawget(t, "contentView")
    if contentView and contentView[k] then
        t.__method = k
        return t
    end
    return method
end

_class.__call = function(t, k, ...)
    local ret = (k.contentView[t.__method])(k.contentView, ...)
    if ret == k.contentView then return t end
    return ret
end

return _class
