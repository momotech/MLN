
--数据源
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

local size = window:size()
screen_w = size:width()
screen_h = size:height()
local stateBar = window:stateBarHeight()  --获取状态栏高度

local collectionView = CollectionView()
collectionView:scrollDirection(ScrollDirection.HORIZONTAL)  --水平视图
collectionView:width(screen_w):height(screen_h/2):marginTop(stateBar)
window:addView(collectionView)

local layout = CollectionViewLayout()
--layout:lineSpacing(10)  --设置cell之间的水平距离
layout:itemSpacing(10)  --设置cell之间的垂直距离
layout:itemSize(Size(100, screen_h/2))  --设置cell大小
collectionView:layout(layout)


local adapter = CollectionViewAdapter()

adapter:sectionCount(function ()  --设置section数量回调
return 1
end)

adapter:rowCount(function (_)  --根据section设置row数量回调
local sections = dataSource.items
return #sections
end)

adapter:reuseId(function (_, _)  --设置不同类型cell的id回调
return "cellID"
end)

adapter:sizeForCell(function ()  --设置cell大小的回调
return Size(screen_w/2, screen_h/2)
end)

adapter:cellWillAppear(function (cell, section, row)
local str = string.format("cell appear, section = %d, row = %d", section, row)
print(str)
end)

adapter:cellDidDisappear(function (cell, section, row)
local str = string.format("cell disappear, section = %d, row = %d", section, row)
print(str)
end)

adapter:initCellByReuseId("cellID", function(cell)  --根据reuseId设置初始化cell的回调
cell.bgImage = ImageView():width(screen_w/4):height(screen_w/4):marginTop(50):marginLeft(50)
cell.bgImage:contentMode(ContentMode.SCALE_TO_FILL)  --直接拉伸到View大小， 有可能会变形

cell.titleLabel = Label():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
cell.titleLabel:textColor(Color(245, 150, 170, 1))
cell.titleLabel:fontSize(14)
cell.titleLabel:height(screen_w/4):marginLeft(20):marginTop(50)

cell.contentView:bgColor(Color(0,170,144,1))
cell.contentView:cornerRadius(10):clipToBounds(true)  --设置圆角
cell.contentView:addView(cell.bgImage):addView(cell.titleLabel)
end)

adapter:fillCellDataByReuseId("cellID", function (cell, _, row)  --根据reuseId设置初始化cell数据的回调
local item = dataSource.items[row]
cell.bgImage:image(item.icon)
cell.titleLabel:text(item.text)
end)

collectionView:adapter(adapter)

local label = Label():frame(Rect(10, 400, 100, 50)):bgColor(Color(90, 90, 90, 1))
label:text("reloadData")
window:addView(label)
label:onClick(function ()
print("reload Data")
collectionView:reloadData()
end)
