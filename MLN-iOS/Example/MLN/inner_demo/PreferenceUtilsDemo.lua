
---------------------------------由于网页无法外部require  只能手动拿过来  start



function createCommonTabLinearLayout(contentView)
    local btnScrollView = ScrollView(true)
    btnScrollView:height(50)
    btnScrollView:width(width)

    --btnScrollView:padding(4, 0, 4, 0)

    contentView:addView(btnScrollView)
    local tabsContainer = LinearLayout(LinearType.HORIZONTAL):height(50):setWrapContent(true)
    btnScrollView:addView(tabsContainer)

    return tabsContainer
end

function addTabFromData(btnInfo, tabsContainer)

    local tabs = {}
    for i, v in ipairs(btnInfo) do
        local start, last = string.find(v, "demo.")
        local name
        if last and last < #v then
            name = string.sub(v, last + 1, #v)
        else
            name = v
        end
        local tab = Label():textAlign(TextAlign.CENTER):setMinWidth(80):marginLeft(5):padding(0, 5, 5, 5):height(50):fontSize(14):text(name):bgColor(Color(211, 211, 211, 1)):textColor(Color(0, 0, 0, 1))
        tabsContainer:addView(tab)
        tabs[v] = tab
    end

    return tabs
end

function initShowLabel(showLabel, width, height)
    showLabel:width(width - 16):height(height - (16 + (40 + 5) * 3) - 8):lines(0):fontSize(20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):bgColor(Color(222, 222, 222, 1)):marginTop(16 + (40 + 5) * 3):marginLeft(8):textColor(Color(0, 0, 0, 1))
    return showLabel
end

-- demoUtils = utils

-- -------------------------------由于网页无法外部require  只能手动拿过来  end






local _class = {}
_class._version = '1.0'
_class._classname = ''
_class.http = nil
_class.postParams = nil
_class.isCache = nil

function _class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function _class:onCreate(contentView)

    local width = contentView:width()
    local height = contentView:height()

    local showLabel = Label()--显示结果
    ------------------------------PreferenceUtils 实践 Demo Start------------------------------
    function _class:save(key, value)
        PreferenceUtils:save(key, value)
        showLabel:text("Save\n\nkey: " .. key .. "\n\nvalue: " .. value)
    end

    function _class:get(key, default)
        local value = PreferenceUtils:get(key, default)
        showLabel:text("Get\n\nkey: " .. key .. "\n\nvalue: " .. value.. "\n\ndefault: " .. default)
    end
    ------------------------------PreferenceUtils 实践 Demo End------------------------------


    ----以下代码不用管，显示UI用的
    local btnInfo = { "save", "get" }

    --初始化view
    local Desc = Label():text("Info"):fontSize(19):height(40):textAlign(TextAlign.CENTER):textColor(Color(0, 0, 0, 1)):marginLeft(10):marginTop(50)
    contentView:addView(Desc)
    local editLabal = EditTextView():text("value 23333"):fontSize(19):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):marginLeft(10):marginTop(75)
    contentView:addView(editLabal)
    local msgEdit = EditTextView():text("default 23333"):fontSize(19):width(width - 20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):marginLeft(10):marginTop(105)
    contentView:addView(msgEdit)
    contentView:addView(initShowLabel(showLabel, width, height*0.6))

    local btnScrollView = ScrollView(true)
    btnScrollView:height(50)
    btnScrollView:width(width)
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
                _class:save("momo",editLabal:text())
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                _class:get("momo",msgEdit:text())
            end)
        end
    end
end

_class:onCreate(window)

return _class

