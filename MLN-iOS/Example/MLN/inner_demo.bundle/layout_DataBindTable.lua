local timeDistance="1.02km 4分钟前"
local myList = TableView()
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
_cell_.contentView_1:bgColor(Color(255, 0, 0, 0.4))
                    :mainAxisAlignment(MainAxisAlignment.CENTER)
                    :crossAxisAlignment(CrossAxisAlignment.CENTER)
                    :setGravity(Gravity.CENTER)
                    :height(80)
local contentView_1_2 = Label()
_cell_.contentView_1_2 = contentView_1_2
_cell_.contentView_1_2:fontSize(30)
_cell_.contentView_1:children({_cell_.contentView_1_2})
_cell_.contentView:addView(_cell_.contentView_1)
end)
myList_adapter:initCellByReuseId("MyCell", function(_cell_)
local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
_cell_.contentView_1:setGravity(Gravity.CENTER_VERTICAL)
                    :crossAxisAlignment(CrossAxisAlignment.CENTER)
                    :mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
                    :bgColor(Color(34, 66, 121, 1))
                    :height(80)
local contentView_1_2 = ImageView()
_cell_.contentView_1_2 = contentView_1_2
_cell_.contentView_1_2:width(60)
                      :height(60)
                      :marginLeft(10)
local contentView_1_3 = HStack()
_cell_.contentView_1_3 = contentView_1_3
_cell_.contentView_1_3:mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
                      :crossAxisAlignment(CrossAxisAlignment.START)
                      :height(MeasurementType.MATCH_PARENT)
                      :bgColor(Color(153, 153, 153, 1))
                      :marginRight(10)
                      :marginLeft(10)
                      :marginTop(10)
                      :marginBottom(10)
local contentView_1_3_4 = Label()
_cell_.contentView_1_3_4 = contentView_1_3_4
_cell_.contentView_1_3_4:marginLeft(10)
local contentView_1_3_5 = Label()
_cell_.contentView_1_3_5 = contentView_1_3_5
_cell_.contentView_1_3_5:marginRight(10)
_cell_.contentView_1_3:children({_cell_.contentView_1_3_4, _cell_.contentView_1_3_5})
_cell_.contentView_1:children({_cell_.contentView_1_2, _cell_.contentView_1_3})
_cell_.contentView:addView(_cell_.contentView_1)
end)
myList_adapter:fillCellDataByReuseId("MyCell", function(_cell_, section, row)
_cell_.contentView_1_2:image(DataBinding:getModel("tableModel.source", section, row, "iconUrl"))
_cell_.contentView_1_2:gone(DataBinding:getModel("tableModel.source", section, row, "hideIcon"))
_cell_.contentView_1_3_4:text(DataBinding:getModel("tableModel.source", section, row, "name"))
 if DataBinding:getModel("tableModel.source", section, row, "hideIcon") then
_cell_.contentView_1_3_5:text(DataBinding:getModel("tableModel.source", section, row, "title"))
else
_cell_.contentView_1_3_5:text(timeDistance)
end
DataBinding:bindCell("tableModel.source", section, row, {"hideIcon", "name", "iconUrl", "type", "title"})
end)
myList_adapter:fillCellDataByReuseId("ADCell", function(_cell_, section, row)
_cell_.contentView_1_2:text(DataBinding:getModel("tableModel.source", section, row, "title"))
DataBinding:bindCell("tableModel.source", section, row, {"title"})
end)
myList_adapter:heightForCellByReuseId("ADCell", function(section, row)
return 120
end)
myList_adapter:heightForCellByReuseId("MyCell", function(section, row)
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
ui_views = {}
ui_views.myList = myList
return {}, true
