
dataSource = {
items = {
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372024-01.png",
text = "11111"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372064-02.png",
text = "22222"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-3.png",
text = "33333"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372137-4.png",
text = "44444"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-5.png",
text = "55555"
}
}
}

screen_w = window:width()
screen_h = window:height()
local stateBar = window:stateBarHeight()  --获取状态栏高度

local collectionView = WaterfallView(true, true)
collectionView:useAllSpanForLoading(true)  --加载是否占用一行
collectionView:frame(Rect(0, stateBar, screen_w, screen_h))
collectionView:showScrollIndicator(true)  --滑动指示器
window:addView(collectionView)

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

local layout = WaterfallLayout()
layout:lineSpacing(5)  --cell之间的垂直距离
layout:itemSpacing(10)  --cell之间的水平距离
layout:spanCount(2)  --列数
collectionView:layout(layout)

local adapter = WaterfallAdapter()

adapter:sectionCount(function ()  --设置section数量回调
return 1
end)

adapter:rowCount(function ()  --根据section设置row数量回调
return #dataSource.items
end)

adapter:reuseId(function (_, row)  --设置不同类型cell的id回调
if row == 1 then
return "1"
end
return "2"
end)

adapter:initCellByReuseId('1', function (cell)  --根据reuseId设置初始化cell的回调
cell.vp = ViewPager()
cell.vp:width(cell.contentView:width()):height(cell.contentView:height())
cell.adapter = ViewPagerAdapter()
cell.adapter:getCount(function ()  --设置cell数量回调
return 5
end)
cell.adapter:initCell(function (cell_1, position)  --设置初始化cell的回调
cell_1.bgImage = ImageView():marginTop(10):marginLeft(30):width(100):height(100)
cell_1.bgImage:contentMode(ContentMode.SCALE_ASPECT_FILL)
cell_1.titleLabel = Label():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
cell_1.titleLabel:textColor(Color(0, 0, 0, 1)):fontSize(14)
cell_1.titleLabel:text(dataSource.items[position].text)
cell_1.titleLabel:height(30):marginLeft(20):marginTop(50)
cell_1.contentView:bgColor(Color(255, 0, 0, 0.5))
cell_1.contentView:cornerRadius(8):clipToBounds(true)  --设置圆角
cell_1.contentView:addView(cell_1.bgImage):addView(cell_1.titleLabel)
end)
cell.adapter:fillCellData(function (cell_1, position)  --设置初始化cell数据的回调
cell_1.bgImage:bgColor(Color(76, 175, 80, 1))
cell_1.bgImage:image(dataSource.items[position].icon)
end)
cell.vp:autoScroll(true)  --是否自动滚动
cell.vp:frameInterval(2.5)  --播放的默认周期
cell.vp:recurrence(true)  --是否循环滚动
cell.vp:showIndicator(true)  --是否显示滚动指示器

cell.contentView:addView(cell.vp)
cell.vp:adapter(cell.adapter)
end)

adapter:fillCellDataByReuseId('1', function (cell)  --根据reuseId设置初始化cell数据的回调
cell.vp:reloadData()
end)

adapter:initCellByReuseId('2', function (cell)  --根据reuseId设置初始化cell的回调
cell.bgImage = ImageView():width(cell.contentView:width()):height(cell.contentView:height())
cell.bgImage:contentMode(ContentMode.SCALE_ASPECT_FIT)
cell.titleLabel = Label():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
cell.titleLabel:textColor(Color(0, 0, 0, 1)):fontSize(14)
cell.titleLabel:height(30):marginLeft(20):marginTop(50)
cell.contentView:cornerRadius(8):clipToBounds(true)
cell.contentView:bgColor(Color(183, 248, 219, 1))
cell.contentView:addView(cell.bgImage):addView(cell.titleLabel)
end)

adapter:fillCellDataByReuseId('2', function (cell, _, row)  --根据reuseId设置初始化cell数据的回调
local item = dataSource.items[row]
cell.bgImage:image(item.icon)
cell.titleLabel:text(item.text)
end)

adapter:heightForCell(function ()
return 150
end)

collectionView:adapter(adapter)
