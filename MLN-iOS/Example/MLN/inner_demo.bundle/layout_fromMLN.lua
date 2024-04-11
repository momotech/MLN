
--1
ui_views = {}
local timeDistance="1.02km 4分钟前"
require("packet/BindMeta")
if userData== nil then
userData= BindMeta("userData")
end
local window_1 = TableView()
ui_views.window_1 = window_1
window_1:refreshEnable(true)
window_1:loadEnable(true)
window_1:setRefreshingCallback(function()
window_1:stopRefreshing()
end)
DataBinding:bindListView(userData.source.__path, window_1)
local window_1_adapter = TableViewAdapter()
window_1_adapter:sectionCount(function()
return DataBinding:getSectionCount(userData.source.__path)
end)
window_1_adapter:rowCount(function(section)
return DataBinding:getRowCount(userData.source.__path, section)
end)
window_1_adapter:initCellByReuseId("MyCell", function(_cell_)
local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
local contentView_1_1 = ImageView()
_cell_.contentView_1_1 = contentView_1_1
_cell_.contentView_1_1:width(60)
_cell_.contentView_1_1:height(60)
_cell_.contentView_1_1:marginLeft(10)
local contentView_1_2 = HStack()
_cell_.contentView_1_2 = contentView_1_2
_cell_.contentView_1_2:mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
_cell_.contentView_1_2:crossAxisAlignment(CrossAxisAlignment.START)
_cell_.contentView_1_2:height(MeasurementType.MATCH_PARENT)
_cell_.contentView_1_2:bgColor(Color(153, 153, 153, 1))
_cell_.contentView_1_2:marginRight(10)
_cell_.contentView_1_2:marginLeft(10)
_cell_.contentView_1_2:marginTop(10)
_cell_.contentView_1_2:marginBottom(10)
_cell_.contentView_1_2:weight(2)
_cell_.contentView_1:children({_cell_.contentView_1_1, _cell_.contentView_1_2})
_cell_.contentView_1:setGravity(Gravity.CENTER_VERTICAL)
_cell_.contentView_1:crossAxisAlignment(CrossAxisAlignment.CENTER)
_cell_.contentView_1:mainAxisAlignment(MainAxisAlignment.START)
_cell_.contentView_1:bgColor(Color(34, 66, 121, 1))
_cell_.contentView_1:height(80)
_cell_.contentView:addView(_cell_.contentView_1)
end)
window_1_adapter:fillCellDataByReuseId("MyCell", function(_cell_, section, row)
local _l_c_item=userData.source[section][row]
_cell_.contentView_1_1:image(_l_c_item.iconUrl.__get)
_cell_.contentView_1_1:gone(_l_c_item.hideIcon.__get)
_cell_.contentView_1_1:onClick(function()
_l_c_item.hideIcon=true
end)
_cell_.contentView_1_2_sf_1 = function()
local _v_1 = {}
for index=1,#(_l_c_item.titles.__get) do
local _p_i_1=index
_v_1[index] = (function()
return (function()
local contentView_1_2_var1_1 = Label()
_cell_.contentView_1_2_var1_1 = contentView_1_2_var1_1
_cell_.contentView_1_2_var1_1:text(_l_c_item.titles[_p_i_1].tt.__get)
_cell_.contentView_1_2_var1_1:onClick(function()
 
end)
return _cell_.contentView_1_2_var1_1
end)()
end)()
end
return _v_1
end
_cell_.contentView_1_2_add = function()
_cell_.contentView_1_2_s = {}
local add = function(_v_)
if type(_v_) == "table" then
for _k, _v in pairs(_v_) do
table.insert(_cell_.contentView_1_2_s, _v)
end
elseif _v_ then
table.insert(_cell_.contentView_1_2_s, _v_)
end
end
add(_cell_.contentView_1_2_sf_1())
_cell_.contentView_1_2:children(_cell_.contentView_1_2_s)
end
_cell_.contentView_1_2_add()
_l_c_item.titles.__watch=function(new, old)
_cell_.contentView_1_2:removeAllSubviews()
_cell_.contentView_1_2_add()
end
DataBinding:bindCell(userData.source.__path, section, row, {"hideIcon","iconUrl","titles"})
end)
window_1_adapter:heightForCellByReuseId("MyCell", function(section, row)
return 150
end)
window_1_adapter:reuseId(function(section, row)
return "MyCell"
end)
window_1:adapter(window_1_adapter)
window:addView(window_1)
return {}, true
