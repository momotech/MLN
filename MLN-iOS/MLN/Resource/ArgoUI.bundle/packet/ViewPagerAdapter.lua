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
        return fillCell(cell, row)
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