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
    --waterfallview
    self.waterfall = self:setupWaterfallView()
    self.containerView:addView(self.waterfall)
    self:setupHeaderView()
end
---容器视图
---@public
function _class:setupContainerView()
    self.containerView = LinearLayout(LinearType.VERTICAL)
    self.containerView:width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):bgColor(_Color.White)
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
    self.backBtn:image("https://s.momocdn.com/w/u/others/2019/09/01/1567316383505-minmore.png")
    self.navibar:addView(self.backBtn)

    --分享
    self.shareBtn = ImageView():width(22):height(22):marginRight(20):setGravity(MBit:bor(Gravity.RIGHT, Gravity.CENTER_VERTICAL))
    self.shareBtn:image("https://s.momocdn.com/w/u/others/2019/09/01/1567316383469-minshare.png")
    self.navibar:addView(self.shareBtn)

end
---header设置
function _class:setupHeaderView()
    self:setupTopView()
    self.waterfallAdapter:initHeader(function(header)
        header.contentView:addView(self.HeaderView)
    end)

    self.waterfallAdapter:fillHeaderData(function(header)
        --header.contentView:addView(self.HeaderView)
    end)
    self.waterfallAdapter:headerValid(function()
        return true
    end)
    self.waterfallAdapter:heightForHeader(function()
        return 250
    end)
end
---header视图
function _class:setupTopView()
    self.HeaderView = LinearLayout(LinearType.VERTICAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):bgColor(_Color.Gray)

    self.topView = View():width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT):padding(20, 10, 10, 10)
    self.HeaderView:addView(self.topView)

    self.iv = ImageView():width(100):height(100):cornerRadius(6)
    self.topView:addView(self.iv)

    self.attention = Label():text("+ 关注"):textColor(_Color.White):fontSize(12):borderWidth(1):borderColor(_Color.White):padding(6, 12, 6, 12):cornerRadius(2):setGravity(Gravity.RIGHT)
    self.topView:addView(self.attention)

    self.title = Label():marginLeft(120):text("一周穿搭不重样"):textColor(_Color.White):fontSize(16):setTextFontStyle(FontStyle.BOLD)
    self.topView:addView(self.title)

    --篇数 浏览量
    self.countLinear = LinearLayout(LinearType.HORIZONTAL):marginLeft(120):marginTop(28)
    self.topView:addView(self.countLinear)

    self.pageLogo = ImageView():width(15):height(15):cornerRadius(6):image("https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_star.png")
    self.countLinear:addView(self.pageLogo)
    self.pageCount = Label():text("200篇"):textColor(_Color.White):fontSize(12):marginLeft(3)
    self.countLinear:addView(self.pageCount)

    self.scanLogo = ImageView():width(15):height(15):marginLeft(8):image("https://s.momocdn.com/w/u/others/2019/10/18/1571393656549-mls_scan.png")
    self.countLinear:addView(self.scanLogo)
    self.scanCount = Label():text("6790"):textColor(_Color.White):fontSize(12):marginLeft(3)
    self.countLinear:addView(self.scanCount)

    --话题创建者
    self.autoLinear = LinearLayout(LinearType.HORIZONTAL):marginLeft(120):setGravity(Gravity.BOTTOM):marginBottom(5)
    self.topView:addView(self.autoLinear)
    self.authorHeader = ImageView():width(25):height(25):image("https://s.momocdn.com/w/u/others/2019/10/18/1571393657050-mls_header.png")
    self.autoLinear:addView(self.authorHeader)
    self.authorName = Label():text("小美酱Pick榜 创建"):textColor(_Color.White):fontSize(12):setGravity(Gravity.CENTER_VERTICAL):marginLeft(5)
    self.autoLinear:addView(self.authorName)

    --相关灵感集栏
    self.aboutLinear = LinearLayout(LinearType.HORIZONTAL):width(MeasurementType.MATCH_PARENT):height(50):padding(10, 10, 10, 10)
    self.HeaderView:addView(self.aboutLinear)
    self.about = Label():text("相关灵感集："):textColor(_Color.White):fontSize(12):setGravity(Gravity.CENTER_VERTICAL)
    self.aboutLinear:addView(self.about)
    --标签列表视图
    self:setupTapListView():setGravity(Gravity.CENTER_VERTICAL)
    self.aboutLinear:addView(self:setupTapListView())
    self.bottomView = LinearLayout(LinearType.VERTICAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
    self.bottomView:bgColor(_Color.White):setCornerRadiusWithDirection(10, MBit:bor(RectCorner.TOP_LEFT, RectCorner.TOP_RIGHT))
    self.HeaderView:addView(self.bottomView)
    --tabSegment
    self.tabSegment = self:setupTabSegment()
    --line
    self.line = View():width(MeasurementType.MATCH_PARENT):height(1):bgColor(_Color.LightGray)
    self.bottomView:addView(self.line)

end
---灵感集标签列表
function _class:setupTapListView()
    self.tapTableView = CollectionView(false, false):width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT):scrollDirection(ScrollDirection.HORIZONTAL)
    self.tapLayout = CollectionViewGridLayoutFix():itemSpacing(10):spanCount(1)

    self.tapAdapter = CollectionViewAutoFitAdapter()

    --self.tapAdapter = CollectionViewAdapter()
    --self.tapAdapter:sizeForCell(function(section, row)
    --    return Size(70, 30)
    --end)


    self.tapAdapter:initCell(function(cell)
        cell.tapLabel = Label():text(""):textColor(_Color.White):fontSize(12):padding(6, 15, 6, 15):bgColor(Color(70, 70, 70, 0.5)):cornerRadius(40)
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
    self.tapTableView:adapter(self.tapAdapter)
    return self.tapTableView
end

function _class:setupTabSegment()
    titles = Array():add("热门"):add("最新")
    self.tabSegment = TabSegmentView(Rect(0, 400, window:width(), 50), titles, _Color.Black)
    self.tabSegment:normalFontSize(14):tintColor(_Color.Gray):selectedColor(_Color.DeepGray):setAlignment(TabSegmentAlignment.LEFT):selectScale(1)
    self.tabSegment:setItemTabClickListener(function(index)
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
    end)
    self.bottomView:addView(self.tabSegment)
    return self.tabSegment
end

function _class:setupWaterfallView()
    self.waterfall = WaterfallView(false, true):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
    self.waterfallLayout = WaterfallLayoutFix():itemSpacing(12):lineSpacing(18):spanCount(2)
    self.waterfallAdapter = WaterfallAdapter()
    self.waterfallAdapter:initCell(function(cell)
        local REQCELL = require("MMLuaKitGallery.IdeaWaterfallCell"):new()
        REQCELL:cellView()
        cell.CELL = REQCELL
        cell.contentView:addView(REQCELL.cellLayout)
    end)
    self.waterfallAdapter:fillCellData(function(cell, _, row)
        if row % 2 == 0 then
            cell.contentView:padding(0, 12, 0, 0)
        else
            cell.contentView:padding(0, 0, 0, 12)
        end
        local item = self.dataList:get(row)

        cell.CELL.image:image(item:get("pic_big"))
        cell.CELL.desc:text(tostring(item:get("title") .. " " .. tostring(item:get("si_proxycompany"))))
        if item:get("album_title") ~= nil then
            cell.CELL.desc:text(tostring(cell.CELL.desc:text() .. "  " .. tostring(item:get("album_title"))))
        end
        cell.CELL.authorhead:image(item:get("pic_small"))
        cell.CELL.authorName:text(item:get("artist_name"))
        cell.CELL.likeCount:text(item:get("file_duration"))
    end)
    self.waterfallAdapter:rowCount(function()
        return self.dataList:size()
    end)

    --bug 希望支持瀑布流自适应
    self.waterfallAdapter:heightForCell(function(section, row)
        local str = self.dataList:get(row):get("si_proxycompany")
        if string.len(str) > 15 then
            return 280
        else
            return 250
        end
    end)
    self.waterfall:layout(self.waterfallLayout)
    self.waterfall:adapter(self.waterfallAdapter)
    self.waterfall:setLoadingCallback(function()
        self:requestNetwork(false, function(success, data)
            if success then
                self.waterfall:stopLoading()
                self.waterfall:reloadData()
                self.waterfall:noMoreData()
            end
        end)
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



    File:asyncReadMapFile('file://android_asset/MMLuaKitGallery/discoverry_detail.json', function(codeNumber, response)

        print("codeNumber: " .. tostring(codeNumber))
        if codeNumber == 0 then
            local data = response:get("result")
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


    --local HTTPHandler = require("MMLuaKitGallery.HTTPHandler")
    --HTTPHandler:GET("https://api.apiopen.top/musicRankingsDetails", { type = self.pageIndex }, function(success, response, err)
    --    if success then
    --        local data = response:get("result")
    --        if first then
    --            self.dataList = data
    --        elseif data then
    --            self.dataList:addAll(data)
    --        end
    --
    --        complete(success, data)
    --    else
    --        error(err:get("errmsg"))
    --        complete(false, nil)
    --    end
    --end)


end

function _class:setupDataSource()
    --首先展示第一页数据
    self:requestNetwork(true, function(success, _)
        if success then
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