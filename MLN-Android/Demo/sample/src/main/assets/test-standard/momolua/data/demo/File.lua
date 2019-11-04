----
---- Http
----- 实现案例
---- Created by zhang.ke
---- on 2018/11/21


local _class = {}
_class._version = '1.0'
_class._classname = 'File'

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function _class:onCreate(contentView)
    local width = contentView:width()
    local height = contentView:height()

    local count = 0--监听数量
    local showLabel = Label()--显示结果
    --CachePolicy {
    --    API_ONLY = 0,               -- 不使用缓存,只从网络更新数据
    --    CACHE_THEN_API,             -- 先使用缓存，随后请求网络更新请求
    --    CACHE_OR_API,               -- 优先使用缓存，无法找到缓存时才连网更新
    --    CACHE_ONLY,                 -- 只读缓存
    --    REFRESH_CACHE_BY_API        -- 刷新网络后数据加入缓存
    --}

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
        showLabel:text("Method: syncReadFile\n\n" .."string: " .. tostring(string) .. "\n\nPath: " .. filePath)
    end

    function _class:syncWriteFile(filePath, str)
        local codeNumber = File:syncWriteFile(filePath, str)
        showLabel:text("Method: syncWriteFile\n\n" .."codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\nstr: " .. str)
    end

    function _class:syncWriteMap(filePath, map)
        local codeNumber = File:syncWriteMap(filePath, map)
        showLabel:text("Method: syncWriteMap\n\n" .."codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\nmap: " .. tostring(map))
    end

    function _class:syncWriteArray(filePath, array)
        local codeNumber = File:syncWriteArray(filePath, array)
        showLabel:text("Method: syncWriteArray\n\n" .."codeNumber: " .. tostring(codeNumber) .. "\n\nPath: " .. filePath .. "\n\narray: " .. tostring(array))
    end

    function _class:syncUnzipFile(sourcePath, targetPath)
        local codeNumber = File:syncUnzipFile(sourcePath, targetPath)
        showLabel:text("Method: syncUnzipFile\n\n" .."codeNumber: " .. tostring(codeNumber) .. "\n\nsourcePath: " .. sourcePath .. "\n\ntargetPath: " .. tostring(targetPath))
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
    local Desc = Label():text("请用陌陌客户端扫码测试"):fontSize(19):setAutoFit(true):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):x(10):y(50)
    contentView:addView(Desc)
    local editLabal = EditTextView():text("file://LuaView"):fontSize(19):setAutoFit(true):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):x(10):y(75)
    contentView:addView(editLabal)
    local msgEdit = EditTextView():text("momo.lua"):fontSize(19):setAutoFit(true):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):x(10):y(105)
    contentView:addView(msgEdit)
    contentView:addView(demoUtils:initShowLabel(showLabel, width, height))

    local tabsContainer = demoUtils:createCommonTabLinearLayout(contentView,nil)
    local tabs = demoUtils:addTabFromData(btnInfo, tabsContainer)

    for i, v in pairs(tabs) do
        if i == btnInfo[1] then
            v:onClick(function()
                self:exist(editLabal:text())
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                self:isDir(editLabal:text())
            end)
        elseif i == btnInfo[3] then
            v:onClick(function()
                self:isFile(editLabal:text())
            end)
        elseif i == btnInfo[4] then
            v:onClick(function()
                self:asyncReadFile(editLabal:text())
            end)
        elseif i == btnInfo[5] then
            v:onClick(function()
                self:asyncReadMapFile(editLabal:text())
            end)
        elseif i == btnInfo[6] then
            v:onClick(function()
                self:asyncReadArrayFile(editLabal:text())
            end)
        elseif i == btnInfo[7] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.lua")
                self:asyncWriteFile(editLabal:text(), msgEdit:text())
            end)
        elseif i == btnInfo[8] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.lua")
                local map = Map()
                map:put("line2", msgEdit:text())
                self:asyncWriteMap(editLabal:text(), map)
            end)
        elseif i == btnInfo[9] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.zip")
                local array = Array()
                array:add( msgEdit:text())
                self:asyncWriteArray(editLabal:text(), array)
            end)
        elseif i == btnInfo[10] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.zip")
                msgEdit:text("file://LuaView")
                self:asyncUnzipFile(editLabal:text(), msgEdit:text())
            end)
        elseif i == btnInfo[11] then
            v:onClick(function()
                msgEdit:text("")
                self:syncReadString(editLabal:text())
            end)
        elseif i == btnInfo[12] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.lua")
                self:syncWriteFile(editLabal:text(), msgEdit:text())
            end)
        elseif i == btnInfo[13] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.lua")
                local map = Map()
                map:put("line2", msgEdit:text())
                self:syncWriteMap(editLabal:text(), map)
            end)
        elseif i == btnInfo[14] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.zip")
                local array = Array()
                array:add( msgEdit:text())
                self:syncWriteArray(editLabal:text(), array)
            end)
        elseif i == btnInfo[15] then
            v:onClick(function()
                editLabal:text("file://LuaView/momo.zip")
                msgEdit:text("file://LuaView")
                self:syncUnzipFile(editLabal:text(), msgEdit:text())
            end)
        end
    end

end

--function _class:updateCellWithItem(cell, item)
--
--end

return _class