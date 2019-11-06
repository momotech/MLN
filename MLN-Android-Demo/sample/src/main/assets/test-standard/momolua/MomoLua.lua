---- Lua Object
---- Created by zhang.ke
---- on 2018/11/26

affinity("keye")
local _class = {}
_class._version = '1.0'
_class._classname = 'AdapterControler'

Tag = "luaData"
demoUtils = require("momolua.demoUtils.DemoUtils")

screen_w = window:width()
screen_h = window:height()

--basePath = "file://LuaView/172.16.103.121/-momo/"
demoSource = {"momolua.ui.Ui" ,"momolua.ui.List" , "momolua.data.Data","momolua.utils.Utils"}

rootList = View():width(screen_w):height(screen_h)
demoView = View():width(screen_w):height(screen_h)
window:addView(rootList)--显示demo列表

window:keyboardShowing(function(isShowing,keyboardHeight)
    Toast("Keyboard showing is: "..tostring(isShowing).." "..tostring(keyboardHeight),1)
end)

function showDemo(model)
    rootList:hidden(true)
    demoView:removeAllSubviews()
    demoView:removeFromSuper()
    demoView:addView(model.contentView)
    window:addView(demoView)
end
function showList()
    rootList:hidden(false)
    demoView:removeAllSubviews()
    demoView:removeFromSuper()
end

--声明reuseId
ReuseId_Normal = "DemoList" --normalCell_Template

-- tableView datasource
--返回按钮
commonBackBtn = Label():text("< Back"):setAutoFit(true):textAlign(TextAlign.CENTER):setMinWidth(80):marginLeft(5):padding(0, 5, 5, 5):height(50):fontSize(14):bgColor(Color(211, 211, 211, 1)):textColor(Color(0,0,0,1))
commonBackBtn:onClick(function()
    showList()
end)

local titleView=Label():text("MOMOLua Demo 列表"):width(screen_w):height(50):fontSize(29):textAlign(TextAlign.CENTER):bgColor(Color(233,233,233,0.7))
local tableView = TableView():y(50)
local adapter = TableViewAdapter()
tableView:adapter(adapter)

rootList:addView(titleView)
rootList:addView(tableView)

adapter:sectionCount(function()
    --TODO return section. (default:1)
    return 1
end)

adapter:rowCount(function(sectionidx)
    --TODO return datasource count
    return #demoSource
end)

adapter:reuseId(function(section, row)
    --TODO return use for every type of cell
    return ReuseId_Normal
end)

adapter:heightForCell(function(section, row)
    --TODO return height for every cell
    return 50
end)

-------------Cell show/hidden--------------
adapter:cellWillAppear(function(cell, section, row)

end)

adapter:cellDidDisappear(function(cell, section, row)

end)

-------------init Cell--------------
adapter:initCellByReuseId(ReuseId_Normal, function(cell)
    cell.nameLabel = Label():height(50):width(screen_w):textAlign(TextAlign.CENTER):fontSize(18):textColor(Color(0,0,0,1))
    cell.cellLine = View():y(49):height(1):width(screen_w):bgColor(Color(23,23,23,0.5))

    cell.contentView:addView(cell.nameLabel)
    cell.contentView:addView(cell.cellLine)
end)

-------------fill Cell--------------
adapter:fillCellDataByReuseId(ReuseId_Normal, function(cell, section, row)
    cell.nameLabel:text(demoSource[row])
end)

-------------onSelected--------------
adapter:selectedRowByReuseId(ReuseId_Normal, function(cell, section, row)
    --TODO Cell onSelected
    cell.demoModel = require(demoSource[row])
    cell.demoModel:setCommonBackBtn(commonBackBtn)
    showDemo(cell.demoModel)
end)


return _class