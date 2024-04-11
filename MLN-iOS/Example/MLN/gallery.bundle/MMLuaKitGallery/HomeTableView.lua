---
--- Generated by MLN Team (http://www.immomo.com)
--- Created by MLN Team.
--- DateTime: 2019-09-05 12:05
---

local _class = {
    _name = 'HomeTableView',
    _version = '1.0',
    _type = 0,
    TYPE_FOLLOW = "follow",
    TYPE_RECOMMEND = "recommend"
}

---@public
function _class:new()
    local o = {}
    setmetatable(o, {__index = self})
    self.dataList = Array()
    self.cid = 1
    return o
end

---@public
function _class:tableView(type)
    self._type = type
    self:setupContainerView()
    self:setupDataSource()
    return self.tableView
end

---@private
function _class:setupContainerView()
    local searchBarCellId = "firstCellType"
    local normalCellId = "normalCellType"

    local tableView = TableView(true, true)
    tableView:width(window:width()):height(MeasurementType.MATCH_PARENT)
    tableView:showScrollIndicator(true)
    self.tableView = tableView

    local adapter = TableViewAutoFitAdapter()
    tableView:adapter(adapter)
    self.adapter = adapter

    adapter:sectionCount(function()
        return 1
    end)

    adapter:rowCount(function(_)
        return self.dataList:size()
    end)

    --第一个cell用来展示搜索框以便能跟随tableView滚动
    adapter:initCellByReuseId(searchBarCellId, function(cell)
        cell.searchBar = self:searchBox()
        cell.contentView:addView(cell.searchBar)
    end)

    adapter:initCellByReuseId(normalCellId, function(cell)
        local cellClass = require("MMLuaKitGallery.HomeCommonCell")
        cell._cell = cellClass:new()
        cell.contentView:addView(cell._cell:contentView())

        if self._type == self.TYPE_FOLLOW then
            cell._cell:updateFollowLabel(true, nil)
        elseif self._type == self.TYPE_RECOMMEND then
            cell._cell:updateFollowLabel(false, nil)
        end
    end)

    adapter:reuseId(function(_, row)
        if row == 1 then
            return searchBarCellId
        end
        return normalCellId
    end)

    adapter:fillCellDataByReuseId(searchBarCellId, function (_, _, _)
        --do nothing
    end)

    adapter:fillCellDataByReuseId(normalCellId, function(cell, _, row)
        local item = self.dataList:get(row)
        cell._cell:updateCellContentWithItem(item)
    end)
end


--- 更新数据分类
--- @public
function _class:updateCategoryId(cid)
    self.cid = cid
end

--- 创建搜索框
--- @private
function _class:searchBox()
    local search = require("MMLuaKitGallery.SearchBox"):new()
    return search:setup(nil)
end

--- 加载数据
--- @private
function _class:setupDataSource()
    self.minId = 1

    --首先展示第一页数据
    self:request(true,function(success, _)
        if success then
            self.tableView:reloadData()
        end
    end)

    --下拉刷新
    self.tableView:setRefreshingCallback(function ()
        self:request(true,function(success, _)
            self.tableView:stopRefreshing()
            self.tableView:resetLoading()
            if success then
                self.tableView:reloadData()
            end
        end)
    end)

    --上拉加载
    self.tableView:setLoadingCallback(function ()
        self:request(false,function(success, data)
            self.tableView:stopLoading()
            if not data then
                self.tableView:noMoreData()
            end
            if success then
                self.tableView:reloadData()
            end
        end)
    end)
end

--- 数据请求
--- @param first boolean 是否请求第一页
--- @param complete function 数据请求结束的回调
--- @private
function _class:request(first, complete)

    local filepath = 'gallery.bundle/json/fashion.json'
    if System:Android() then
        filepath = 'assets://'..filepath
    else
        filepath = 'file://'..filepath
    end
    File:asyncReadFile(filepath, function(codeNumber, response)
        map = StringUtil:jsonToMap(response)
        if codeNumber == 0 then
            local data = map:get("data")
            if first then
                self.dataList = data
            elseif data then
                self.dataList:addAll(data)
            end
            complete(true, data)
        else
            --error(err:get("errmsg"))
            complete(false, nil)
        end
    end)
end

return _class
