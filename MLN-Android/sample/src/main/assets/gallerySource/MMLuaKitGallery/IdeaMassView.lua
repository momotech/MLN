local _class = {
    _name = 'IdeaMassView',
    _version = '1.0'
}

---@public
function _class:new()
    local o = {}
    setmetatable(o, { __index = self })
    self.dataList = Array()
    self.pageIndex = 1
    self.type = 1
    return o
end
---优先加载其他辅助文件
---@private
function _class:loadExtensions()
    require("MMLuaKitGallery.Constant")
end

---@public
function _class:rootView()
    if self.containerView then
        return self.containerView
    end
    self:loadExtensions()
    self:createSubviews()
    self:setupDataSource()
    return self.containerView
end

---@private
function _class:createSubviews()
    self:setupContainerView()
    self:setupTitleView()
    self:setupHeaderView()
    --waterfallview
    self.waterfall = self:setupWaterfallView()
    self.containerView:addView(self.waterfall)
end
---容器视图
---@public
function _class:setupContainerView()
    self.containerView = LinearLayout(LinearType.VERTICAL)
    self.containerView:width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)

    if System:iOS() then
        self.containerView:marginTop(window:statusBarHeight())
    end
end

---导航栏视图
---@public
function _class:setupTitleView()
    --导航栏
    self.navigation = require("MMLuaKitGallery.NavigationBar"):new()
    self.navibar = self.navigation:bar("灵感集", nil)
    self.containerView:addView(self.navibar)

    --返回
    self.backBtn = ImageView():width(22):height(22):marginLeft(20):setGravity(MBit:bor(Gravity.LEFT, Gravity.CENTER_VERTICAL))
    self.backBtn:image("back")
    self.navibar:addView(self.backBtn)
    self.backBtn:onClick(function()
        Navigator:closeSelf(AnimType.LeftToRight)
    end)

    --分享
    self.shareBtn = ImageView():width(22):height(22):marginRight(20):setGravity(MBit:bor(Gravity.RIGHT, Gravity.CENTER_VERTICAL))
    self.shareBtn:image("share")
    self.navibar:addView(self.shareBtn)

end
---header设置
function _class:setupHeaderView()
    self:setupTopView()
    self.containerView:addView(self.HeaderView)
end
---header视图
function _class:setupTopView()
    self.HeaderView = LinearLayout(LinearType.VERTICAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT)

    self.topView = View():width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT):padding(20, 10, 10, 10)
                         :bgColor(ColorConstants.Gray)
    self.HeaderView:addView(self.topView)

    self.iv = ImageView():width(100):height(100):addCornerMask(6, ColorConstants.Gray, RectCorner.ALL_CORNERS)
    self.topView:addView(self.iv)

    self.attention = Label():text("+ 关注"):textColor(ColorConstants.White):fontSize(12):borderWidth(1):borderColor(ColorConstants.White):padding(6, 12, 6, 12)
                            :cornerRadius(2):setGravity(Gravity.RIGHT)
    self.topView:addView(self.attention)

    self.title = Label():marginLeft(120):text("一周穿搭不重样"):textColor(ColorConstants.White):fontSize(16):setTextFontStyle(FontStyle.BOLD)
    self.topView:addView(self.title)

    --篇数 浏览量
    self.countLinear = LinearLayout(LinearType.HORIZONTAL):marginLeft(120):marginTop(28)
    self.topView:addView(self.countLinear)

    self.pageLogo = ImageView():width(15):height(15)

    self.countLinear:addView(self.pageLogo)
    self.pageCount = Label():text("200篇"):textColor(ColorConstants.White):fontSize(12):marginLeft(3)
    self.countLinear:addView(self.pageCount)

    self.scanLogo = ImageView():width(15):height(15):marginLeft(8)
    self.countLinear:addView(self.scanLogo)
    self.scanCount = Label():text("6790"):textColor(ColorConstants.White):fontSize(12):marginLeft(3)
    self.countLinear:addView(self.scanCount)

    --话题创建者
    self.autoLinear = LinearLayout(LinearType.HORIZONTAL):marginLeft(120):setGravity(Gravity.BOTTOM):marginBottom(5)
    self.topView:addView(self.autoLinear)
    self.authorHeader = ImageView():width(25):height(25)

    self.autoLinear:addView(self.authorHeader)
    self.authorName = Label():text("小美酱Pick榜 创建"):textColor(ColorConstants.White):fontSize(12):setGravity(Gravity.CENTER_VERTICAL):marginLeft(5)
    self.autoLinear:addView(self.authorName)

    --相关灵感集栏
    self.aboutLinear = LinearLayout(LinearType.HORIZONTAL):width(MeasurementType.MATCH_PARENT):height(50):padding(10, 10, 10, 10)
                                                          :bgColor(ColorConstants.Gray)
    self.HeaderView:addView(self.aboutLinear)
    self.about = Label():text("相关灵感集："):textColor(ColorConstants.White):fontSize(12):setGravity(Gravity.CENTER_VERTICAL)
    self.aboutLinear:addView(self.about)
    --标签列表视图
    self:setupTapListView():setGravity(Gravity.CENTER_VERTICAL)
    self.aboutLinear:addView(self.tapTableView)
    self.bottomView = LinearLayout(LinearType.HORIZONTAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
    self.bottomView:addCornerMask(10, ColorConstants.Gray, MBit:bor(RectCorner.TOP_LEFT, RectCorner.TOP_RIGHT))
    self.HeaderView:addView(self.bottomView)
    --tabSegment
    self:setupTabSegment()
    --line
    self.line = View():width(MeasurementType.MATCH_PARENT):height(1):bgColor(ColorConstants.LightGray)
    self.HeaderView:addView(self.line)

end
---灵感集标签列表
function _class:setupTapListView()
    self.tapTableView = CollectionView(false, false):width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT):scrollDirection(ScrollDirection.HORIZONTAL)
    self.tapLayout = CollectionViewLayout():itemSpacing(10):spanCount(1)

    self.tapAdapter = CollectionViewAutoFitAdapter()

    --self.tapAdapter = CollectionViewAdapter()
    --self.tapAdapter:sizeForCell(function(section, row)
    --    return Size(70, 30)
    --end)


    self.tapAdapter:initCell(function(cell)
        cell.tapLabel = Label():text(""):textColor(ColorConstants.White):fontSize(12):padding(6, 15, 6, 15):bgColor(Color(70, 70, 70, 0.5))
                               :cornerRadius(12)
        cell.contentView:addView(cell.tapLabel)
    end)
    self.tapAdapter:fillCellData(function(cell, _, row)
        local item = self.dataList:get(row)
        cell.tapLabel:text(item:get("author"))
    end)
    self.tapAdapter:rowCount(function()
        return self.dataList:size()
    end)
    self.tapTableView:layout(self.tapLayout)

    return self.tapTableView
end

function _class:setupTabSegment()
    self.tabContainerHot = LinearLayout(LinearType.VERTICAL)
    self.tabContainerNew = LinearLayout(LinearType.VERTICAL)

    self.tabHotLabel = Label():fontSize(14):padding(12, 12, 12, 12):text("热门")
    self.tabNewLabel = Label():fontSize(14):padding(12, 12, 12, 12):text("最新")
    self.indicatorHot = View():height(2):width(6):setGravity(Gravity.CENTER_HORIZONTAL)
    self.indicatorNew = View():height(2):width(6):setGravity(Gravity.CENTER_HORIZONTAL)

    self.tabContainerHot:addView(self.tabHotLabel):addView(self.indicatorHot)
    self.tabContainerNew:addView(self.tabNewLabel):addView(self.indicatorNew)

    self.bottomView:addView(self.tabContainerHot):addView(self.tabContainerNew)

    self.tabsListener = function(index)
        if self.type ~= index then
            self.waterfall:resetLoading()
            self.dataList:removeAll()
            self.type = index
            self:requestNetwork(true, function(success, _)
                if success then
                    if self.dataList:size() > 0 then
                        self.waterfall:reloadData()
                    end
                end
            end)
        end
    end

    self.updataFunction = function(index)
        if index == 1 then
            self.indicatorHot:bgColor(ColorConstants.Black)
            self.tabHotLabel:textColor(ColorConstants.Black)
            self.indicatorNew:bgColor(ColorConstants.Gray)
            self.tabNewLabel:textColor(ColorConstants.Gray)
        else
            self.indicatorHot:bgColor(ColorConstants.Gray)
            self.tabHotLabel:textColor(ColorConstants.Gray)
            self.indicatorNew:bgColor(ColorConstants.Black)
            self.tabNewLabel:textColor(ColorConstants.Black)
        end
    end
    self.updataFunction(1)

    self.tabContainerHot:onClick(function()
        self.updataFunction(1)
        self.tabsListener(1)
    end)
    self.tabContainerNew:onClick(function()
        self.updataFunction(2)
        self.tabsListener(2)
    end)
end

function _class:setupWaterfallView()
    self.width = (window:width() - 30) / 2
    self.waterfall = WaterfallView(false, true):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
                                               :marginLeft(10):marginRight(10)
    self.waterfallLayout = WaterfallLayout():itemSpacing(12):lineSpacing(5):spanCount(2)
    self.waterfallAdapter = WaterfallAdapter()
    self.waterfallAdapter:initCell(function(cell)
        local REQCELL = require("MMLuaKitGallery.IdeaWaterfallCell"):new()
        REQCELL:cellView(self.width)
        cell.CELL = REQCELL
        cell.contentView:addView(REQCELL.cellLayout)
    end)
    self.waterfallAdapter:fillCellData(function(cell, _, row)
        local item = self.dataList:get(row)

        cell.CELL.image:image(item:get("pic_big"))
        cell.CELL.desc:text(item:get("title"))
        cell.CELL.authorhead:image(item:get("pic_small"))
        cell.CELL.authorName:text(item:get("artist_name"))
        cell.CELL.likeCount:text(tostring(item:get("file_duration")))
    end)
    self.waterfallAdapter:rowCount(function()
        return self.dataList:size()
    end)

    --bug 希望支持瀑布流自适应
    self.waterfallAdapter:heightForCell(function(section, row)
        return 210
    end)
    self.waterfall:layout(self.waterfallLayout)

    self.waterfall:setLoadingCallback(function()
            System:setTimeOut(function()
                self:requestNetwork(false, function(success, data)
                    if success then
                        self.waterfall:stopLoading()
                        self.waterfall:resetLoading()
                        self.waterfall:reloadData()
                    end
                end)
            end,0.1)
      end)

    return self.waterfall
end
---请求接口
---@private
function _class:requestNetwork(first, complete)
    --热门
    if self.type == 1 then
        if first then
            self.pageIndex = 1
        else
            self.pageIndex = 6
        end
    elseif self.type == 2 then
        --最新
        if first then
            self.pageIndex = 11
        else
            self.pageIndex = 9
        end
    end
    local filepath = 'gallery/json/musicRank.json'
    if System:Android() then
        filepath = 'assets://' .. filepath
    else
        filepath = 'file://' .. filepath
    end
    File:asyncReadFile(filepath, function(codeNumber, response)
        print("codeNumber: " .. tostring(codeNumber))
        map = StringUtil:jsonToMap(response)
        if codeNumber == 0 then
            local data = map:get("result")
            if first then
                self.dataList = data
            elseif data then
                self.dataList:addAll(data)
            end
            complete(true, data)
        else
            --error(err:get("errmsg"))
            complete(false, nil)
        end
    end)

end

function _class:setupDataSource()
    --首先展示第一页数据
    ----延迟加载，为了列表适配和加载时间分开


    self:requestNetwork(true, function(success, _)
        if success then
            if not self.isInit then
                self.isInit = true
                self.waterfall:adapter(self.waterfallAdapter)
                self.tapTableView:adapter(self.tapAdapter)
                self.authorHeader:image("https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_header.png")
                self.pageLogo:image("https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_star.png")
                self.scanLogo:image("https://s.momocdn.com/w/u/others/2019/10/18/1571393656549-mls_scan.png")

            end

            if self.dataList:size() > 0 then
                self.iv:image(self.dataList:get(1):get("pic_radio"))
                self.tapTableView:reloadData()
                self.waterfall:reloadData()
            end
        end
    end)

end

_class:new()
window:addView(_class:rootView())

return _class
