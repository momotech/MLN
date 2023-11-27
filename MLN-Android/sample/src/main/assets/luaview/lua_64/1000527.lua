---
--- DateTime: 2022-01-17 14:24:04
--- @author jidongdong
--- 附近群组运营位
---
kScreenWidth = System:screenSize():width()
WHITE = Color(255, 255, 255)
GRAY_170 = Color(170, 170, 170)    --#aaaaaa
GRAY_155 = Color(146, 146, 146)
DARK_50 = Color(50, 51, 51)
COLOR_BLUE = Color(78, 127, 255)


--群组头部
FeedNearbyGroupHeader = {}

function FeedNearbyGroupHeader:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o:createSubViews()
    return o
end

function FeedNearbyGroupHeader:createSubViews()
    self.contentView = LinearLayout()
            :width(MeasurementType.MATCH_PARENT)
            :height(MeasurementType.WRAP_CONTENT)
    self.sourceTitle = Label()
            :textColor(DARK_50)
    self.moreTitle = Label()
            :width(MeasurementType.MATCH_PARENT)
            :height(MeasurementType.WRAP_CONTENT)
            :textAlign(TextAlign.RIGHT)
            :textColor(GRAY_170)
    self.contentView:addView(self.sourceTitle)
    self.contentView:addView(self.moreTitle)
end

function FeedNearbyGroupHeader:bind(data)
    self.contentView:onClick(function()
        Navigator:gotoPage(data:get("goto"), nil, 0)
    end)
    self.sourceTitle:text(data:get("title"))

    --更多
    local moreTitleStr = data:get("more_title")

    if moreTitleStr == nil or data:get("type") == "1" then
        self.moreTitle:hidden(true)
    else
        self.moreTitle:hidden(false)
        self.moreTitle:text(moreTitleStr)
    end

end

--群组cell
FeedNearbyGroupCell = {}

function FeedNearbyGroupCell:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o:createSubViews()
    return o
end

function FeedNearbyGroupCell:createSubViews()
    self.contentView = View()
    self.contentView:width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT):marginTop(15)
    self.imageView = ImageView()
            :cornerRadius(50)
            :width(55)
            :height(55)
    self.contentView:addView(self.imageView)

    self.textLinearLayout = LinearLayout(LinearType.VERTICAL)
            :marginLeft(65)
            :marginRight(15)
            :width(kScreenWidth - 73 - 92 - 15)
            :setGravity(Gravity.CENTER_VERTICAL)
    self.contentView:addView(self.textLinearLayout)

    local fontSize = (kScreenWidth <= 340) and 14 or ((kScreenWidth <= 360) and 15 or 16)
    self.titleLabel = Label()
            :fontSize(fontSize)
            :textColor(DARK_50)
    self.textLinearLayout:addView(self.titleLabel)

    self.descLabel = Label()
    self.descLabel:fontSize(13):textColor(GRAY_155)
    self.descLabel:marginTop(4)
    self.textLinearLayout:addView(self.descLabel)

    self.button = Label()
            :width(70)
            :height(30)
            :setGravity(MBit:bor(Gravity.CENTER_VERTICAL, Gravity.RIGHT))
            :text("加入")
            :textAlign(TextAlign.CENTER)
            :bgColor(COLOR_BLUE)
            :textColor(WHITE)
            :fontSize(14)
            :cornerRadius(15)

    self.contentView:addView(self.button)
end

function FeedNearbyGroupCell:bind(data)
    if data == nil then
        self.contentView:gone(true)
    else
        self.contentView:gone(false)
        self.imageView:image(data:get("imgurl"))
        self.titleLabel:text(data:get("name"))
        self.descLabel:text(data:get("desc"))

        self.contentView:onClick(function()
            Navigator:gotoPage(data:get("goto"), nil, 0)
        end)
        if data:get("buttongoto") == nil or data:get("buttongoto") == '' then
            self.button:hidden(true)
        else
            self.button:hidden(false)
            self.button:onClick(function()
                Navigator:gotoPage(data:get("buttongoto"), nil, 0)
            end)
        end
    end
end


-- create
local rootView = LinearLayout(LinearType.VERTICAL)
        :width(MeasurementType.MATCH_PARENT)
        :padding(15, 15, 15, 15)
local header = FeedNearbyGroupHeader:new()
local cells = {}
cells[1] = FeedNearbyGroupCell:new()
cells[2] = FeedNearbyGroupCell:new()

rootView:addView(header.contentView)
for i, v in ipairs(cells) do
    rootView:addView(cells[i].contentView)
end

window:viewAppear(function(type)
    print("viewAppear"..type)
end)

window:viewDisappear(function(type)
    print("viewDisappear"..type)
end)

window:addView(rootView)
--bind
function updateView(map)
    header:bind(map)
    local list = map:get("list")
    local diff = list:size() - #cells
    if diff > 0 then
        for i = 1, diff do
            local next = #cells + 1
            cells[next] = FeedNearbyGroupCell:new()
            rootView:addView(cells[next].contentView)
        end
    end
    for i = 1, #cells do
        local data = i <= list:size() and list:get(i) or nil
        cells[i]:bind(data)
    end
end


