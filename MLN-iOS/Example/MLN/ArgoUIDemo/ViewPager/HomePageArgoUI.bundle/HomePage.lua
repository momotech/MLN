--1

require("packet/TabSegment")
require("packet/ViewPagerAdapter")
require("packet/ViewPager")
require("packet/BindMeta")
if homeData== nil then
homeData= BindMeta("homeData")
end
if kuaModel== nil then
kuaModel= BindMeta("kuaModel")
end
if cellModel== nil then
cellModel= BindMeta("cellModel")
end
keyboardManager = require("packet/KeyboardManager")
keyboardManager:init(window)
if ui_views == nil then
ui_views=setmetatable({}, { __mode = 'v'})
BindMetaCreateFindGID(ui_views)
end
require("KK.KuaKua")
RED=Color(180, 100, 100, 0.8)
YELLOW=Color(220, 200, 100, 0.8)
PURPLE=Color(100, 100, 200, 0.8)
COLORS={PURPLE,
RED,
YELLOW}
preTabIndex=1
window:safeArea(SafeArea.TOP)
local vwj1 = TabSegment()
ui_views.vwj1 = vwj1
vwj1:bindData({"11111111",
"222222222",
"333333333",
"4444444",
"5555555"})
vwj1:bindCell(function(item)
 return  (function(_argo_break)
local vwj32 = Label()
ui_views.vwj32 = vwj32
vwj32:text(item)
return vwj32
end)('@argo@')
end)
window:addView(vwj1.contentView)
local vp = ViewPager()
ui_views.vp = vp
vp:basis(1)
vp:spacing(5)
local vp_adapter = ViewPagerAdapter()
vp:adapter(vp_adapter)
vp_adapter:initCellByReuseId("mPage", function(_l_c1)
--@&$local kvar3=_l_i1.page$--&@
local vwj3 = VStack()
_l_c1.vwj3 = vwj3
local vwj4 = TableView()
_l_c1.vwj4 = vwj4
_l_c1.vwj4_adapter = TableViewAutoFitAdapter()
_l_c1.vwj4:adapter(_l_c1.vwj4_adapter)
_l_c1.vwj4_adapter:initCellByReuseId("mainCell", function(_l_c2)
--@&$local kvar4=_l_i2$--&@
local kvar5=KUA_CELL_TYPE.MAIN
local vwj5 = VStack()
_l_c2.vwj5 = vwj5
local vwj6 = VStack()
_l_c2.vwj6 = vwj6
--@&$local kvar6=kvar4$--&@
local kvar7=kvar5
local vwj7 = VStack()
_l_c2.vwj7 = vwj7
local vwj8 = HStack()
_l_c2.vwj8 = vwj8
local vwj9 = ImageView()
_l_c2.vwj9 = vwj9
_l_c2.vwj9:cornerRadius(29)
_l_c2.vwj9:height(58)
_l_c2.vwj9:width(58)
_l_c2.vwj9:contentMode(ContentMode.SCALE_ASPECT_FILL)
local vwj10 = VStack()
_l_c2.vwj10 = vwj10
local vwj11 = Label()
_l_c2.vwj11 = vwj11
_l_c2.vwj11:fontSize(14)
_l_c2.vwj11:lines(1)
_l_c2.vwj11:textColor(Color(0, 0, 0, 1))
local vwj12 = Label()
_l_c2.vwj12 = vwj12
_l_c2.vwj12:fontSize(14)
_l_c2.vwj12:textColor(Color(162, 162, 162, 1))
_l_c2.vwj12:marginTop(10)
_l_c2.vwj10:children({_l_c2.vwj11, _l_c2.vwj12})
_l_c2.vwj10:marginLeft(8)
_l_c2.vwj10:basis(1)
local vwj13 = Label()
_l_c2.vwj13 = vwj13
_l_c2.vwj13:text("+ 好友")
_l_c2.vwj13:textColor(Color(78, 200, 193, 1))
_l_c2.vwj13:display(kvar7 == 2)
local vwj14 = Label()
_l_c2.vwj14 = vwj14
_l_c2.vwj14:text("4分钟前")
_l_c2.vwj14:textColor(Color():hex(13553358))
_l_c2.vwj14:display(kvar7 == 1)
_l_c2.vwj8:children({_l_c2.vwj9, _l_c2.vwj10, _l_c2.vwj13, _l_c2.vwj14})
_l_c2.vwj8:widthPercent(100)
_l_c2.vwj8:crossAxis(CrossAxis.CENTER)
local vwj15 = Label()
_l_c2.vwj15 = vwj15
_l_c2.vwj15:textColor(Color():hex(6645093))
_l_c2.vwj15:fontSize(16)
_l_c2.vwj15:marginTop(4)
_l_c2.vwj15:lines(4)
local vwj16 = HStack()
_l_c2.vwj16 = vwj16
_l_c2.vwj16:widthPercent(100)
_l_c2.vwj16:cornerRadius(1)
local vwj17 = ImageView()
_l_c2.vwj17 = vwj17
_l_c2.vwj17:cornerRadius(6)
_l_c2.vwj17:widthPercent(100)
_l_c2.vwj17:height(300)
_l_c2.vwj17:contentMode(ContentMode.SCALE_ASPECT_FILL)
local vwj18 = HStack()
_l_c2.vwj18 = vwj18
local vwj19 = ImageView()
_l_c2.vwj19 = vwj19
_l_c2.vwj19:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062704301-likeH.png")
_l_c2.vwj19:width(25)
_l_c2.vwj19:height(25)
local vwj20 = Label()
_l_c2.vwj20 = vwj20
_l_c2.vwj20:marginLeft(6)
_l_c2.vwj20:marginRight(20)
_l_c2.vwj20:textColor(Color(1, 1, 1, 1))
local vwj21 = ImageView()
_l_c2.vwj21 = vwj21
_l_c2.vwj21:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062894566-comment.png")
_l_c2.vwj21:width(25)
_l_c2.vwj21:height(25)
local vwj22 = Label()
_l_c2.vwj22 = vwj22
_l_c2.vwj22:marginLeft(6)
_l_c2.vwj22:textColor(Color(1, 1, 1, 1))
local vwj23 = Spacer()
_l_c2.vwj23 = vwj23
local vwj24 = ImageView()
_l_c2.vwj24 = vwj24
_l_c2.vwj24:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062992926-share.png")
_l_c2.vwj24:width(25)
_l_c2.vwj24:height(25)
_l_c2.vwj18:children({_l_c2.vwj19, _l_c2.vwj20, _l_c2.vwj21, _l_c2.vwj22, _l_c2.vwj23, _l_c2.vwj24})
_l_c2.vwj18:marginTop(18)
_l_c2.vwj18:crossAxis(CrossAxis.CENTER)
_l_c2.vwj18:widthPercent(100)
_l_c2.vwj18:marginBottom(18)
_l_c2.vwj7:children({_l_c2.vwj8, _l_c2.vwj15, _l_c2.vwj16, _l_c2.vwj17, _l_c2.vwj18})
_l_c2.vwj7:widthPercent(100)
local vwj25 = VStack()
_l_c2.vwj25 = vwj25
_l_c2.vwj25:widthPercent(100)
_l_c2.vwj25:height(120)
_l_c2.vwj25:cornerRadius(1)
 
local vwj26 = Label()
_l_c2.vwj26 = vwj26
_l_c2.vwj26:text("查看236条夸夸评论")
_l_c2.vwj26:textColor(Color():hex(11447982))
_l_c2.vwj26:fontSize(14)
_l_c2.vwj26:marginBottom(8)
local vwj27 = HStack()
_l_c2.vwj27 = vwj27
_l_c2.vwj27:widthPercent(100)
_l_c2.vwj27:height(1)
_l_c2.vwj27:bgColor(Color():hex(13553358))
_l_c2.vwj27:marginBottom(14)
local vwj28 = HStack()
_l_c2.vwj28 = vwj28
_l_c2.vwj28:crossAxis(CrossAxis.CENTER)
local vwj29 = ImageView()
_l_c2.vwj29 = vwj29
_l_c2.vwj29:cornerRadius(14)
_l_c2.vwj29:height(28)
_l_c2.vwj29:width(28)
_l_c2.vwj29:contentMode(ContentMode.SCALE_ASPECT_FILL)
local vwj30 = EditTextView()
_l_c2.vwj30 = vwj30
_l_c2.vwj30:text("夸夸我...")
_l_c2.vwj30:textColor(Color():hex(11447982))
_l_c2.vwj30:fontSize(16)
_l_c2.vwj30:marginLeft(6)
keyboardManager:bindEditText(keyboardManager.WINDOW_PUSH, _l_c2.vwj30, 0, null)
_l_c2.vwj28:children({_l_c2.vwj29, _l_c2.vwj30})
_l_c2.vwj6:children({_l_c2.vwj7, _l_c2.vwj25, _l_c2.vwj26, _l_c2.vwj27, _l_c2.vwj28})
_l_c2.vwj6:borderWidth(2.5)
_l_c2.vwj6:borderColor(Color():hex(0))
_l_c2.vwj6:cornerRadius(10)
_l_c2.vwj6:widthPercent(100)
_l_c2.vwj6:padding(10, 20, 14, 20)
_l_c2.vwj5:children({_l_c2.vwj6})
_l_c2.vwj5:widthPercent(100)
_l_c2.vwj5:padding(8, 8, 8, 8)
_l_c2.contentView:addView(_l_c2.vwj5)
end)
local vwj31 = ImageView()
_l_c1.vwj31 = vwj31
_l_c1.vwj31:image("https://s.momocdn.com/w/u/others/2020/07/20/1595220387718-add.png")
_l_c1.vwj31:height(60)
_l_c1.vwj31:width(60)
_l_c1.vwj31:positionType(PositionType.ABSOLUTE)
_l_c1.vwj31:positionRight(15)
_l_c1.vwj31:positionBottom(15)
_l_c1.vwj31:cornerRadius(30)
_l_c1.vwj3:children({_l_c1.vwj4, _l_c1.vwj31})
_l_c1.vwj3:widthPercent(100)
_l_c1.vwj3:basis(1)
_l_c1.contentView:addView(_l_c1.vwj3)
end)
DataBinding:bindListView(homeData.pageModels.__path,vp.contentView)
vp_adapter:getCount(function()
 return DataBinding:getRowCount(homeData.pageModels.__path, 1)
end)
vp_adapter:fillCellDataByReuseId("mPage", function(_l_c1, row1)
local _l_i1=homeData.pageModels[row1].__ci
local kvar3=_l_i1.page
DataBinding:bindListView(kvar3.__path,_l_c1.vwj4)
_l_c1.vwj4_adapter:sectionCount(function()
return DataBinding:getSectionCount(kvar3.__path)
end)
_l_c1.vwj4_adapter:rowCount(function(section2)
return  DataBinding:getRowCount(kvar3.__path,section2)
end)
_l_c1.vwj4_adapter:fillCellDataByReuseId("mainCell", function(_l_c2,section2,row2)
local _l_i2=kvar3[section2][row2].__ci
local kvar4=_l_i2
local kvar5=KUA_CELL_TYPE.MAIN
local kvar6=kvar4
local kvar7=kvar5
_l_c2.vwj9:image(kvar6.icon.__get)
_l_c2.vwj11:text(kvar6.name.__get)
_l_c2.vwj12:text(kvar6.desc.__get)
_l_c2.vwj15:text(kvar6.content.__get)
local kvar10 = function()
local kvar2 = {}
for kvar1=1, (kvar6.actions.__asize) do
local kvar8=kvar1
local kvar2_=(function()
return  (function(_argo_break)
local vwj33 = Label()
ui_views.vwj33 = vwj33
vwj33 = vwj33
vwj33:text(kvar6.actions[kvar8].__get)
vwj33:marginRight(8)
vwj33:textColor(Color(78, 200, 193, 1))
return vwj33
end)('@argo@')
end)()
if kvar2_ then table.insert(kvar2,kvar2_) end
end
BindMetaPopForach()
return kvar2
end
local kvar13 = function()
local kvar12 = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(kvar12, _v)
end
elseif _v_ then
table.insert(kvar12, _v_)
end
end
add(kvar10())
_l_c2.vwj16:children(kvar12)
end
_l_c2.vwj16:removeAllSubviews()
kvar13()
_l_c2.vwj17:image(kvar6.pic.__get)
_l_c2.vwj20:text(kvar6.like.__get)
_l_c2.vwj22:text(kvar6.comment.__get)
_l_c2.vwj29:image(kvar4.icon.__get)
BindMetaWatchListCell(kvar3,section2,row2)
end)
_l_c1.vwj4_adapter:reuseId(function(section2, row2)
return  "mainCell"
end)
_l_c1.vwj4_adapter:cellWillAppear(function(cell, section, row)
 
end)
_l_c1.vwj4:reloadData()
BindMetaWatchListCell(homeData.pageModels,-1,row1)
end)
vp_adapter:reuseId(function(row1)
return  "mPage"
end)
vp.contentView:reloadData()
vwj1:bindViewPager(vp)
window:addView(vp.contentView)
keyboardManager:keyboardOffset(0)
window:keyboardDismiss(true)
