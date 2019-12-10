
-- 数据源
datasouce = {
headIconName = "http://img.momocdn.com/album/4F/CF/4FCFA0D2-95E8-3C09-3760-142E6916CA1B20170701_S.jpg",
summary = "安全等级：高",
sections = {
{
sectionTitle = "通过以下设置可以提高安全等级",
items = {
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "密码修改——1——100",
subtitle = nil,
height=400,
},
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "密码修改——1——100",
subtitle = nil,
height=150,
},
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "手机绑定——2——300",
subtitle = "已绑定",
height=300,
},
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "证件信息——3——100",
subtitle = "未绑定",
height=150,
},
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "登录保护--4--100",
subtitle = "已开启",
height=150,
},
{
iconName = "https://moji.wemomo.com/attach/pimg_5b5703e8c769c.png",
title = "账号注销--5--200",
subtitle = "",
height=200,
},
}
},

}
}

local size = window:size()

-- tableView
local tableView = TableView(true, true)
tableView:frame(Rect(0,0,size:width(),size:height()))
tableView:bgColor(Color(105, 105, 105, 1))
--tableView:loadThreshold(0.5)
tableView:showScrollIndicator(true)
window:addView(tableView)

-- adapter
local adapter = TableViewAdapter()
adapter:sectionCount(function ()
return 2
end)
adapter:rowCount(function (section)
if section == 1 then
local sections = datasouce.sections;
return #sections[section].items
end
return 0
end)
adapter:reuseId(function (section, row)
return "cellID"
end)
adapter:initCellByReuseId("cellID", function (cell)
local width = cell.contentView:width()
cell.bgImage = ImageView():marginTop(10):marginLeft(width/2-50):width(100):height(100)
cell.bgImage:contentMode(ContentMode.SCALE_TO_FILL)
cell.titleLabel = Label():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
cell.titleLabel:textColor(Color(1,0,0,1))
cell.titleLabel:text("1231")
cell.titleLabel:fontSize(14)
cell.titleLabel:height(30):marginLeft(20):marginTop(50)
cell.contentView:cornerRadius(8)
cell.contentView:clipToBounds(true)
cell.contentView:bgColor(Color(255,0,0,0.5))
cell.contentView:addView(cell.titleLabel):addView(cell.bgImage)
cell.contentView:openRipple(true)
end)
adapter:fillCellDataByReuseId("cellID", function (cell,section,row)
local sectionData = datasouce.sections[section]
local items = sectionData.items;
local detailItem = items[row]
cell.bgImage:image(detailItem.iconName)
cell.titleLabel:text(detailItem.title)
end)
adapter:selectedRowByReuseId("cellID",function (cell,section,row)
print('onclick', section,row)
if row % 3 == 0 then
tableView:startRefreshing()
end
end)
adapter:heightForCell(function (section,row)
local section = datasouce.sections[section]
local items = section.items;
return items[row].height
end)
adapter:cellWillAppear(function (cell,s,r)
print('cell appear ', r)
end)
tableView:adapter(adapter)

-- tableView method
tableView:setRefreshingCallback(function ()
print('开始刷新')
System:setTimeOut(function ()
print("timer 完成")
tableView:stopRefreshing()
tableView:stopLoading()
--tableView:resetLoading()
tableView:reloadData()
end , 1)
end)
tableView:setLoadingCallback(function ()
print('开始加载')
System:setTimeOut(function ()
local items = datasouce.sections[1].items
local old = #items + 1
tableView:reloadData()
--tableView:insertCellsAtSection(1, old, 9 + old)
tableView:stopRefreshing()
tableView:stopLoading()
--tableView:noMoreData()
--tableView:loadEnable(false)
end, 1)
end)
tableView:setScrollingCallback(function (x, y)
print('滚动中', x, y)
end)
tableView:setScrollBeginCallback(function ()
print('开始滚动')
end)
tableView:setScrollEndCallback(function ()
print('滚动结束')
end)
tableView:setEndDraggingCallback(function (x, y)
print('end dragging', x, y)
end)
tableView:setStartDeceleratingCallback(function (x, y)
print('dece', x, y)
end)
--tableView:reload()
