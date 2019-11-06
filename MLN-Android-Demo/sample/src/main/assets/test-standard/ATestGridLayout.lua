screen_h = window:height() - 64

window:bgColor(Color(255, 255, 255, 1))

-- cellSize = {Size(111, 10), Size(111, 200), Size(111, 200), Size(111, 200), Size(365, 200), Size(111, 200),Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200)}
collectionView = CollectionView()
collectionView:bgColor(Color(30, 130, 20, 1))
-- collectionView:scrollDirection(ScrollDirection.HORIZONTAL)
--collectionView:scrollDirection(ScrollDirection.VERTICAL)
collectionView:frame(Rect(0, 64, window:width(), screen_h))

--collectionView:scrollDirection(ScrollDirection.VERTICAL)


--[[
collectionView:setContentInset(10,20,30,40);
collectionView:setScrollIndicatorInset(1,2,3,4)
collectionView:getContentInset(function(top,right,bottom,left)
    print("top,right,bottom,left",top,right,bottom,left)
end)
--]]

--[[collectionView:setEndDraggingCallback(function (x, y)
    print('end___ dragging', x, y)
end)

collectionView:setScrollEndCallback(function ()
    print('scrolling end ========')
end)]]

collectionView:setScrollingCallback(function(x, y)
    print('scrolling', x, y)
end)

singlewidth1 = 111
singlewidth2 = 365
singleHeight = 80

--- layout
layout = CollectionViewGridLayout()
layout:spanCount(2)
layout:lineSpacing(30)

layout:itemSpacing(30)

layout:layoutInset(30, 50, 0, 0)

 layout:canScroll2Screen(true)

collectionView:layout(layout)

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
    local width = contentView:width()
    local height = contentView:height()


    cell.label = Label()
    cell.label:frame(Rect(0, 0, width, height))
    cell.label:textAlign(TextAlign.CENTER)
    cell.label:lines(0)
    contentView:addView(cell.label)
    cell.image = ImageView()
    cell.image:frame(Rect(0, 0, width, height))

    cell.contentView:bgColor(Color(57, 175, 202, 1))

    contentView:addView(cell.label)
end)

adapter:fillCellData(function(cell, section, row)
    local contentView = cell.contentView
    local width = contentView:width()
    local height = contentView:height()

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



    return Size(155, singleHeight)
end)

collectionView:adapter(adapter)
window:addView(collectionView)