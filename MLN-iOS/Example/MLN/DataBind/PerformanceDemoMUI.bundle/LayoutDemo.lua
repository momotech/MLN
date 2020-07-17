--1
ui_views = {}
WHITE=Color(255, 255, 255, 1)
RED=Color(180, 100, 100, 1)
REDALPHA=Color(180, 100, 100, 0.2)
YELLOW=Color(220, 200, 100, 1)
PURPLE=Color(100, 100, 200, 1)
GRAY=Color(200, 200, 200, 0.8)
BLACK=Color(10, 10, 10, 1)
PURPLEALPHA=Color(100, 100, 200, 0.6)
COLORS={PURPLE,
RED,
YELLOW}
labelStyle={
textColor = BLACK,
bgColor = GRAY,
fontSize = 12,
textAlign = TextAlign.CENTER,
padding = {8, 10, 8, 10},
cornerRadius = 20,
marginTop=3 ,
marginRight=3 ,
marginBottom=3 ,
marginLeft=3 
}
function setParams(pos1,pos2)
if pos1 == 1 then 
temp=(pos2 == 1)
ui_views.base_hstack:display(temp)
ui_views.base_vstack:display(not temp)
elseif pos1 == 2 then 
ui_views.base_hstack:mainAxis(paramsModel.stackParams[pos1].params[pos2].enum.__get)
ui_views.base_vstack:mainAxis(paramsModel.stackParams[pos1].params[pos2].enum.__get)
elseif pos1 == 3 then 
ui_views.base_hstack:crossAxis(paramsModel.stackParams[pos1].params[pos2].enum.__get)
ui_views.base_vstack:crossAxis(paramsModel.stackParams[pos1].params[pos2].enum.__get)
ui_views.base_hstack:crossContent(paramsModel.stackParams[pos1].params[pos2].enum.__get)
ui_views.base_vstack:crossContent(paramsModel.stackParams[pos1].params[pos2].enum.__get)
elseif pos1 == 4 then 
ui_views.base_hstack:wrap(paramsModel.stackParams[pos1].params[pos2].enum.__get)
ui_views.base_vstack:wrap(paramsModel.stackParams[pos1].params[pos2].enum.__get)
end
end
function showStackParamsLayout(b)
ui_views.stackParamsLayout:display(b)
ui_views.childParamsLayout:display(not b)
if b then 
paramsModel.childView[paramsModel.curChildPos.__get].isChoosed=false
end
end
function addChildData(ipos)
temp={}
temp.text=tostring(ipos)
temp.params=initParams()
temp.isChoosed=false 
table.insert(paramsModel.childView, ipos, temp)
end
require("packet/BindMeta")
if paramsModel== nil then 
paramsModel= BindMeta("paramsModel")
end
if childParamsModel== nil then 
childParamsModel= BindMeta("childParamsModel")
end
local keyboardManager = require("packet/KeyboardManager")
require("packet/style")
window:safeArea(SafeArea.TOP)
local base_hstack = HStack()
ui_views.base_hstack = base_hstack
base_hstack:widthPercent(100)
base_hstack:bgColor(GRAY)
base_hstack:basis(1)
local base_hstack_sf_1 = function()
local _v_4 = {}
for index=1, (paramsModel.childView.__asize) do
local _p_i_1=index
local _v_4_=(function()
return  (function()
local var_7=index
local base_hstack_var1_1 = Label()
ui_views.base_hstack_var1_1 = base_hstack_var1_1
base_hstack_var1_1:text(paramsModel.childView[_p_i_1].text.__get)
paramsModel.childView[_p_i_1].text.__watch=function(new, old)
base_hstack_var1_1:text(new)
end
base_hstack_var1_1:textColor(WHITE)
base_hstack_var1_1:bgColor(COLORS[var_7%#COLORS+1])
base_hstack_var1_1:fontSize(24)
base_hstack_var1_1:borderColor(BLACK)
base_hstack_var1_1:textAlign(TextAlign.CENTER)
local watch_f_1 = function()
 if paramsModel.childView[_p_i_1].isChoosed.__get then 
base_hstack_var1_1:borderWidth(2)
else 
base_hstack_var1_1:borderWidth(0)
end 
crossSelfPos=paramsModel.childView[_p_i_1].params[1].choosedIndex.__get
if paramsModel.childView[_p_i_1].params[1].choosedIndex.__get>0 then 
base_hstack_var1_1:crossSelf(paramsModel.childView[_p_i_1].params[1].params[paramsModel.childView[_p_i_1].params[1].choosedIndex.__get].enum.__get)
end
if paramsModel.childView[_p_i_1].params[2].values[1].__get>0 then 
base_hstack_var1_1:basis(paramsModel.childView[_p_i_1].params[2].values[1].__get)
end
if paramsModel.childView[_p_i_1].params[2].values[2].__get>0 then 
base_hstack_var1_1:grow(paramsModel.childView[_p_i_1].params[2].values[2].__get)
else
end
if paramsModel.childView[_p_i_1].params[2].values[3].__get>0 then 
base_hstack_var1_1:shrink(paramsModel.childView[_p_i_1].params[2].values[3].__get)
end
if paramsModel.childView[_p_i_1].params[3].values[1].__get>= 0 then 
base_hstack_var1_1:display(paramsModel.childView[_p_i_1].params[3].values[1].__get== 1)
end
if paramsModel.childView[_p_i_1].params[3].values[2].__get>= 0 then 
base_hstack_var1_1:hidden(paramsModel.childView[_p_i_1].params[3].values[2].__get== 1)
end
if paramsModel.childView[_p_i_1].params[4].values[1].__get>0 then 
base_hstack_var1_1:width(paramsModel.childView[_p_i_1].params[4].values[1].__get)
end
if paramsModel.childView[_p_i_1].params[4].values[2].__get>0 then 
base_hstack_var1_1:height(paramsModel.childView[_p_i_1].params[4].values[2].__get)
end
if paramsModel.childView[_p_i_1].params[5].values[1].__get>0 then 
base_hstack_var1_1:widthPercent(paramsModel.childView[_p_i_1].params[5].values[1].__get)
end
if paramsModel.childView[_p_i_1].params[5].values[2].__get>0 then 
base_hstack_var1_1:heightPercent(paramsModel.childView[_p_i_1].params[5].values[2].__get)
end
if paramsModel.childView[_p_i_1].params[6].values[1].__get>0 then 
base_hstack_var1_1:minWidth(paramsModel.childView[_p_i_1].params[6].values[1].__get)
end
if paramsModel.childView[_p_i_1].params[6].values[2].__get>0 then 
base_hstack_var1_1:minHeight(paramsModel.childView[_p_i_1].params[6].values[2].__get)
end
if paramsModel.childView[_p_i_1].params[7].values[1].__get>0 then 
base_hstack_var1_1:maxWidth(paramsModel.childView[_p_i_1].params[7].values[1].__get)
end
if paramsModel.childView[_p_i_1].params[7].values[2].__get>0 then 
base_hstack_var1_1:maxHeight(paramsModel.childView[_p_i_1].params[7].values[2].__get)
end 
base_hstack_var1_1:marginTop(paramsModel.childView[_p_i_1].params[8].values[1].__get):marginRight(paramsModel.childView[_p_i_1].params[8].values[2].__get):marginBottom(paramsModel.childView[_p_i_1].params[8].values[3].__get):marginLeft(paramsModel.childView[_p_i_1].params[8].values[4].__get)
base_hstack_var1_1:padding(paramsModel.childView[_p_i_1].params[9].values[1].__get, paramsModel.childView[_p_i_1].params[9].values[2].__get, paramsModel.childView[_p_i_1].params[9].values[3].__get, paramsModel.childView[_p_i_1].params[9].values[4].__get)
for i=1, (paramsModel.childView[_p_i_1].params[10].values.__asize) do
local _p_i_8=i
if paramsModel.childView[_p_i_1].params[10].values[_p_i_8].__get>0 then
if paramsModel.childView[_p_i_1].params[10].isAbsolute.__get then 
base_hstack_var1_1:positionType(PositionType.ABSOLUTE)
else 
base_hstack_var1_1:positionType(PositionType.RELATIVE)
end 
base_hstack_var1_1:position(paramsModel.childView[_p_i_1].params[10].values[1].__get, paramsModel.childView[_p_i_1].params[10].values[2].__get, paramsModel.childView[_p_i_1].params[10].values[3].__get, paramsModel.childView[_p_i_1].params[10].values[4].__get)
return  
end
end 
BindMetaPopForach()
end
watch_f_1()
paramsModel.childView[_p_i_1].params[4].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[6].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[9].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[1].params[paramsModel.childView[_p_i_1].params[1].choosedIndex.__get].enum.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[7].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[3].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[5].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[10].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[2].values.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[10].isAbsolute.__watch=watch_f_1
paramsModel.childView[_p_i_1].isChoosed.__watch=watch_f_1
paramsModel.childView[_p_i_1].params[1].choosedIndex.__watch=watch_f_1
base_hstack_var1_1:onClick(function()
paramsModel.childView[paramsModel.curChildPos.__get].isChoosed=false 
paramsModel.childView[var_7].isChoosed=true 
paramsModel.curChildPos=var_7
showStackParamsLayout(false)
childParamsModel.params=paramsModel.childView[paramsModel.curChildPos.__get].params.__get
--[[
print(tostring(paramsModel.childView[paramsModel.curChildPos.__get].params[1].choosedIndex.__get)
.. "," .. tostring(childParamsModel.params[1].choosedIndex.__get))
]]--
end)
return base_hstack_var1_1
end)()
end)()
if _v_4_ then table.insert(_v_4,_v_4_) end
end 
BindMetaPopForach()
return _v_4
end
local base_hstack_add = function()
local base_hstack_s = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(base_hstack_s, _v)
end
elseif _v_ then
table.insert(base_hstack_s, _v_)
end
end
add(base_hstack_sf_1())
base_hstack:children(base_hstack_s)
end
BindMetaPush(_watchIds)
base_hstack_add()
local base_hstack_add_ws=BindMetaPop(_watchIds)
paramsModel.childView.__watch=function(new, old)
BindMetaRemoveWatchs(base_hstack_add_ws)
base_hstack:removeAllSubviews()
BindMetaPush(_watchIds)
base_hstack_add()
base_hstack_add_ws=BindMetaPop(_watchIds)
end
base_hstack:onClick(function()
showStackParamsLayout(true)
end)
window:addView(base_hstack)
local base_vstack = VStack()
ui_views.base_vstack = base_vstack
base_vstack:widthPercent(100)
base_vstack:bgColor(GRAY)
base_vstack:basis(1)
base_vstack:display(false)
local base_vstack_sf_1 = function()
local _v_5 = {}
for index=1, (paramsModel.childView.__asize) do
local _p_i_2=index
local _v_5_=(function()
return  (function()
local var_9=index
local base_vstack_var2_1 = Label()
ui_views.base_vstack_var2_1 = base_vstack_var2_1
base_vstack_var2_1:text(paramsModel.childView[_p_i_2].text.__get)
paramsModel.childView[_p_i_2].text.__watch=function(new, old)
base_vstack_var2_1:text(new)
end
base_vstack_var2_1:textColor(WHITE)
base_vstack_var2_1:bgColor(COLORS[var_9%#COLORS+1])
base_vstack_var2_1:fontSize(24)
base_vstack_var2_1:borderColor(BLACK)
base_vstack_var2_1:textAlign(TextAlign.CENTER)
local watch_f_2 = function()
 if paramsModel.childView[_p_i_2].isChoosed.__get then 
base_vstack_var2_1:borderWidth(2)
else 
base_vstack_var2_1:borderWidth(0)
end 
crossSelfPos=paramsModel.childView[_p_i_2].params[1].choosedIndex.__get
if paramsModel.childView[_p_i_2].params[1].choosedIndex.__get>0 then 
base_vstack_var2_1:crossSelf(paramsModel.childView[_p_i_2].params[1].params[paramsModel.childView[_p_i_2].params[1].choosedIndex.__get].enum.__get)
end
if paramsModel.childView[_p_i_2].params[2].values[1].__get>0 then 
base_vstack_var2_1:basis(paramsModel.childView[_p_i_2].params[2].values[1].__get)
end
if paramsModel.childView[_p_i_2].params[2].values[2].__get>0 then 
base_vstack_var2_1:grow(paramsModel.childView[_p_i_2].params[2].values[2].__get)
else
end
if paramsModel.childView[_p_i_2].params[2].values[3].__get>0 then 
base_vstack_var2_1:shrink(paramsModel.childView[_p_i_2].params[2].values[3].__get)
end
if paramsModel.childView[_p_i_2].params[3].values[1].__get>= 0 then 
base_vstack_var2_1:display(paramsModel.childView[_p_i_2].params[3].values[1].__get== 1)
end
if paramsModel.childView[_p_i_2].params[3].values[2].__get>= 0 then 
base_vstack_var2_1:hidden(paramsModel.childView[_p_i_2].params[3].values[2].__get== 1)
end
if paramsModel.childView[_p_i_2].params[4].values[1].__get>0 then 
base_vstack_var2_1:width(paramsModel.childView[_p_i_2].params[4].values[1].__get)
end
if paramsModel.childView[_p_i_2].params[4].values[2].__get>0 then 
base_vstack_var2_1:height(paramsModel.childView[_p_i_2].params[4].values[2].__get)
end
if paramsModel.childView[_p_i_2].params[5].values[1].__get>0 then 
base_vstack_var2_1:widthPercent(paramsModel.childView[_p_i_2].params[5].values[1].__get)
end
if paramsModel.childView[_p_i_2].params[5].values[2].__get>0 then 
base_vstack_var2_1:heightPercent(paramsModel.childView[_p_i_2].params[5].values[2].__get)
end
if paramsModel.childView[_p_i_2].params[6].values[1].__get>0 then 
base_vstack_var2_1:minWidth(paramsModel.childView[_p_i_2].params[6].values[1].__get)
end
if paramsModel.childView[_p_i_2].params[6].values[2].__get>0 then 
base_vstack_var2_1:minHeight(paramsModel.childView[_p_i_2].params[6].values[2].__get)
end
if paramsModel.childView[_p_i_2].params[7].values[1].__get>0 then 
base_vstack_var2_1:maxWidth(paramsModel.childView[_p_i_2].params[7].values[1].__get)
end
if paramsModel.childView[_p_i_2].params[7].values[2].__get>0 then 
base_vstack_var2_1:maxHeight(paramsModel.childView[_p_i_2].params[7].values[2].__get)
end 
base_vstack_var2_1:marginTop(paramsModel.childView[_p_i_2].params[8].values[1].__get):marginRight(paramsModel.childView[_p_i_2].params[8].values[2].__get):marginBottom(paramsModel.childView[_p_i_2].params[8].values[3].__get):marginLeft(paramsModel.childView[_p_i_2].params[8].values[4].__get)
base_vstack_var2_1:padding(paramsModel.childView[_p_i_2].params[9].values[1].__get, paramsModel.childView[_p_i_2].params[9].values[2].__get, paramsModel.childView[_p_i_2].params[9].values[3].__get, paramsModel.childView[_p_i_2].params[9].values[4].__get)
for i=1, (paramsModel.childView[_p_i_2].params[10].values.__asize) do
local _p_i_10=i
if paramsModel.childView[_p_i_2].params[10].values[_p_i_10].__get>0 then
if paramsModel.childView[_p_i_2].params[10].isAbsolute.__get then 
base_vstack_var2_1:positionType(PositionType.ABSOLUTE)
else 
base_vstack_var2_1:positionType(PositionType.RELATIVE)
end 
base_vstack_var2_1:position(paramsModel.childView[_p_i_2].params[10].values[1].__get, paramsModel.childView[_p_i_2].params[10].values[2].__get, paramsModel.childView[_p_i_2].params[10].values[3].__get, paramsModel.childView[_p_i_2].params[10].values[4].__get)
return  
end
end 
BindMetaPopForach()
end
watch_f_2()
paramsModel.childView[_p_i_2].params[2].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[1].choosedIndex.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[7].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[9].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[4].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[5].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[10].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[10].isAbsolute.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[3].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[6].values.__watch=watch_f_2
paramsModel.childView[_p_i_2].params[1].params[paramsModel.childView[_p_i_2].params[1].choosedIndex.__get].enum.__watch=watch_f_2
paramsModel.childView[_p_i_2].isChoosed.__watch=watch_f_2
base_vstack_var2_1:onClick(function()
paramsModel.childView[paramsModel.curChildPos.__get].isChoosed=false 
paramsModel.childView[var_9].isChoosed=true 
paramsModel.curChildPos=var_9
showStackParamsLayout(false)
childParamsModel.params=paramsModel.childView[paramsModel.curChildPos.__get].params.__get
--[[
print(tostring(paramsModel.childView[paramsModel.curChildPos.__get].params[1].choosedIndex.__get)
.. "," .. tostring(childParamsModel.params[1].choosedIndex.__get))
]]--
end)
return base_vstack_var2_1
end)()
end)()
if _v_5_ then table.insert(_v_5,_v_5_) end
end 
BindMetaPopForach()
return _v_5
end
local base_vstack_add = function()
local base_vstack_s = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(base_vstack_s, _v)
end
elseif _v_ then
table.insert(base_vstack_s, _v_)
end
end
add(base_vstack_sf_1())
base_vstack:children(base_vstack_s)
end
BindMetaPush(_watchIds)
base_vstack_add()
local base_vstack_add_ws=BindMetaPop(_watchIds)
paramsModel.childView.__watch=function(new, old)
BindMetaRemoveWatchs(base_vstack_add_ws)
base_vstack:removeAllSubviews()
BindMetaPush(_watchIds)
base_vstack_add()
base_vstack_add_ws=BindMetaPop(_watchIds)
end
base_vstack:onClick(function()
showStackParamsLayout(true)
end)
window:addView(base_vstack)
local var_4="add"
local window_3 = Label()
ui_views.window_3 = window_3
window_3:text(var_4)
window_3:width(50)
window_3:height(50)
window_3:textColor(BLACK)
window_3:bgColor(REDALPHA)
window_3:fontSize(12)
window_3:textAlign(TextAlign.CENTER)
window_3:cornerRadius(45)
window_3:positionType(PositionType.ABSOLUTE)
window_3:positionRight(0)
window_3:positionTop(250)
window_3:onClick(function()
addChildData(#paramsModel.childView.__get+1)
end)
window:addView(window_3)
local var_5="sub"
local window_4 = Label()
ui_views.window_4 = window_4
window_4:text(var_5)
window_4:width(50)
window_4:height(50)
window_4:textColor(BLACK)
window_4:bgColor(REDALPHA)
window_4:fontSize(12)
window_4:textAlign(TextAlign.CENTER)
window_4:cornerRadius(45)
window_4:positionType(PositionType.ABSOLUTE)
window_4:positionRight(0)
window_4:positionTop(300)
window_4:onClick(function()
 if#paramsModel.childView.__get>0 then 
table.remove(paramsModel.childView)
end
end)
window:addView(window_4)
local var_6="确定"
local window_5 = Label()
ui_views.window_5 = window_5
window_5:text(var_6)
window_5:width(50)
window_5:height(50)
window_5:textColor(BLACK)
window_5:bgColor(REDALPHA)
window_5:fontSize(12)
window_5:textAlign(TextAlign.CENTER)
window_5:cornerRadius(45)
window_5:positionType(PositionType.ABSOLUTE)
window_5:positionRight(50)
window_5:positionTop(300)
window_5:onClick(function()
-- print("确定------>")
paramsModel.childView[paramsModel.curChildPos.__get].params=childParamsModel.params.__get
end)
window:addView(window_5)
local stackParamsLayout = TableView()
ui_views.stackParamsLayout = stackParamsLayout
stackParamsLayout:bgColor(WHITE)
stackParamsLayout:widthPercent(100)
stackParamsLayout:height(260)
DataBinding:bindListView(paramsModel.stackParams.__path, stackParamsLayout)
local stackParamsLayout_adapter = TableViewAutoFitAdapter()
stackParamsLayout_adapter:sectionCount(function()
return DataBinding:getSectionCount(paramsModel.stackParams.__path)
end)
stackParamsLayout_adapter:rowCount(function(section)
return DataBinding:getRowCount(paramsModel.stackParams.__path, section)
end)
stackParamsLayout_adapter:initCellByReuseId("Label", function(_cell_)
local contentView_1 = Label()
_cell_.contentView_1 = contentView_1
_cell_.contentView_1:text("test")
_cell_.contentView:addView(_cell_.contentView_1)
end)
stackParamsLayout_adapter:fillCellDataByReuseId("Label", function(_cell_, section, row)
local _l_c_item=paramsModel.stackParams[section][row]
BindMetaPush(_cellBinds)
BindMetaWatchListCell(paramsModel.stackParams,section,row)
end)
stackParamsLayout_adapter:reuseId(function(section, row)
return  "Label"
end)
stackParamsLayout:adapter(stackParamsLayout_adapter)
window:addView(stackParamsLayout)
local childParamsLayout = ScrollView()
ui_views.childParamsLayout = childParamsLayout
childParamsLayout:bgColor(WHITE)
childParamsLayout:display(false)
childParamsLayout:widthPercent(100)
childParamsLayout:height(260)
local childParamsLayout_sf_1 = function()
local _v_6 = {}
for index2=1, (paramsModel.childView[paramsModel.curChildPos.__get].params.__asize) do
local _p_i_3=index2
local _v_6_=(function()
-- print("create childView ", index2)
if index2 == 1 then
return  (function()
local var_11=index2
local childParamsLayout_var3_1 = VStack()
ui_views.childParamsLayout_var3_1 = childParamsLayout_var3_1
childParamsLayout_var3_1:padding(10, 10, 10, 10)
childParamsLayout_var3_1:widthPercent(100)
local childParamsLayout_var3_1_1 = Label()
ui_views.childParamsLayout_var3_1_1 = childParamsLayout_var3_1_1
childParamsLayout_var3_1_1:text(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__get)
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__watch=function(new, old)
childParamsLayout_var3_1_1:text(new)
end
childParamsLayout_var3_1_1:marginBottom(10)
childParamsLayout_var3_1_1:setTextFontStyle(FontStyle.BOLD)
local childParamsLayout_var3_1_2 = HStack()
ui_views.childParamsLayout_var3_1_2 = childParamsLayout_var3_1_2
childParamsLayout_var3_1_2:wrap(Wrap.WRAP)
local childParamsLayout_var3_1_2_sf_1 = function()
local _v_2 = {}
for index3=1, (paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params.__asize) do
local _p_i_12=index3
local _v_2_=(function()
return  (function()
local var_13=var_11
local var_14=index3
local childParamsLayout_var3_1_2_var4_1 = Label()
ui_views.childParamsLayout_var3_1_2_var4_1 = childParamsLayout_var3_1_2_var4_1
childParamsLayout_var3_1_2_var4_1:text(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].name.__get)
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].name.__watch=function(new, old)
childParamsLayout_var3_1_2_var4_1:text(new)
end
_view_set_style_with_filter(childParamsLayout_var3_1_2_var4_1,labelStyle,{})
childParamsLayout_var3_1_2_var4_1:onClick(function()
--[[
print("scrollview--->" .. paramsModel.curChildPos.__get .. "," .. var_13 .. "," .. var_14)
print("label——self--->preIndex=" .. paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get .. ",choosedIndex=" .. var_14)
]]--
if not paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].isChoosed.__get then 
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].isChoosed=not paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].isChoosed.__get
preIndex=paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get
--[[
print("preindex-->" .. tostring(paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get))
--]]
if paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get>0 then 
paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].params[paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get].isChoosed=not paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].params[paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex.__get].isChoosed.__get
end 
paramsModel.childView[paramsModel.curChildPos.__get].params[var_13].choosedIndex=var_14
childParamsModel.params[1]=paramsModel.childView[paramsModel.curChildPos.__get].params[1].__get
end
end)
local watch_f_3 = function()
 if paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].isChoosed.__get then 
childParamsLayout_var3_1_2_var4_1:textColor(RED):borderColor(RED):borderWidth(2):bgColor(REDALPHA)
else 
childParamsLayout_var3_1_2_var4_1:textColor(BLACK):borderWidth(0):bgColor(GRAY)
end
end
watch_f_3()
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params[_p_i_12].isChoosed.__watch=watch_f_3
return childParamsLayout_var3_1_2_var4_1
end)()
end)()
if _v_2_ then table.insert(_v_2,_v_2_) end
end 
BindMetaPopForach()
return _v_2
end
local childParamsLayout_var3_1_2_add = function()
local childParamsLayout_var3_1_2_s = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(childParamsLayout_var3_1_2_s, _v)
end
elseif _v_ then
table.insert(childParamsLayout_var3_1_2_s, _v_)
end
end
add(childParamsLayout_var3_1_2_sf_1())
childParamsLayout_var3_1_2:children(childParamsLayout_var3_1_2_s)
end
BindMetaPush(_watchIds)
childParamsLayout_var3_1_2_add()
local childParamsLayout_var3_1_2_add_ws=BindMetaPop(_watchIds)
paramsModel.curChildPos.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_var3_1_2_add_ws)
childParamsLayout_var3_1_2:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_var3_1_2_add()
childParamsLayout_var3_1_2_add_ws=BindMetaPop(_watchIds)
end
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].params.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_var3_1_2_add_ws)
childParamsLayout_var3_1_2:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_var3_1_2_add()
childParamsLayout_var3_1_2_add_ws=BindMetaPop(_watchIds)
end
childParamsLayout_var3_1:children({childParamsLayout_var3_1_1, childParamsLayout_var3_1_2})
return childParamsLayout_var3_1
end)()
else
return  (function()
local var_15=index2
local childParamsLayout_var5_1 = VStack()
ui_views.childParamsLayout_var5_1 = childParamsLayout_var5_1
childParamsLayout_var5_1:padding(10, 10, 10, 10)
childParamsLayout_var5_1:widthPercent(100)
local childParamsLayout_var5_1_1 = HStack()
ui_views.childParamsLayout_var5_1_1 = childParamsLayout_var5_1_1
local title = Label()
ui_views.title = title
title:text(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__get)
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__watch=function(new, old)
title:text(new)
end
title:setTextFontStyle(FontStyle.BOLD)
local childParamsLayout_var5_1_1_2 = Switch()
ui_views.childParamsLayout_var5_1_1_2 = childParamsLayout_var5_1_1_2
childParamsLayout_var5_1_1_2:display(false)
childParamsLayout_var5_1_1_2:width(50)
childParamsLayout_var5_1_1_2:height(40)
childParamsLayout_var5_1_1_2:setSwitchChangedCallback(function(isOn)
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].isAbsolute=isOn
childParamsModel.params[10].isAbsolute=isOn
end)
local watch_f_4 = function()
 if var_15 == 10 then 
childParamsLayout_var5_1_1_2:display(true)
childParamsLayout_var5_1_1_2:on(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].isAbsolute.__get)
if paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].isAbsolute.__get then 
title:text(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__get .. "-->绝对")
else 
title:text(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__get .. "-->相对")
end
end
end
watch_f_4()
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].isAbsolute.__watch=watch_f_4
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].title.__watch=watch_f_4
childParamsLayout_var5_1_1:children({title, childParamsLayout_var5_1_1_2})
local childParamsLayout_var5_1_2 = HStack()
ui_views.childParamsLayout_var5_1_2 = childParamsLayout_var5_1_2
local childParamsLayout_var5_1_2_sf_1 = function()
local _v_3 = {}
for index=1, (paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].values.__asize) do
local _p_i_16=index
local _v_3_=(function()
return  (function()
local var_17=var_15
local var_18=index
local childParamsLayout_var5_1_2_var6_1 = EditTextView()
ui_views.childParamsLayout_var5_1_2_var6_1 = childParamsLayout_var5_1_2_var6_1
childParamsLayout_var5_1_2_var6_1:width(75)
childParamsLayout_var5_1_2_var6_1:singleLine(true)
childParamsLayout_var5_1_2_var6_1:textAlign(TextAlign.CENTER)
childParamsLayout_var5_1_2_var6_1:inputMode(EditTextViewInputMode.Number)
childParamsLayout_var5_1_2_var6_1:padding(8, 5, 8, 5)
childParamsLayout_var5_1_2_var6_1:marginTop(3):marginRight(5):marginBottom(3):marginLeft(5)
childParamsLayout_var5_1_2_var6_1:borderColor(BLACK)
childParamsLayout_var5_1_2_var6_1:borderWidth(2)
childParamsLayout_var5_1_2_var6_1:cornerRadius(8)
local watch_f_5 = function()
 if tonumber(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].values[_p_i_16].__get)>0 then 
childParamsLayout_var5_1_2_var6_1:text(tostring(paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].values[_p_i_16].__get))
else 
childParamsLayout_var5_1_2_var6_1:text("")
end
end
watch_f_5()
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].values.__watch=watch_f_5
childParamsLayout_var5_1_2_var6_1:setEndChangedCallback(function(str)
-- print("edit--->" .. str)
if str ~= "" then 
temp=tonumber(str)
else 
temp=0
end 
childParamsModel.params[var_17].values[var_18]=temp
-- print(childParamsModel.params[var_17].values[var_18].__get)
end)
keyboardManager:bindEditText(keyboardManager.WINDOW_PUSH, childParamsLayout_var5_1_2_var6_1, 0, null)
return childParamsLayout_var5_1_2_var6_1
end)()
end)()
if _v_3_ then table.insert(_v_3,_v_3_) end
end 
BindMetaPopForach()
return _v_3
end
local childParamsLayout_var5_1_2_add = function()
local childParamsLayout_var5_1_2_s = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(childParamsLayout_var5_1_2_s, _v)
end
elseif _v_ then
table.insert(childParamsLayout_var5_1_2_s, _v_)
end
end
add(childParamsLayout_var5_1_2_sf_1())
childParamsLayout_var5_1_2:children(childParamsLayout_var5_1_2_s)
end
BindMetaPush(_watchIds)
childParamsLayout_var5_1_2_add()
local childParamsLayout_var5_1_2_add_ws=BindMetaPop(_watchIds)
paramsModel.childView[paramsModel.curChildPos.__get].params[_p_i_3].values.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_var5_1_2_add_ws)
childParamsLayout_var5_1_2:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_var5_1_2_add()
childParamsLayout_var5_1_2_add_ws=BindMetaPop(_watchIds)
end
paramsModel.curChildPos.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_var5_1_2_add_ws)
childParamsLayout_var5_1_2:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_var5_1_2_add()
childParamsLayout_var5_1_2_add_ws=BindMetaPop(_watchIds)
end
childParamsLayout_var5_1:children({childParamsLayout_var5_1_1, childParamsLayout_var5_1_2})
return childParamsLayout_var5_1
end)()
end 
end)()
if _v_6_ then table.insert(_v_6,_v_6_) end
end 
BindMetaPopForach()
return _v_6
end
local childParamsLayout_1 = Label()
ui_views.childParamsLayout_1 = childParamsLayout_1
childParamsLayout_1:text("当前选中Label--->" .. paramsModel.childView[paramsModel.curChildPos.__get].text.__get)
paramsModel.childView[paramsModel.curChildPos.__get].text.__watch=function(new, old)
childParamsLayout_1:text("当前选中Label--->" .. new)
end
childParamsLayout_1:textColor(PURPLE)
childParamsLayout_1:padding(10, 10, 10, 10)
local childParamsLayout_add = function()
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
childParamsLayout:addView(_v)
end
elseif _v_ then
childParamsLayout:addView(_v_)
end
end
add(childParamsLayout_1)
add(childParamsLayout_sf_1())
end
BindMetaPush(_watchIds)
childParamsLayout_add()
local childParamsLayout_add_ws=BindMetaPop(_watchIds)
paramsModel.childView[paramsModel.curChildPos.__get].params.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_add_ws)
childParamsLayout:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_add()
childParamsLayout_add_ws=BindMetaPop(_watchIds)
end
paramsModel.curChildPos.__watch=function(new, old)
BindMetaRemoveWatchs(childParamsLayout_add_ws)
childParamsLayout:removeAllSubviews()
BindMetaPush(_watchIds)
childParamsLayout_add()
childParamsLayout_add_ws=BindMetaPop(_watchIds)
end
keyboardManager:bindView(childParamsLayout, 5)
childParamsLayout:keyboardDismiss(true)
window:addView(childParamsLayout)
window:bgColor(WHITE)
keyboardManager:keyboardOffset(0)
window:keyboardDismiss(true)
