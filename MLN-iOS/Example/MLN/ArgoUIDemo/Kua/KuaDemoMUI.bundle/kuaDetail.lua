--1

require("packet/BindMeta")
if userData== nil then 
userData= BindMeta("userData")
end
require("packet/style")
if ui_views == nil then 
ui_views=setmetatable({}, { __mode = 'v'})
BindMetaCreateFindGID(ui_views)
end
require("KuaCell")
local backImg="https://s.momocdn.com/w/u/others/2020/07/13/1594631804940-back.png"
Style={
nav={
{bgColor = Color(78, 200, 193, 1)},
{mainAxis = MainAxis.CENTER},
{height = 70},
{widthPercent = 100},
{crossAxis = CrossAxis.CENTER}
},
backImg={
{width = 24},
{height = 24},
{positionType = PositionType.ABSOLUTE},
{positionLeft = 10}
}
}
local vwj1 = VStack()
ui_views.vwj1 = vwj1
local vwj2 = HStack()
ui_views.vwj2 = vwj2
local vwj3 = ImageView()
ui_views.vwj3 = vwj3
vwj3:image(backImg)
_view_set_style_with_filter(vwj3,Style.backImg,{image=true})
local vwj4 = Label()
ui_views.vwj4 = vwj4
vwj4:text(userData.title.__get)
userData.title.__watch=function(new)
vwj4:text(new)
end
vwj4:textColor(Color():hex(16777215))
vwj2:children({vwj3, vwj4})
_view_set_style_with_filter(vwj2,Style.nav,{})
local vwj5 = TableView()
ui_views.vwj5 = vwj5
vwj5:marginTop(20)
vwj5:basis(1)
vwj5:marginBottom(45)
local vwj5_adapter = TableViewAutoFitAdapter()
vwj5:adapter(vwj5_adapter)
vwj5_adapter:initCellByReuseId("contentCell", function(_l_c1)
--@&$local kvar3=_l_i1$--&@
local kvar4=KUA_CELL_TYPE.DETAIL
local vwj6 = VStack()
_l_c1.vwj6 = vwj6
--@&$local kvar5=kvar3$--&@
local kvar6=KUA_CELL_TYPE.DETAIL
local vwj7 = VStack()
_l_c1.vwj7 = vwj7
local vwj8 = HStack()
_l_c1.vwj8 = vwj8
local vwj9 = ImageView()
_l_c1.vwj9 = vwj9
_l_c1.vwj9:cornerRadius(29)
_l_c1.vwj9:height(58)
_l_c1.vwj9:width(58)
_l_c1.vwj9:contentMode(ContentMode.SCALE_ASPECT_FILL)
local vwj10 = VStack()
_l_c1.vwj10 = vwj10
local vwj11 = Label()
_l_c1.vwj11 = vwj11
_l_c1.vwj11:fontSize(20)
_l_c1.vwj11:lines(1)
_l_c1.vwj11:textColor(Color(0, 0, 0, 1))
local vwj12 = Label()
_l_c1.vwj12 = vwj12
_l_c1.vwj12:fontSize(16)
_l_c1.vwj12:textColor(Color(162, 162, 162, 1))
_l_c1.vwj12:marginTop(10)
_l_c1.vwj10:children({_l_c1.vwj11, _l_c1.vwj12})
_l_c1.vwj10:marginLeft(8)
_l_c1.vwj10:basis(1)
local vwj13 = Label()
_l_c1.vwj13 = vwj13
_l_c1.vwj13:text("+ 好友")
_l_c1.vwj13:textColor(Color(78, 200, 193, 1))
_l_c1.vwj13:display(kvar6 == 2)
local vwj14 = Label()
_l_c1.vwj14 = vwj14
_l_c1.vwj14:text("4分钟前")
_l_c1.vwj14:textColor(Color():hex(13553358))
_l_c1.vwj14:display(kvar6 == 1)
_l_c1.vwj8:children({_l_c1.vwj9, _l_c1.vwj10, _l_c1.vwj13, _l_c1.vwj14})
_l_c1.vwj8:widthPercent(100)
local vwj15 = Label()
_l_c1.vwj15 = vwj15
_l_c1.vwj15:textColor(Color():hex(6645093))
_l_c1.vwj15:fontSize(20)
_l_c1.vwj15:marginTop(4)
_l_c1.vwj15:lines(4)
local vwj16 = HStack()
_l_c1.vwj16 = vwj16
_l_c1.vwj16:widthPercent(100)
_l_c1.vwj16:cornerRadius(1)
local vwj17 = ImageView()
_l_c1.vwj17 = vwj17
_l_c1.vwj17:cornerRadius(6)
_l_c1.vwj17:widthPercent(100)
_l_c1.vwj17:height(374)
_l_c1.vwj17:contentMode(ContentMode.SCALE_ASPECT_FILL)
local vwj18 = HStack()
_l_c1.vwj18 = vwj18
local vwj19 = ImageView()
_l_c1.vwj19 = vwj19
_l_c1.vwj19:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062704301-likeH.png")
_l_c1.vwj19:width(30)
_l_c1.vwj19:height(30)
local vwj20 = Label()
_l_c1.vwj20 = vwj20
_l_c1.vwj20:marginRight(14)
_l_c1.vwj20:textColor(Color(1, 1, 1, 1))
local vwj21 = ImageView()
_l_c1.vwj21 = vwj21
_l_c1.vwj21:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062894566-comment.png")
_l_c1.vwj21:width(30)
_l_c1.vwj21:height(30)
local vwj22 = Label()
_l_c1.vwj22 = vwj22
_l_c1.vwj22:textColor(Color(1, 1, 1, 1))
local vwj23 = Spacer()
_l_c1.vwj23 = vwj23
local vwj24 = ImageView()
_l_c1.vwj24 = vwj24
_l_c1.vwj24:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062992926-share.png")
_l_c1.vwj24:width(30)
_l_c1.vwj24:height(30)
_l_c1.vwj18:children({_l_c1.vwj19, _l_c1.vwj20, _l_c1.vwj21, _l_c1.vwj22, _l_c1.vwj23, _l_c1.vwj24})
_l_c1.vwj18:marginTop(18)
_l_c1.vwj18:crossAxis(CrossAxis.CENTER)
_l_c1.vwj18:widthPercent(100)
_l_c1.vwj18:marginBottom(18)
_l_c1.vwj7:children({_l_c1.vwj8, _l_c1.vwj15, _l_c1.vwj16, _l_c1.vwj17, _l_c1.vwj18})
_l_c1.vwj7:widthPercent(100)
_l_c1.vwj6:children({_l_c1.vwj7})
_l_c1.vwj6:widthPercent(100)
_l_c1.vwj6:heightPercent(100)
_l_c1.vwj6:padding(0, 20, 0, 20)
_l_c1.contentView:addView(_l_c1.vwj6)
end)
vwj5_adapter:initCellByReuseId("commentCell", function(_l_c1)
--@&$local kvar8=_l_i1$--&@
local vwj25 = VStack()
_l_c1.vwj25 = vwj25
local vwj26 = VStack()
_l_c1.vwj26 = vwj26
local vwj27 = VStack()
_l_c1.vwj27 = vwj27
_l_c1.vwj27:bgColor(Color():hex(15724527))
_l_c1.vwj27:widthPercent(100)
_l_c1.vwj27:height(8)
local vwj28 = Label()
_l_c1.vwj28 = vwj28
_l_c1.vwj28:text("全部夸夸评论:")
_l_c1.vwj28:textColor(Color():hex(11447982))
_l_c1.vwj28:marginBottom(12)
_l_c1.vwj28:marginTop(10)
_l_c1.vwj28:marginLeft(20)
_l_c1.vwj26:children({_l_c1.vwj27, _l_c1.vwj28})
_l_c1.vwj26:widthPercent(100)
local vwj29 = VStack()
_l_c1.vwj29 = vwj29
local vwj30 = HStack()
_l_c1.vwj30 = vwj30
local vwj31 = ImageView()
_l_c1.vwj31 = vwj31
_view_set_style_with_filter(_l_c1.vwj31,Style.icon,{width=true,height=true})
_l_c1.vwj31:width(40)
_l_c1.vwj31:height(40)
local vwj32 = VStack()
_l_c1.vwj32 = vwj32
local vwj33 = HStack()
_l_c1.vwj33 = vwj33
local vwj34 = Label()
_l_c1.vwj34 = vwj34
_l_c1.vwj34:fontSize(15)
local vwj35 = Spacer()
_l_c1.vwj35 = vwj35
local vwj36 = ImageView()
_l_c1.vwj36 = vwj36
_l_c1.vwj36:image("https://s.momocdn.com/w/u/others/2020/07/18/1595062704301-likeH.png")
_l_c1.vwj36:width(20)
_l_c1.vwj36:height(20)
local vwj37 = Label()
_l_c1.vwj37 = vwj37
_l_c1.vwj37:fontSize(18)
_l_c1.vwj37:marginLeft(4)
_l_c1.vwj37:textColor(Color():hex(11447982))
_l_c1.vwj33:children({_l_c1.vwj34, _l_c1.vwj35, _l_c1.vwj36, _l_c1.vwj37})
_l_c1.vwj33:widthPercent(100)
local vwj38 = HStack()
_l_c1.vwj38 = vwj38
local vwj39 = Label()
_l_c1.vwj39 = vwj39
_l_c1.vwj39:fontSize(15)
_l_c1.vwj39:textColor(Color():hex(16744110))
local vwj40 = Label()
_l_c1.vwj40 = vwj40
_l_c1.vwj40:text("·")
_l_c1.vwj40:textColor(Color():hex(11447982))
local vwj41 = Label()
_l_c1.vwj41 = vwj41
_l_c1.vwj41:fontSize(15)
_l_c1.vwj41:textColor(Color():hex(11447982))
_l_c1.vwj38:children({_l_c1.vwj39, _l_c1.vwj40, _l_c1.vwj41})
local vwj42 = Label()
_l_c1.vwj42 = vwj42
_l_c1.vwj42:fontSize(18)
_l_c1.vwj42:textColor(Color():hex(9013641))
_l_c1.vwj42:lines(0)
local vwj43 = VStack()
_l_c1.vwj43 = vwj43
local vwj44 = HStack()
_l_c1.vwj44 = vwj44
local vwj45 = Label()
_l_c1.vwj45 = vwj45
_l_c1.vwj45:fontSize(18)
_l_c1.vwj45:textColor(Color(78, 200, 193, 1))
_l_c1.vwj45:marginBottom(5)
local vwj46 = Label()
_l_c1.vwj46 = vwj46
_l_c1.vwj46:text(":")
_l_c1.vwj46:fontSize(18)
_l_c1.vwj46:textColor(Color(78, 200, 193, 1))
local vwj47 = Label()
_l_c1.vwj47 = vwj47
_l_c1.vwj47:lines(1)
_l_c1.vwj47:fontSize(18)
_l_c1.vwj47:textColor(Color():hex(11447982))
_l_c1.vwj47:basis(1)
_l_c1.vwj44:children({_l_c1.vwj45, _l_c1.vwj46, _l_c1.vwj47})
_l_c1.vwj44:widthPercent(100)
local vwj48 = HStack()
_l_c1.vwj48 = vwj48
local vwj49 = Label()
_l_c1.vwj49 = vwj49
_l_c1.vwj49:fontSize(18)
_l_c1.vwj49:textColor(Color(78, 200, 193, 1))
_l_c1.vwj49:marginBottom(5)
local vwj50 = Label()
_l_c1.vwj50 = vwj50
_l_c1.vwj50:text(":")
_l_c1.vwj50:fontSize(18)
_l_c1.vwj50:textColor(Color(78, 200, 193, 1))
local vwj51 = Label()
_l_c1.vwj51 = vwj51
_l_c1.vwj51:lines(1)
_l_c1.vwj51:fontSize(18)
_l_c1.vwj51:textColor(Color():hex(11447982))
_l_c1.vwj51:basis(1)
_l_c1.vwj48:children({_l_c1.vwj49, _l_c1.vwj50, _l_c1.vwj51})
_l_c1.vwj48:widthPercent(100)
local vwj52 = HStack()
_l_c1.vwj52 = vwj52
local vwj53 = Spacer()
_l_c1.vwj53 = vwj53
local vwj54 = Label()
_l_c1.vwj54 = vwj54
_l_c1.vwj54:text("更多回复")
_l_c1.vwj54:textColor(Color(78, 200, 193, 1))
_l_c1.vwj54:fontSize(17)
_l_c1.vwj52:children({_l_c1.vwj53, _l_c1.vwj54})
_l_c1.vwj52:widthPercent(100)
_l_c1.vwj52:marginTop(6)
_l_c1.vwj43:children({_l_c1.vwj44, _l_c1.vwj48, _l_c1.vwj52})
_l_c1.vwj43:bgColor(Color():hex(15724527))
_l_c1.vwj43:widthPercent(100)
_l_c1.vwj43:cornerRadius(4)
_l_c1.vwj43:padding(8, 8, 8, 8)
_l_c1.vwj32:children({_l_c1.vwj33, _l_c1.vwj38, _l_c1.vwj42, _l_c1.vwj43})
_l_c1.vwj32:marginLeft(4)
_l_c1.vwj32:basis(1)
_l_c1.vwj30:children({_l_c1.vwj31, _l_c1.vwj32})
_l_c1.vwj30:widthPercent(100)
_l_c1.vwj29:children({_l_c1.vwj30})
_l_c1.vwj29:widthPercent(100)
_l_c1.vwj29:paddingLeft(20)
_l_c1.vwj29:paddingRight(20)
_l_c1.vwj25:children({_l_c1.vwj26, _l_c1.vwj29})
_l_c1.vwj25:widthPercent(100)
_l_c1.vwj25:marginBottom(20)
_l_c1.contentView:addView(_l_c1.vwj25)
end)
DataBinding:bindListView(userData.listSource.__path,vwj5)
vwj5_adapter:sectionCount(function()
return DataBinding:getSectionCount(userData.listSource.__path)
end)
vwj5_adapter:rowCount(function(section1)
return  DataBinding:getRowCount(userData.listSource.__path,section1)
end)
vwj5_adapter:fillCellDataByReuseId("commentCell", function(_l_c1,section1,row1)
local _l_i1=userData.listSource[section1][row1].__ci
local kvar8=_l_i1
_l_c1.vwj26:display(kvar8.row.__get == 2)
_l_c1.vwj31:image(kvar8.icon.__get)
_l_c1.vwj34:text(kvar8.name.__get)
_l_c1.vwj37:text(kvar8.like.__get)
_l_c1.vwj39:text(kvar8.level.__get)
_l_c1.vwj41:text(kvar8.time.__get)
_l_c1.vwj42:text(kvar8.content.__get)
_l_c1.vwj45:text((#kvar8.reply.__get >= 1 and{kvar8.reply[1].name.__get} or{""})[1])
_l_c1.vwj47:text((#kvar8.reply.__get >= 1 and{kvar8.reply[1].content.__get} or{""})[1])
_l_c1.vwj44:display((#kvar8.reply.__get >= 1))
_l_c1.vwj49:text((#kvar8.reply.__get >= 2 and{kvar8.reply[2].name.__get} or{""})[1])
_l_c1.vwj51:text((#kvar8.reply.__get >= 2 and{kvar8.reply[2].content.__get} or{""})[1])
_l_c1.vwj48:display((#kvar8.reply.__get >= 2))
_l_c1.vwj52:display((#kvar8.reply.__get >= 3))
BindMetaWatchListCell(userData.listSource,section1,row1)
end)
vwj5_adapter:fillCellDataByReuseId("contentCell", function(_l_c1,section1,row1)
local _l_i1=userData.listSource[section1][row1].__ci
local kvar3=_l_i1
local kvar4=KUA_CELL_TYPE.DETAIL
local kvar5=kvar3
local kvar6=KUA_CELL_TYPE.DETAIL
_l_c1.vwj9:image(kvar5.icon.__get)
_l_c1.vwj11:text(kvar5.name.__get)
_l_c1.vwj12:text(kvar5.desc.__get)
_l_c1.vwj15:text(kvar5.content.__get)
local kvar9 = function()
local kvar2 = {}
for kvar1=1, (kvar5.actions.__asize) do 
local kvar7=kvar1
local kvar2_=(function()
return  (function(_argo_break)
local vwj58 = Label()
ui_views.vwj58 = vwj58
vwj58 = vwj58
vwj58:text(kvar5.actions[kvar7].__get)
vwj58:marginRight(8)
vwj58:textColor(Color(78, 200, 193, 1))
return vwj58
end)('@argo@')
end)()
if kvar2_ then table.insert(kvar2,kvar2_) end
end 
BindMetaPopForach()
return kvar2
end
local kvar12 = function()
local kvar11 = {}
local add = function(_v_)
if type(_v_) == "table" then
for _, _v in ipairs(_v_) do
table.insert(kvar11, _v)
end
elseif _v_ then
table.insert(kvar11, _v_)
end
end
add(kvar9())
_l_c1.vwj16:children(kvar11)
end
_l_c1.vwj16:removeAllSubviews()
kvar12()
_l_c1.vwj17:image(kvar5.pic.__get)
_l_c1.vwj20:text(kvar5.like.__get)
_l_c1.vwj22:text(kvar5.comment.__get)
BindMetaWatchListCell(userData.listSource,section1,row1)
end)
vwj5_adapter:reuseId(function(section1, row1)
local _l_i1=userData.listSource[section1][row1].__cii
if _l_i1.row.__get == 1 then 
return  "contentCell"
else 
return  "commentCell"
end 
end)
vwj5:reloadData()
vwj1:children({vwj2, vwj5})
vwj1:widthPercent(100)
vwj1:heightPercent(100)
window:addView(vwj1)
local vwj55 = HStack()
ui_views.vwj55 = vwj55
local vwj56 = Spacer()
ui_views.vwj56 = vwj56
local vwj57 = Label()
ui_views.vwj57 = vwj57
vwj57:text("发送")
vwj57:marginRight(20)
vwj57:textColor(Color(78, 200, 193, 1))
vwj55:children({vwj56, vwj57})
vwj55:positionType(PositionType.ABSOLUTE)
vwj55:positionBottom(10)
vwj55:widthPercent(100)
vwj55:height(35)
vwj55:paddingTop(10)
window:addView(vwj55)
