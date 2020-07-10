--1
ui_views = {}
require("packet/BindMeta")
if tableModel== nil then 
tableModel= BindMeta("tableModel")
end
local window_1 = TableView()
ui_views.window_1 = window_1
window_1:bgColor(Color(255, 255, 0, 0.1))
DataBinding:bindListView(tableModel.sourceData.__path, window_1)
local window_1_adapter = TableViewAdapter()
window_1_adapter:sectionCount(function()
return DataBinding:getSectionCount(tableModel.sourceData.__path)
end)
window_1_adapter:rowCount(function(section)
return DataBinding:getRowCount(tableModel.sourceData.__path, section)
end)
window_1_adapter:initCellByReuseId("bannerCell", function(_cell_)
local contentView_1 = ImageView()
_cell_.contentView_1 = contentView_1
_cell_.contentView_1:widthPercent(100)
_cell_.contentView_1:contentMode(ContentMode.SCALE_ASPECT_FILL)
_cell_.contentView:addView(_cell_.contentView_1)
end)
window_1_adapter:initCellByReuseId("txtCell", function(_cell_)
local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
_cell_.contentView_1:padding(5, 10, 5, 10)
_cell_.contentView_1:crossAxis(CrossAxis.CENTER)
local contentView_1_1 = ImageView()
_cell_.contentView_1_1 = contentView_1_1
_cell_.contentView_1_1:width(38)
_cell_.contentView_1_1:height(38)
_cell_.contentView_1_1:cornerRadius(50)
_cell_.contentView_1_1:contentMode(ContentMode.SCALE_ASPECT_FILL)
local contentView_1_2 = Spacer()
_cell_.contentView_1_2 = contentView_1_2
_cell_.contentView_1_2:width(20)
local contentView_1_3 = Label()
_cell_.contentView_1_3 = contentView_1_3
_cell_.contentView_1:children({_cell_.contentView_1_1, _cell_.contentView_1_2, _cell_.contentView_1_3})
_cell_.contentView:addView(_cell_.contentView_1)
end)
window_1_adapter:fillCellDataByReuseId("txtCell", function(_cell_, section, row)
local _l_c_item=tableModel.sourceData[section][row]
BindMetaPush(_cellBinds)_cell_.contentView_1_1:image(_l_c_item.imgUrl.__get)
_cell_.contentView_1_3:text(_l_c_item.name.__get)

BindMetaWatchListCell(tableModel.sourceData,section,row)
end)
window_1_adapter:fillCellDataByReuseId("bannerCell", function(_cell_, section, row)
local _l_c_item=tableModel.sourceData[section][row]
BindMetaPush(_cellBinds)_cell_.contentView_1:image(_l_c_item.imgUrl.__get)

BindMetaWatchListCell(tableModel.sourceData,section,row)
end)
window_1_adapter:heightForCellByReuseId("bannerCell", function(section, row)
return  100
end)
window_1_adapter:heightForCellByReuseId("txtCell", function(section, row)
return  44
end)
window_1_adapter:reuseId(function(section, row)
if row == 1 then
return  "bannerCell"
else
return  "txtCell"
end
end)
window_1:adapter(window_1_adapter)
window:addView(window_1)
