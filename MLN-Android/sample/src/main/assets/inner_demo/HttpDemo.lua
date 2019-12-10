
local _class = {}
_class._version = '1.0'
_class._classname = ''

_class.http = Http()
_class.isCache = false
_class.isRequesting = false

------------------------------Http 实践 Demo Start------------------------------
-- http请求数据
function _class:requestHttp(url)

    if _class.isRequesting then
        return
    end
    _class.isRequesting = true

    local postParams = {}
    postParams["cachePolicy"] = CachePolicy.CACHE_THEN_API
    postParams["encType"] = EncType.NORMAL
    
    _class.http:post(url, postParams, function(success, resp, error)
        if success and resp then
            if resp:get("__isCache") then
                _class.isCache = true
            end

            showLabel:text("cachePolicy：" .. tostring(postParams["cachePolicy"]) .. "\n\nencType：" .. tostring(postParams["encType"]) .. "\n\nUrl: " .. tostring(url) .. "\n\nsuccess: " .. tostring(success) .. "\n\nhasCache: " .. tostring(_class.isCache) .. "\n\nreps: \n" .. tostring(resp))
        else
            showLabel:text("cachePolicy：" .. tostring(postParams["cachePolicy"]) .. "\n\nencType：" .. tostring(postParams["encType"]) .. "\n\nUrl: " .. tostring(url) .. "\n\nsuccess: " .. tostring(success) .. "\n\nerror: \n" .. tostring(error))
        end
        _class.isRequesting = false
    end)
end

------------------------------Http 实践 Demo End-----------------------------
---- 显示UI用的
function _class:setupTestUI()
    btnInfo = { "正确请求", "错误请求" }
    
    contentView = window
    width = contentView:width()
    height = contentView:height()
    
    showLabel = Label()--显示结果

    contentScrollView = ScrollView():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
    window:addView(contentScrollView)

    --初始化view
    showLabel:width(width - 16):lines(0):fontSize(20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):bgColor(Color(222, 222, 222, 1)):marginTop(16 + (40 + 5) * 3):marginLeft(8):textColor(Color(0, 0, 0, 1))
    contentScrollView:addView(showLabel)
    
    btnScrollView = ScrollView(true):height(50):width(width):padding(4, 0, 4, 0)
    contentScrollView:addView(btnScrollView)
    local tabsContainer = LinearLayout(LinearType.HORIZONTAL):height(50):setWrapContent(true)
    btnScrollView:addView(tabsContainer)
    
    tabs = {}
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
                showLabel:text("请求中...." .. tostring(_class.postParams))
                _class:requestHttp("https://suggest.taobao.com/sug?code=utf-8&q=%E5%A4%A7%E5%AE%9D&callback=cb")
            end)
        elseif i == btnInfo[2] then
            v:onClick(function()
                showLabel:text("请求中...." .. tostring(_class.postParams))
                _class:requestHttp("www.abc")
            end)
        end
    end
end

_class:setupTestUI()

return _class
