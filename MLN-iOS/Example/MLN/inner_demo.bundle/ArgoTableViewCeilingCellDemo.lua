height = { 300, 350, 400, 500 }
rowHeight = {}
for i = 1, 100 do
    table.insert(rowHeight, height[math.random(1, #height)])
end
tableView = TableView(false, false)

local function initAdapter(tableView)
    local adapter = TableViewAdapter()
    adapter:heightForCell(function(section, row)
        return rowHeight[row]
    end)

    adapter:sectionCount(function()
        return 1
    end)

    adapter:rowCount(function(section)
        print(#rowHeight)
        return #rowHeight
    end)

    adapter:reuseId(function(section, position)
        return "cell"
    end)

    adapter:initCellByReuseId("cell", function(cell)
        cell.rowContainer = HStack():widthPercent(100)
                                    :heightPercent(100)
                                    :mainAxis(MainAxis.CENTER)

        cell.tv = Label():fontSize(16)
                         :textAlign(TextAlign.CENTER)
                         :crossSelf(CrossAxis.CENTER)

        cell.rowContainer:addView(cell.tv)

        cell.contentView:addView(cell.rowContainer)
    end)

    adapter:fillCellDataByReuseId("cell", function(cell, section, row)
        cell.tv:text(tostring(row))
        if row % 2 == 0 then
            cell.contentView:bgColor(Color(255, 255, 255, 1))
        else
            cell.contentView:bgColor(Color(0, 0, 0, 0.1))
        end
    end)

    adapter:selectedRowByReuseId("cell", function(cell, section, row)
        print("点击了：" .. tostring(row))
    end)

    return adapter
end

local topHeight = 0
if System:iOS() then
    topHeight = window:statusBarHeight() + window:navBarHeight()
end

tableView:widthPercent(100):heightPercent(100)

--下拉刷新事件回调
tableView:setRefreshingCallback(
        function()
            --print("开始刷新")
            System:setTimeOut(function()
                --2秒后结束刷新
                --print("结束刷新了")
                tableView:stopRefreshing()
            end, 2)
        end)


--上拉加载事件回调
tableView:setLoadingCallback(function()
    --print("开始加载")
    System:setTimeOut(function()
        --2秒后结束加载
        --print("结束加载")
        tableView:stopLoading()
        --已加载全部
        tableView:noMoreData()
    end, 2)
end)

tableView:setScrollWillEndDraggingCallback(function(y)
    local index = tableView:visibleCellsRows()
    if y > 0 then
        print("setScrollWillEndDrag", "y > 0")
        tableView:scrollToCell(index[1] + 1, 1, true)
    elseif y < 0 then
        print("setScrollWillEndDrag", "y < 0")
        tableView:scrollToCell(index[1], 1, true)
    end
end)
tableView:disallowFling(true)

local adapter = initAdapter(tableView)
tableView:adapter(adapter)
window:addView(tableView)
--System:setTimeOut(function()
--    tableView:scrollToCell(3, 1, true)
--end, 2)











