screen_h = window:height() - 64

window:bgColor(Color(255, 255, 255, 1))

collectionView = CollectionView(true, true)
collectionView:bgColor(Color(30, 130, 20, 1))
collectionView:scrollDirection(ScrollDirection.HORIZONTAL)
cHeight = 200

spanCount = 6--默认0
top = 5
bottom = 5
lineSpacing = 1

itemHeight = (cHeight - top - bottom - (spanCount - 1)*lineSpacing)/spanCount
str = string.format("item height = %f", itemHeight)
print(str)

local indeex = 3
local begin = (indeex-1)*itemHeight + (indeex-2)*lineSpacing
str = string.format("index = %d, begin = %f", indeex, begin)
print(str)

collectionView:frame(Rect(0, 64, window:width(), cHeight))

--- layout
layout = CollectionViewGridLayout()
layout:spanCount(spanCount)


-- 视图是横向滚动时，代表为横向间距
layout:lineSpacing(lineSpacing)




layout:itemSpacing(5)
layout:layoutInset(top, 5, bottom, 5)
collectionView:layout(layout)
-- method
collectionView:setRefreshingCallback(function ()
    print('开始刷新')
    System:setTimeOut(function ()
        print("timer 完成")
        collectionView:stopRefreshing()
        collectionView:resetLoading()
    end, 1)
end)
collectionView:setLoadingCallback(function ()
    print('开始加载')
    System:setTimeOut(function ()
        print("timer 完成")
        collectionView:stopLoading()
        collectionView:noMoreData()
    end, 1)
end)

--- adapter
adapter = CollectionViewAdapter()
adapter:sectionCount(function()
    return 2
end)

adapter:rowCount(function(sectionidx)
    return 10
end)

adapter:initCell(function(cell)
    local contentView = cell.contentView
    contentView:bgColor(Color(57, 175, 202, 1))
    local width = contentView:width()
    local height = contentView:height()
    cell.label = Label()
    cell.label:frame(Rect(0, 0, width, height))
    cell.label:textAlign(TextAlign.CENTER)
    cell.label:lines(0)
    contentView:addView(cell.label)
    cell.image = ImageView()
    cell.image:frame(Rect(0, 0, width, height))
    contentView:addView(cell.image)
end)

adapter:fillCellData(function(cell, section, row)
    local contentView = cell.contentView
    local width = contentView:width()
    local height = contentView:height()
    --cell.image:image("my.jpg")
    cell.image:cornerRadius(width * 0.5)
    cell.label:text("Reuse cell | section" .. section .. "row" .. row)
end)

adapter:selectedRow(function(cell, section, row)

    local txt = "be selected, section:" .. section .. "row:" .. row
    cell.label:text(txt)
end)


size = Size()
size:width(30)
size:height(100)

adapter:sizeForCell(function(section, row)
    -- local idx = row
    -- print('cell size --------', row % 11, cellSize[row % 11])
    -- return cellSize[row % 11]

    print("___row =")
    print(row)
    cellW = 111
    if row%2 == 0 then
        cellW = 150
    end

    if spanCount == 3 then
        if row == 9 then
            return Size(cellW, 55)
        elseif row > 5 then
            return Size(cellW, 49)
        end
        return Size(cellW, 50) -- --count = 3, height = 50; 测 49, 55
    end

    if spanCount == 5 then
        if row == 8 then
            return Size(cellW, 45)
        elseif row > 5 then
            return Size(cellW, 65) -- 63或者64,测一下
        end
        return Size(cellW, 22) --count = 5, height = 22; 测 60
    end

    if spanCount == 6 then
        if row > 10 then
            return Size(cellW, 51)
        elseif row > spanCount then
            return Size(cellW, 49) -- --50
        end
        return Size(cellW, 15) --count = 5, height = 22; 测 60
    end
end)

collectionView:adapter(adapter)
window:addView(collectionView)


--[[
--测试点：
--上下拉控件；
--横向
--竖向
--
--发现问题:



]]--

