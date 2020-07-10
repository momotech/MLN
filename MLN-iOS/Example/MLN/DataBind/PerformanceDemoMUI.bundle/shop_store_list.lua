--1
ui_views = {}
PURPLE=Color(100, 100, 200, 1)
WHITE=Color(255, 255, 255, 1)
ICON_ADD="https://s.momocdn.com/w/u/others/custom/MLNUI/icon_add.png"
ICON_SUB="https://s.momocdn.com/w/u/others/custom/MLNUI/icon_sub.png"
style={
padding = {0, 10, 0, 10},
setTextFontStyle = FontStyle.BOLD,
fontSize = 16,
bgColor = WHITE
}
require("packet/BindMeta")
if goodsData== nil then 
goodsData= BindMeta("goodsData")
end
require("packet/style")
local window_1 = VStack()
ui_views.window_1 = window_1
window_1:widthPercent(100)
window_1:heightPercent(100)
window_1:bgColor(WHITE)
local window_1_1 = TableView()
ui_views.window_1_1 = window_1_1
window_1_1:bgColor(Color(200, 200, 200, 1))
window_1_1:widthPercent(100)
window_1_1:basis(1)
goodsData.list.__watch=function(new,old)
print("watch_goodsData.list---->" ..#new .. ",")
end
DataBinding:bindListView(goodsData.list.__path, window_1_1)
local window_1_1_adapter = TableViewAutoFitAdapter()
window_1_1_adapter:sectionCount(function()
return DataBinding:getSectionCount(goodsData.list.__path)
end)
window_1_1_adapter:rowCount(function(section)
return DataBinding:getRowCount(goodsData.list.__path, section)
end)
window_1_1_adapter:initCellByReuseId("itemLayout", function(_cell_)
local contentView_1 = HStack()
_cell_.contentView_1 = contentView_1
_cell_.contentView_1:widthPercent(100)
_cell_.contentView_1:padding(10, 10, 10, 10)
_cell_.contentView_1:height(80)
_cell_.contentView_1:crossAxis(CrossAxis.CENTER)
local contentView_1_1 = ImageView()
_cell_.contentView_1_1 = contentView_1_1
_cell_.contentView_1_1:width(60)
_cell_.contentView_1_1:height(60)
local contentView_1_2 = VStack()
_cell_.contentView_1_2 = contentView_1_2
_cell_.contentView_1_2:marginLeft(10)
_cell_.contentView_1_2:mainAxis(MainAxis.SPACE_EVENLY)
local contentView_1_2_1 = Label()
_cell_.contentView_1_2_1 = contentView_1_2_1
local contentView_1_2_2 = Label()
_cell_.contentView_1_2_2 = contentView_1_2_2
_cell_.contentView_1_2_2:textColor(PURPLE)
_cell_.contentView_1_2_2:crossSelf(CrossAxis.END)
local contentView_1_2_3 = Label()
_cell_.contentView_1_2_3 = contentView_1_2_3
_cell_.contentView_1_2_3:textColor(PURPLE)
_cell_.contentView_1_2:children({_cell_.contentView_1_2_1, _cell_.contentView_1_2_2, _cell_.contentView_1_2_3})
local contentView_1_3 = Spacer()
_cell_.contentView_1_3 = contentView_1_3
local contentView_1_4 = HStack()
_cell_.contentView_1_4 = contentView_1_4
local subNum = ImageView()
_cell_.subNum = subNum
_cell_.subNum:image(ICON_SUB)
_cell_.subNum:display(false)
_cell_.subNum:crossSelf(CrossAxis.CENTER)
_cell_.subNum:width(30)
_cell_.subNum:height(30)
local goodsNum = Label()
_cell_.goodsNum = goodsNum
_cell_.goodsNum:display(false)
_cell_.goodsNum:fontSize(16)
_cell_.goodsNum:setTextFontStyle(FontStyle.BOLD)
_cell_.goodsNum:width(50)
_cell_.goodsNum:height(50)
_cell_.goodsNum:textAlign(TextAlign.CENTER)
local addNum = ImageView()
_cell_.addNum = addNum
_cell_.addNum:image(ICON_ADD)
_cell_.addNum:crossSelf(CrossAxis.CENTER)
_cell_.addNum:width(30)
_cell_.addNum:height(30)
_cell_.contentView_1_4:children({_cell_.subNum, _cell_.goodsNum, _cell_.addNum})
_cell_.contentView_1:children({_cell_.contentView_1_1, _cell_.contentView_1_2, _cell_.contentView_1_3, _cell_.contentView_1_4})
_cell_.contentView:addView(_cell_.contentView_1)
end)
window_1_1_adapter:fillCellDataByReuseId("itemLayout", function(_cell_, section, row)
local _l_c_item=goodsData.list[section][row]
BindMetaPush(_cellBinds)_cell_.contentView_1_1:image(_l_c_item.img.__get)
_cell_.contentView_1_2_1:text(_l_c_item.name.__get)
_cell_.contentView_1_2_2:text(_l_c_item.discount.__get .. "折" .. " 原¥" .. _l_c_item.price.__get)
_cell_.contentView_1_2_3:text("折后¥" .. _l_c_item.price.__get*_l_c_item.discount.__get/10)
_cell_.subNum:onClick(function()
print("--")
goodsData.totalNum=goodsData.totalNum.__get-1
if _l_c_item.num.__get>0 then 
_l_c_item.num=_l_c_item.num.__get-1
end
end)
_cell_.goodsNum:text(_l_c_item.num.__get .. "")
print("bind-->" .. _l_c_item.name.__get .. "," .. _l_c_item.num.__get)
for i=1, (goodsData.list.__asize) do
local _p_i_1=i
print(goodsData.list[_p_i_1].name.__get .. "-->" .. goodsData.list[_p_i_1].num.__get)
end 
BindMetaPopForach()
isHidden=(_l_c_item.num.__get <= 0)
_cell_.subNum:display(not isHidden)
_cell_.goodsNum:display(not isHidden)
_cell_.addNum:onClick(function()
print("++")
goodsData.totalNum=goodsData.totalNum.__get+1
_l_c_item.num=_l_c_item.num.__get+1
end)

BindMetaWatchListCell(goodsData.list,section,row)
end)
window_1_1_adapter:reuseId(function(section, row)
return  "itemLayout"
end)
window_1_1:adapter(window_1_1_adapter)
local window_1_2 = HStack()
ui_views.window_1_2 = window_1_2
window_1_2:widthPercent(100)
window_1_2:height(60)
window_1_2:bgColor(Color(120, 180, 0, 0.2))
window_1_2:mainAxis(MainAxis.SPACE_BETWEEN)
window_1_2:crossAxis(CrossAxis.CENTER)
local window_1_2_1 = Label()
ui_views.window_1_2_1 = window_1_2_1
window_1_2_1:text("清空购物车( " .. goodsData.totalNum.__get .. ")")
goodsData.totalNum.__watch=function(new, old)
window_1_2_1:text("清空购物车( " .. new .. ")")
end
window_1_2_1:textColor(PURPLE)
window_1_2_1:textAlign(TextAlign.CENTER)
window_1_2_1:heightPercent(100)
_view_set_style_with_filter(window_1_2_1,style,{"textColor","textAlign","heightPercent"})
window_1_2_1:onClick(function()
 for i=1, (goodsData.list.__asize) do
local _p_i_2=i
goodsData.list[_p_i_2].num=0
end 
BindMetaPopForach()
goodsData.totalNum=0
end)
local var_5="修改第1行"
local window_1_2_2 = Label()
ui_views.window_1_2_2 = window_1_2_2
window_1_2_2:text(var_5)
window_1_2_2:textColor(PURPLE)
_view_set_style_with_filter(window_1_2_2,style,{"text","textColor","textAlign","heightPercent"})
window_1_2_2:textAlign(TextAlign.CENTER)
window_1_2_2:heightPercent(100)
window_1_2_2:onClick(function()
goodsData.list[1]={
img="https://hbimg.huabanimg.com/973de16798446890fc3b5f55a978db53c36059e619f83-5eeIuJ_fw658",
name="修改11111",
discount=1.1,
price=11.1,
num=6}
for i=1, (goodsData.list.__asize) do
local _p_i_3=i
print(goodsData.list[_p_i_3].name.__get .. "-->" .. goodsData.list[_p_i_3].num.__get)
end 
BindMetaPopForach()
end)
local var_6="新增"
local window_1_2_3 = Label()
ui_views.window_1_2_3 = window_1_2_3
window_1_2_3:text(var_6)
window_1_2_3:textColor(PURPLE)
_view_set_style_with_filter(window_1_2_3,style,{"text","textColor","heightPercent"})
window_1_2_3:heightPercent(100)
window_1_2_3:onClick(function()
table.insert(goodsData.list, 1, {
img="https://hbimg.huabanimg.com/973de16798446890fc3b5f55a978db53c36059e619f83-5eeIuJ_fw658",
name="新增",
discount=6.6,
price=66,
num=0})
for i=1, (goodsData.list.__asize) do
local _p_i_4=i
print(goodsData.list[_p_i_4].name.__get .. "-->" .. goodsData.list[_p_i_4].num.__get)
end 
BindMetaPopForach()
end)
local var_7="删除"
local window_1_2_4 = Label()
ui_views.window_1_2_4 = window_1_2_4
window_1_2_4:text(var_7)
window_1_2_4:textColor(PURPLE)
_view_set_style_with_filter(window_1_2_4,style,{"text","textColor","heightPercent"})
window_1_2_4:heightPercent(100)
window_1_2_4:onClick(function()
table.remove(goodsData.list, -1)
end)
window_1_2:children({window_1_2_1, window_1_2_2, window_1_2_3, window_1_2_4})
window_1:children({window_1_1, window_1_2})
goodsData.totalNum.__watch=function(new,old)
print("watch_goodsData.totalNum--->" .. new .. ",")
end
window:addView(window_1)
