
local _class = {}
_class._version = '1.0'
_class._classname = 'File'

local contentView = window

local width = contentView:width()
local height = contentView:height()

local showLabel = Label()--显示结果

------------------------------Http 实践 Demo Start------------------------------

----
function _class:exist(filePath)
    local exist = File:exist(filePath)
    local text = "exist: " .. tostring(exist) .. "\n\nPath: " .. filePath
    showLabel:text(text)
    return text
end

function _class:isDir(filePath)
    local exist = File:isDir(filePath)
    showLabel:text("isDir: " .. tostring(exist) .. "\n\nPath: " .. filePath)
end

function _class:isFile(filePath)
    local exist = File:isFile(filePath)
    showLabel:text("isFile: " .. tostring(exist) .. "\n\nPath: " .. filePath)
end

function _class:asyncReadFile(filePath)
    File:asyncReadFile(filePath, function(codeNumber, file)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\nfileData: " .. tostring(file) .. "\n\nPath: " .. filePath)

    end)
end

function _class:asyncReadMapFile(filePath)
    File:asyncReadMapFile(filePath, function(codeNumber, fileMap)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\nfileMap: " .. tostring(fileMap) .. "\n\nPath: " .. filePath)

    end)
end

function _class:asyncReadArrayFile(filePath)
    File:asyncReadArrayFile(filePath, function(codeNumber, fileArray)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\nfileArray: " .. tostring(fileArray) .. "\n\nPath: " .. filePath)

    end)
end

function _class:asyncWriteFile(filePath, str)
    File:asyncWriteFile(filePath, str, function(codeNumber, path)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\ncallBackPath: " .. tostring(path) .. "\n\nPath: " .. filePath .. "\n\nstr: " .. str)
    end)
end

function _class:asyncWriteMap(filePath, map)
    File:asyncWriteMap(filePath, map, function(codeNumber, path)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\ncallBackPath: " .. tostring(path) .. "\n\nPath: " .. filePath .. "\n\nmap: " .. tostring(map))
    end)
end

function _class:asyncWriteArray(filePath, array)
    File:asyncWriteArray(filePath, array, function(codeNumber, path)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\ncallBackPath: " .. tostring(path) .. "\n\nPath: " .. filePath .. "\n\narray: " .. tostring(array))
    end)
end

function _class:asyncUnzipFile(sourcePath, targetPath)
    File:asyncUnzipFile(sourcePath, targetPath, function(codeNumber, sourcePath)
        showLabel:text("codeNumber: " .. tostring(codeNumber) .. "\n\ncallBackSourcePath: " .. tostring(sourcePath) .. "\n\nsourcePath: " .. sourcePath .. "\n\ntargetPath: " .. tostring(targetPath))
    end)
end

function _class:syncReadString(filePath)
    local string = File:syncReadString(filePath)
    showLabel:text("Method: syncReadFile\n\n" .. "string: " .. tostring(string) .. "\n\nPath: " .. filePath)
end

function _class:syncWriteFile(filePath, str)
    local codeNumber = File:syncWriteFile(filePath, str)
    showLabel:text("Method: syncWriteFile\n\n" .. "codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\nstr: " .. str)
end

function _class:syncWriteMap(filePath, map)
    local codeNumber = File:syncWriteMap(filePath, map)
    showLabel:text("Method: syncWriteMap\n\n" .. "codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\nmap: " .. tostring(map))
end

function _class:syncWriteArray(filePath, array)
    local codeNumber = File:syncWriteArray(filePath, array)
    showLabel:text("Method: syncWriteArray\n\n" .. "codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\narray: " .. tostring(array))
end

function _class:syncUnzipFile(sourcePath, targetPath)
    local codeNumber = File:syncUnzipFile(sourcePath, targetPath)
    showLabel:text("Method: syncUnzipFile\n\n" .. "codeNumber: " .. tostring(codeNumber) .. "\n\nsourcePath: " .. sourcePath .. "\n\ntargetPath: " .. tostring(targetPath))
end

----
------------------------------Http 实践 Demo End------------------------------


----以下代码不用管，显示UI用的


--初始化view
----以下代码不用管，显示UI用的
--local btnInfo = { }
local btnInfo = { "exist", "isDir", "isFile", "asyncReadFile", "asyncReadMapFile", "asyncReadArrayFile",
                  "asyncWriteFile", "asyncWriteMap", "asyncWriteArray", "asyncUnzipFile",
                  "syncReadString", "syncWriteFile", "syncWriteMap", "syncWriteArray", "syncUnzipFile" }

--初始化view
local editLabal = EditTextView():text("file://LuaView"):fontSize(19):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):marginLeft(10):marginTop(75)
contentView:addView(editLabal)
local msgEdit = EditTextView():text("momo.lua"):fontSize(19):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):marginLeft(10):marginTop(105)
contentView:addView(msgEdit)
showLabel:width(width - 16):height(height - (16 + (40 + 5) * 3) - 8):lines(0):fontSize(20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):bgColor(Color(222, 222, 222, 1)):marginTop(16 + (40 + 5) * 3):marginLeft(8):textColor(Color(0, 0, 0, 1))
contentView:addView(showLabel)

local btnScrollView = ScrollView(true):height(50):width(width):padding(4, 0, 4, 0):scrollEnabled(true)
contentView:addView(btnScrollView)
local tabsContainer = LinearLayout(LinearType.HORIZONTAL):height(50):setWrapContent(true)
btnScrollView:addView(tabsContainer)

local tabs = {}
for i, v in ipairs(btnInfo) do
    local start, last = string.find(v, "demo.")
    local name
    if last and last < #v then
        name = string.sub(v, last + 1, #v)
    else
        name = v
    end
    local tab = Label():setWrapContent(true):textAlign(TextAlign.CENTER):setMinWidth(80):marginLeft(5):padding(0, 5, 5, 5):height(50):fontSize(14):text(name):bgColor(Color(211, 211, 211, 1)):textColor(Color(0, 0, 0, 1))
    tabsContainer:addView(tab)
    tabs[v] = tab
end

for i, v in pairs(tabs) do
    if i == btnInfo[1] then
        v:onClick(function()
            _class:exist(editLabal:text())
        end)
    elseif i == btnInfo[2] then
        v:onClick(function()
            _class:isDir(editLabal:text())
        end)
    elseif i == btnInfo[3] then
        v:onClick(function()
            _class:isFile(editLabal:text())
        end)
    elseif i == btnInfo[4] then
        v:onClick(function()
            _class:asyncReadFile(editLabal:text())
        end)
    elseif i == btnInfo[5] then
        v:onClick(function()
            _class:asyncReadMapFile(editLabal:text())
        end)
    elseif i == btnInfo[6] then
        v:onClick(function()
            _class:asyncReadArrayFile(editLabal:text())
        end)
    elseif i == btnInfo[7] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.lua")
            _class:asyncWriteFile(editLabal:text(), msgEdit:text())
        end)
    elseif i == btnInfo[8] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.lua")
            local map = Map()
            map:put("line2", msgEdit:text())
            _class:asyncWriteMap(editLabal:text(), map)
        end)
    elseif i == btnInfo[9] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.zip")
            local array = Array()
            array:add(msgEdit:text())
            _class:asyncWriteArray(editLabal:text(), array)
        end)
    elseif i == btnInfo[10] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.zip")
            msgEdit:text("file://LuaView")
            _class:asyncUnzipFile(editLabal:text(), msgEdit:text())
        end)
    elseif i == btnInfo[11] then
        v:onClick(function()
            msgEdit:text("")
            _class:syncReadString(editLabal:text())
        end)
    elseif i == btnInfo[12] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.lua")
            _class:syncWriteFile(editLabal:text(), msgEdit:text())
        end)
    elseif i == btnInfo[13] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.lua")
            local map = Map()
            map:put("line2", msgEdit:text())
            _class:syncWriteMap(editLabal:text(), map)
        end)
    elseif i == btnInfo[14] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.zip")
            local array = Array()
            array:add(msgEdit:text())
            _class:syncWriteArray(editLabal:text(), array)
        end)
    elseif i == btnInfo[15] then
        v:onClick(function()
            editLabal:text("file://LuaView/momo.zip")
            msgEdit:text("file://LuaView")
            _class:syncUnzipFile(editLabal:text(), msgEdit:text())
        end)
    end
end

return _class
