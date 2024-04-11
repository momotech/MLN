--1
ui_views = {}
local timeDistance="1.02km 4分钟."
local myList = TableView()
ui_views.myList = myList
myList:refreshEnable(true)
myList:setRefreshingCallback(function(a, b)
DataBinding:update("tableModel.refresh", true)
end)
DataBinding:bind("tableModel.refresh",function(new, old)
if new == false then
myList:stopRefreshing()
end
end)
DataBinding:bindListView("tableModel.source", myList)
local myList_adapter = TableViewAdapter()
myList_adapter:sectionCount(function()
return DataBinding:getSectionCount("tableModel.source")
end)
myList_adapter:rowCount(function(section)
return DataBinding:getRowCount("tableModel.source", section)
end)
myList_adapter:initCellByReuseId("ADCell", function(_cell_)

local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
local contentView_1_1 = Label()
_cell_.contentView_1_1 = contentView_1_1

_cell_.contentView_1:children({_cell_.contentView_1_1})
_cell_.contentView_1:bgColor(Color(255, 0, 0, 0.4))
_cell_.contentView_1:mainAxisAlignment(MainAxisAlignment.CENTER)
_cell_.contentView_1:crossAxisAlignment(CrossAxisAlignment.CENTER)
_cell_.contentView_1:setGravity(Gravity.CENTER)
_cell_.contentView_1:height(80)
_cell_.contentView:addView(_cell_.contentView_1)

end)
myList_adapter:initCellByReuseId("MyCell", function(_cell_)

local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
local contentView_1_1 = ImageView()
_cell_.contentView_1_1 = contentView_1_1
_cell_.contentView_1_1:image()

_cell_.contentView_1_1:width(60)
_cell_.contentView_1_1:height(60)
_cell_.contentView_1_1:marginLeft(10)

local contentView_1_2 = HStack()
_cell_.contentView_1_2 = contentView_1_2
local contentView_1_2_1 = Label()
_cell_.contentView_1_2_1 = contentView_1_2_1

_cell_.contentView_1_2_1:marginLeft(10)
local contentView_1_2_2 = Label()
_cell_.contentView_1_2_2 = contentView_1_2_2
_cell_.contentView_1_2_2:text()
_cell_.contentView_1_2_2:marginRight(10)

_cell_.contentView_1_2:children({_cell_.contentView_1_2_1, _cell_.contentView_1_2_2})
_cell_.contentView_1_2:mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
_cell_.contentView_1_2:crossAxisAlignment(CrossAxisAlignment.START)
_cell_.contentView_1_2:height(MeasurementType.MATCH_PARENT)
_cell_.contentView_1_2:bgColor(Color(153, 153, 153, 1))
_cell_.contentView_1_2:marginRight(10)
_cell_.contentView_1_2:marginLeft(10)
_cell_.contentView_1_2:marginTop(10)
_cell_.contentView_1_2:marginBottom(10)
_cell_.contentView_1:children({_cell_.contentView_1_1, _cell_.contentView_1_2})
_cell_.contentView_1:setGravity(Gravity.CENTER_VERTICAL)
_cell_.contentView_1:crossAxisAlignment(CrossAxisAlignment.CENTER)
_cell_.contentView_1:mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
_cell_.contentView_1:bgColor(Color(34, 66, 121, 1))
_cell_.contentView_1:height(80)
_cell_.contentView:addView(_cell_.contentView_1)

end)
myList_adapter:fillCellDataByReuseId("MyCell", function(_cell_, section, row)
_cell_.contentView_1_1:image(DataBinding:getModel("tableModel.source", section, row, "iconUrl"))
_cell_.contentView_1_1:gone(DataBinding:getModel("tableModel.source", section, row, "hideIcon"))
_cell_.contentView_1_2_1:text(DataBinding:getModel("tableModel.source", section, row, "name"))
 if DataBinding:getModel("tableModel.source", section, row, "hideIcon") then
_cell_.contentView_1_2_2:text(DataBinding:getModel("tableModel.source", section, row, "title"))
else
_cell_.contentView_1_2_2:text(timeDistance)
end
DataBinding:bindCell("tableModel.source", section, row, {"hideIcon", "name", "iconUrl", "type", "title"})
end)
myList_adapter:fillCellDataByReuseId("ADCell", function(_cell_, section, row)
_cell_.contentView_1_1:text(DataBinding:getModel("tableModel.source", section, row, "title"))
DataBinding:bindCell("tableModel.source", section, row, {"title"})
end)
myList_adapter:heightForCellByReuseId("ADCell"
, function(section, row)
return 120
end)
myList_adapter:heightForCellByReuseId("MyCell"
, function(section, row)
return 120
end)
myList_adapter:reuseId(function(section, row)
if DataBinding:getModel("tableModel.source", section, row, "type") == "AD" then
return "ADCell"
end
return "MyCell"
end)
myList:adapter(myList_adapter)
window:addView(myList)
return {}, true
