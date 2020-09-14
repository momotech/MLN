---
--- ViewPagerAdapter是Lua中，用于在lua的window上，针对ViewPager设置的适配器。
--- Created by wang.yang
--- DateTime: 2020-07-24
---

local _class = {}
_class._type = 'ui'
_class._version = '1.0'
_class._classname = 'ViewPagerAdapter'

function ViewPagerAdapter()
    return _class:new()
end

function _class:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.adapter = obj:initAdapter()
    -- 初始化数据（懒加载时，防止未初始化数据）
    obj.initFill = {}
    -- 数据懒加载
    obj.isLazy = false
    obj.needLoad = false
    -- 数据懒加载
    obj.fillCellReuseId = nil
    obj.fillCell = nil
    obj.fillRow = nil
    return obj
end

----Factory Method

function _class:initAdapter()
    local adapter = CollectionViewAdapter()
    adapter:sectionCount(function()
        return 1
    end)
    return adapter
end

-- viewPager滚动停止，页面选中回调
function _class:onPagerSelected(currentPage)
    -- 真正执行懒加载数据模式，有可能是预加载，即self.fillRow~=currentPage
    if self.fillCellReuseId ~= nil and self.fillCell ~= nil and self.isLazy and self.needLoad then
        self.fillCellReuseId(self.fillCell, self.fillRow)
        self.isLazy = false
        self.needLoad = false
        if self.initFill[self.fillRow] ~= nil and self.initFill[self.fillRow].init == false then
            self.initFill[self.fillRow].init = true
        end
    end
    -- 未初始化的进行初始化
    if self.initFill[currentPage] ~= nil and self.initFill[currentPage].init == false then
        local data = self.initFill[currentPage].data
        data.dataFunction(data.dataCell, data.dataRow)
        self.initFill[currentPage].init = true
    end
    return self
end

---- Factory Method END

---- Basic Method

--回调ViewPager的总页数
function _class:getCount(count)
    self.adapter:rowCount(function(section)
        return count()
    end)
    return self
end

--设置cell大小的回调
function _class:sizeForCell(size)
    self.cellSize = size()
    self.adapter:sizeForCell(function(section, row)
        return size()
    end)
    return self
end

--初始化cell的回调
function _class:initCell(initCell)
    self.adapter:initCell(function(cell)
        return initCell(cell)
    end)
    return self
end

--填充cell数据的回调
function _class:fillCellData(fillCell)
    self.adapter:fillCellData(function(cell, section, row)
        fillCell(cell, row)
    end)
    return self
end

--回调某个页面的复用ID
function _class:reuseId(id)
    self.adapter:reuseId(function(section, row)
        return id(row)
    end)
    return self
end

--初始化一个cell，根据复用ID
function _class:initCellByReuseId(reuseId, initCell)
    self.adapter:initCellByReuseId(reuseId, function(cell)
        return initCell(cell)
    end)
    return self
end

--填充cell数据，根据复用ID
function _class:fillCellDataByReuseId(reuseId, fillCell)
    self.adapter:fillCellDataByReuseId(reuseId, function(cell, section, row)
        -- 搜集懒加载模式下，所有初始化数据（防止数据未加载）
        if self.isLazy and self.initFill[row] == nil then
            local data = { dataID = reuseId, dataRow = row, dataCell = cell, dataFunction = fillCell }
            local initData = { init = false, data = data }
            self.initFill[row] = initData
        end
        -- 是否懒加载，针对notifyDataSource
        if self.isLazy then
            self.needLoad = true
            self.fillCell = cell
            self.fillRow = row
            self.fillCellReuseId = fillCell
        else
            return fillCell(cell, row)
        end
    end)
    return self
end

--设置cell大小的回调
function _class:sizeForCellByReuseId(reuseId, size)
    self.cellSize = size()
    self.adapter:sizeForCellByReuseId(reuseId, function(section, row)
        return size()
    end)
    return self
end

return _class