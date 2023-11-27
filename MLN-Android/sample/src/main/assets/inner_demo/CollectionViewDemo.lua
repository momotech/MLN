local W = window:width()
local H = window:height()
local topHeight = 0
if System:iOS() then
    topHeight = window:statusBarHeight() + window:navBarHeight()
end
--初始化CollectionView
local function initCollectionView()
    collectionView = CollectionView(true, true)
            :width(MeasurementType.MATCH_PARENT)
            :height(MeasurementType.MATCH_PARENT)
            :scrollDirection(ScrollDirection.VERTICAL)--竖直方向滑动
    --:scrollDirection(ScrollDirection.HORIZONTAL)--水平方向滑动
            :showScrollIndicator(true)--是否显示滑动指示器
            :bgColor(Color(255, 255, 0, 0.5))
            :marginTop(topHeight)
    --下拉刷新事件回调
    collectionView:setRefreshingCallback(
            function()
                --print("开始刷新")
                System:setTimeOut(function()
                    --2秒后结束刷新
                    --print("结束刷新了")
                    collectionView:stopRefreshing()
                end, 2)
            end)
    --上拉加载事件回调
    collectionView:setLoadingCallback(function()
        --print("开始加载")
        System:setTimeOut(function()
            --2秒后结束加载
            --print("结束加载")
            collectionView:stopLoading()
            --已加载全部
            collectionView:noMoreData()
        end, 2)

    end)
    --开始滑动的回调事件
    collectionView:setScrollBeginCallback(function()
        --print("开始滑动")
    end)
    --滑动中的回调事件
    collectionView:setScrollingCallback(function()
        --print("滑动中")
    end)
    --结束滑动的回调事件
    collectionView:setScrollEndCallback(function()
        --print("结束滑动")
    end)
    return collectionView
end
--初始化CollectionViewGridLayout
local function initCollectionViewGridLayout()

    collectionLayout = CollectionViewLayout()
    collectionLayout:itemSpacing(5)--间隔大小
                    :lineSpacing(5)
    --竖直滑动代表显示列数；水平滑动代表显示行数
    collectionLayout:spanCount(3)
    return collectionLayout
end
--初始化适配器
local function initAdapter()

    adapter = TableViewAdapter()

    adapter:sectionCount(function()
        return 1
    end)

    -----------------------------设置子view个数---------------------------------------
    count = 20
    adapter:rowCount(function(section)
        return count
    end)
    ------------------------------设置cell宽高----------------------------------------
    --根据类型标识设置对应子view的宽高
    --adapter:sizeForCellByReuseId("CellId", function(section, row)
    --    return Size(MeasurementType.MATCH_PARENT, MeasurementType.MATCH_PARENT)
    --end)
    -------------------------------子view类型-----------------------------------------
    --返回当前位置子view的类型标识
    adapter:reuseId(function(section, row)
        return "CellId"
    end)
    -------------------------------创建子view-----------------------------------------
    adapter:initCellByReuseId("CellId", function(cell)

        cell.userView = LinearLayout(LinearType.VERTICAL)
                :height(window:height())
                :bgColor(Color(100, 200, 10, 1))
                :width(MeasurementType.MATCH_PARENT)
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
    --------------------------将子view与数据进行绑定赋值----------------------------------
    adapter:fillCellDataByReuseId("CellId", function(cell, section, row)
        cell.nameLabel:text("盖世英雄")
    end)
    --cell点击事件
    adapter:selectedRowByReuseId("CellId", function(cell, section, row)
        --print("点击了cell", row)
    end)
    --cell被滑出屏幕可见区域的回调
    adapter:cellDidDisappear(function(cell, section, row)
        --print("cell不见了", row)
    end)
    --cell出现在屏幕可见区域的回调
    adapter:cellWillAppear(function(cell, section, row)
        --print("cell出现了", row)
    end)

    return adapter
end

contentView = LinearLayout(LinearType.VERTICAL)
contentView:width(W):height(H)
           :bgColor(Color(255, 255, 255, 1))
--初始化CollectionView
collectionView = initCollectionView()
collectionView:a_pagingEnabled(true)
--初始化CollectionViewGridLayout
--collectionLayout = initCollectionViewGridLayout()
--初始化CollectionViewAdapter
adapter = initAdapter()
--collectionView:layout(collectionLayout)
collectionView:adapter(adapter)
contentView:addView(collectionView)
--操作栏
operLayout = LinearLayout(LinearType.HORIZONTAL):height(100)
addLabel = Label():width(W / 2):height(100):text("点我新增cell")
                  :bgColor(Color(255, 255, 255, 1)):fontSize(16)
                  :setGravity(Gravity.CENTER):textAlign(TextAlign.CENTER)
addLabel:onClick(function()
    --在指定位置插入cell
    count = count + 2
    collectionView:insertCellsAtSection(1, 1, 2)
    --collectionView:insertRowsAtSection(1, 1, 2,true)
end)
subLabel = Label():width(W / 2):height(100):text("点我删除cell")
                  :bgColor(Color(255, 255, 255, 1)):fontSize(16)
                  :setGravity(Gravity.CENTER):textAlign(TextAlign.CENTER)
subLabel:onClick(function()
    --在指定位置删除cell
    count = count - 2
    collectionView:deleteCellsAtSection(1, 1, 2)
    --collectionView:deleteRowsAtSection(1, 1, 2,true)
end)
--operLayout:addView(addLabel)
--operLayout:addView(subLabel)
--contentView:addView(operLayout)
window:addView(contentView)
window:bgColor(Color(123, 3, 1, 1))