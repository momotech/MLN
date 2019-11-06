local W = window:width()
local H = window:height()

mainView = View():bgColor(Color(0, 0, 0, 1))
contentView = LinearLayout(LinearType.VERTICAL)
contentView:width(W):height(H)
           :bgColor(Color(255, 255, 255, 1))
mainView:addView(contentView)

collectionView = CollectionView(false, false)
        :width(MeasurementType.MATCH_PARENT)
        :height(H - 100)
--:scrollDirection(ScrollDirection.VERTICAL)--竖直方向滑动
        :scrollDirection(ScrollDirection.HORIZONTAL)--水平方向滑动
        :showScrollIndicator(true)--是否显示滑动指示器
        :bgColor(Color(255, 255, 0, 0.5))

collectionLayout = CollectionViewGridLayout()
collectionLayout:itemSpacing(5)--间隔大小
                :lineSpacing(5)
collectionLayout:spanCount(5)--几列
collectionView:layout(collectionLayout)

adapter = CollectionViewAdapter()

adapter:sectionCount(function()
    return 1
end)

count = 5
--设置数量
adapter:rowCount(function(section)
    return count
end)
--设置cell宽高
adapter:sizeForCell(function()
    return Size(100, 100)
end)
adapter:reuseId(function(section, row)
    return "CellId"
end)
--初始化cell
adapter:initCellByReuseId("CellId", function(cell)

    cell.userView = LinearLayout(LinearType.VERTICAL)
            :setGravity(Gravity.CENTER)
    --头像
    cell.imageView = ImageView():width(50):height(50):cornerRadius(45)
                                :priority(1):bgColor(Color(255, 0, 0, 0.5))
                                :setGravity(Gravity.CENTER)
    cell.userView:addView(cell.imageView)
    --昵称
    cell.nameLabel = Label():fontSize(14):textColor(Color(0, 0, 0, 1))
                            :text("昵称"):setGravity(Gravity.CENTER)
                            :marginTop(5)
    cell.contentView:bgColor(Color(255, 255, 255, 1))
    cell.userView:addView(cell.nameLabel)
    cell.contentView:addView(cell.userView)
end)
--为cell赋值
adapter:fillCellDataByReuseId("CellId", function(cell, section, row)
    cell.nameLabel:text("盖世英雄")

end)

collectionView:adapter(adapter)
contentView:addView(collectionView)
label = Label():width(W):height(100):text("点我新增cell")
               :bgColor(Color(255, 255, 255, 1)):fontSize(16)
               :setGravity(Gravity.CENTER):textAlign(TextAlign.CENTER)
               :onClick(function()
    print("点击了label")
    --在指定位置插入cell
    count = count + 2
    collectionView:insertCellsAtSection(1, 1, 2, true)
end)
contentView:addView(label)
window:addView(contentView)
--点击事件
adapter:selectedRowByReuseId("CellId", function(cell, section, row)
    print("点击了adapter", section, "**", row)
end)
--cell消失回调
adapter:cellDidDisappear(function(cell, section, row)
    print("cellDidDisappear", row)
end)
--cell出现回调
adapter:cellWillAppear(function(cell, section, row)
    print("cellWillAppear", row)
end)