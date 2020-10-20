height = { 300, 350, 400, 500 }
rowHeight = {}
--for i, v in pairs(screenSize) do
--    print(i, v)
--end
for i = 1, 100 do
    table.insert(rowHeight, 375 + 20)
end
tableView = TableView(false, false)

local function initAdapter()
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
        cell.iv = ImageView()
                :width(375):height(375)
                :contentMode(ContentMode.SCALE_TO_FILL)
                :crossSelf(CrossAxis.CENTER)

        cell.rowContainer
            :addView(cell.iv)

        cell.contentView
            :addView(cell.rowContainer)

    end)

    adapter:fillCellDataByReuseId("cell", function(cell, section, row)
        --cell.contentView:enabled(false)
        cell.iv:image("jolin")
        cell.iv:enabled(true)
        cell.iv:scaleBegin(function(focusX, focusY, span, spanX, spanY, factor)
            print("cell.iv:scaleBegin: focusX = ", focusX, " focusY = ", focusY)
        end)
        cell.iv:scaling(function(focusX, focusY, span, spanX, spanY, factor)
            print("cell.iv:scaling: focusX = ", focusX, " focusY = ", focusY)
        end)
        cell.iv:scaleEnd(function(focusX, focusY, span, spanX, spanY, factor)
            print("cell.iv:scaleEnd: focusX = ", focusX, " focusY = ", focusY)
        end)
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

local adapter = initAdapter(tableView)
tableView:adapter(adapter)

tableView:enabled(true)
tableView:touchBeginExtension(function(x)
    print("tableView:touchBegin = ", x)
end)

tableView:touchMoveExtension(function(x)
    print("tableView:touchMove: x = ", x)
end)

tableView:touchEndExtension(function(x)
    print("tableView:touchEnd = ", x)
end)

tableView:touchCancelExtension(function(x)
    print("tableView:touchCancel = ", x)
end)

tableView:onClick(function()
    print("tableView:onClick = ")
end)

local lbl = Label()
        :width(375):height(375)
lbl:text("这是一段超长的文本")
lbl:enabled(true)
lbl:touchBegin(function(x, y)
    print("lbl:touchBegin = ", x, y)
end)

lbl:touchMove(function(x, y)
    print("lbl:touchMove = ", x, y)
end)

lbl:touchEnd(function(x, y)
    print("lbl:touchEnd = ", x, y)
end)

lbl:onClick(function()
    print("lbl:onClick = ")
end)

lbl:touchCancel(function(x, y)
    print("lbl:touchCancel = ", x, y)
end)

local imgBtn = ImageButton()
        :width(375):height(375)
imgBtn:setImage("jolin", "jaychou")
imgBtn:enabled(true)
imgBtn:touchBegin(function(x, y)
    print("imgBtn:touchBegin = ", x, y)
end)

imgBtn:touchMove(function(x, y)
    print("imgBtn:touchMove = ", x, y)
end)

imgBtn:touchEnd(function(x, y)
    print("imgBtn:touchEnd = ", x, y)
end)

imgBtn:onClick(function()
    print("imgBtn:onClick = ")
end)

imgBtn:touchCancel(function(x, y)
    print("imgBtn:touchCancel = ", x, y)
end)

local iv = ImageView()
--:widthPercent(100):heightPercent(50)
        :width(375):height(375)
        :contentMode(ContentMode.SCALE_TO_FILL)
        :crossSelf(CrossAxis.CENTER)

iv:enabled(true)
iv:touchBegin(function(x, y)
    print("iv:touchBegin = ", x, y)
end)

iv:touchMove(function(x, y)
    print("iv:touchMove = ", x, y)
end)

iv:touchEnd(function(x, y)
    print("iv:touchEnd = ", x, y)
end)

--iv:onClick(function()
--    print("iv:onClick = ")
--end)

iv:touchCancel(function(x, y)
    print("iv:touchCancel = ", x, y)
end)

iv:image("jolin")


iv:scaleBegin(function(focusX, focusY, span, spanX, spanY, factor)
    print("cell.iv:scaleBegin: focusX = ", focusX, " focusY = ", focusY)
end)
iv:scaling(function(focusX, focusY, span, spanX, spanY, factor)
    print("cell.iv:scaling: focusX = ", focusX, " focusY = ", focusY)
end)
iv:scaleEnd(function(focusX, focusY, span, spanX, spanY, factor)
    print("cell.iv:scaleEnd: focusX = ", focusX, " focusY = ", focusY)
end)

window:enabled(true)
window:touchBegin(function(x, y)
    print("window:touchBegin = ", x, y)
end)

window:touchMove(function(x, y)
    print("window:touchMove = ", x, y)
end)

window:touchEnd(function(x, y)
    print("window:touchEnd = ", x, y)
end)

window:onClick(function()
    print("window:onClick = ")
end)

window:touchCancel(function(x, y)
    print("window:touchCancel = ", x, y)
end)

--window:addView(iv)
--window:addView(imgBtn)
window:addView(tableView)
--window:addView(lbl)










