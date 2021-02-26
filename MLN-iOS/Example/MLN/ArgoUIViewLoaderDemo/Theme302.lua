--1
require("packet/v1_0/BindMeta")
require("packet/v1_0/style")
if ui_views == nil then
    ui_views = setmetatable({}, { __mode = 'v' })
    BindMetaCreateFindGID(ui_views)
end
mExpanLabel_class = __module.defModule("mExpanLabel")
function mExpanLabel_class:init(lineNum, str, endStr, textColor, endColor)
    self = __module.weakSelf(self)
    local vwj1 = VStack()
    self.vwj1 = vwj1
    self._view = self.vwj1
    local descLabel = Label()
    self.descLabel = descLabel
    self.descLabel:text(str)
    self.descLabel:lines(lineNum)
    self.descLabel:textColor(textColor)
    local showAllLabel = Label()
    self.showAllLabel = showAllLabel
    self.showAllLabel:textColor(textColor)
    self.showAllLabel:styleText(StyleString("aaaa" .. endStr)
            :setFontColorForRange(endColor, 5, 2)
    )
    self.showAllLabel:padding(0, 0, 0, 3)
    self.showAllLabel:bgColor(Color():hex(16777215))
    self.showAllLabel:onClick(function()
        print("descLabel.lines()= ", self.descLabel:lines())
        if self.descLabel:lines() > 0 then
            self.descLabel:lines(0)
            self.showAllLabel:text("收起")
        else
            self.descLabel:lines(lineNum)
            self.showAllLabel:text("... " .. endStr)
        end
    end)
    self.vwj1:children({ self.descLabel, self.showAllLabel })
    return self
end
function mExpanLabel_class:updateData(lineNum, str, endStr, textColor, endColor)
    self = __module.weakSelf(self)
end
mCommLayout_class = __module.defModule("mCommLayout")
function mCommLayout_class:init()
    self = __module.weakSelf(self)
    local vwj4 = VStack()
    self.vwj4 = vwj4
    self._view = self.vwj4
    self.vwj4:widthPercent(100)
    local vwj5 = HStack()
    self.vwj5 = vwj5
    self.vwj5:widthPercent(100)
    local vwj6 = ImageView()
    self.vwj6 = vwj6
    self.vwj6:width(60)
    self.vwj6:height(60)
    self.vwj6:bgColor(Color():hex(10526941))
    self.vwj6:cornerRadius(50)
    local vwj7 = VStack(true)
    self.vwj7 = vwj7
    self.vwj7:heightPercent(100)
    self.vwj7:basis(0)
    self.vwj7:grow(1)
    self.vwj7:bgColor(Color():hex(14540192))
    self.vwj7:width(100)
    self.vwj7:marginLeft(12)
    self.vwj7:mainAxis(MainAxis.SPACE_EVENLY)
    local vwj8 = Label()
    self.vwj8 = vwj8
    self.vwj8:text("开普勒")
    local vwj9 = Label()
    self.vwj9 = vwj9
    self.vwj9:text("10分钟前")
    self.vwj7:children({ self.vwj8, self.vwj9 })
    self.vwj5:children({ self.vwj6, self.vwj7 })
    local vwj10 = mExpanLabel(4, "请各位同事仔细阅读此制度，对于有疑惑的地方，可以随时通过邮件或者moji向内审部同事咨询，帮助大家充分理解制度条文。谢谢！请各位同事仔细阅读此制度，对于有疑惑的地方，可以随时通过邮件或者moji向内审部同事咨询，帮助大家充分理解制度条文。谢谢！", "全文", Color():hex(0), Color():hex(10526941))
    self.vwj10 = vwj10
    self.vwj10:marginLeft(72)
    self.vwj10:marginTop(12)
    __module.addSubModule(self, self.vwj10)
    self.vwj4:children({ self.vwj5, self.vwj10._view })
    return self
end
function mCommLayout_class:updateData()
    self = __module.weakSelf(self)
    self.vwj10:update(self, 4, "请各位同事仔细阅读此制度，对于有疑惑的地方，可以随时通过邮件或者moji向内审部同事咨询，帮助大家充分理解制度条文。谢谢！请各位同事仔细阅读此制度，对于有疑惑的地方，可以随时通过邮件或者moji向内审部同事咨询，帮助大家充分理解制度条文。谢谢！", "全文", Color():hex(0), Color():hex(10526941))
end
mCommOper_class = __module.defModule("mCommOper")
function mCommOper_class:init(type, str)
    self = __module.weakSelf(self)
    local vwj11 = HStack()
    self.vwj11 = vwj11
    self._view = self.vwj11
    local operImg = ImageView()
    self.operImg = operImg
    self.operImg:width(30)
    self.operImg:height(30)
    self.operImg:bgColor(Color():hex(14540253))
    local vwj13 = Label()
    self.vwj13 = vwj13
    self.vwj13:text(str)
    self.vwj13:marginLeft(8)
    self.vwj13:heightPercent(100)
    self.vwj11:children({ self.operImg, self.vwj13 })
    return self
end
function mCommOper_class:updateData(type, str)
    self = __module.weakSelf(self)
    if self._autoWatch then
        local watch_f_1 = function()
            if type == 1 then
                self.operImg:bgColor(Color():hex(10526941))
            elseif type == 2 then
                self.operImg:bgColor(Color():hex(14540192))
            elseif type == 3 then
                self.operImg:bgColor(Color():hex(14524576))
            end
        end
        watch_f_1()
    else
        do
        end ;
        (function()
            if type == 1 then
                self.operImg:bgColor(Color():hex(10526941))
            elseif type == 2 then
                self.operImg:bgColor(Color():hex(14540192))
            elseif type == 3 then
                self.operImg:bgColor(Color():hex(14524576))
            end
        end)()
    end
end
mOperLayout_class = __module.defModule("mOperLayout")
function mOperLayout_class:init()
    self = __module.weakSelf(self)
    local vwj14 = HStack(true)
    self.vwj14 = vwj14
    self._view = self.vwj14
    self.vwj14:widthPercent(100)
    self.vwj14:bgColor(Color():hex(14540253))
    local vwj15 = mCommOper(1, "20")
    self.vwj15 = vwj15
    __module.addSubModule(self, self.vwj15)
    local vwj16 = mCommOper(2, "259")
    self.vwj16 = vwj16
    self.vwj16:marginLeft(30)
    __module.addSubModule(self, self.vwj16)
    local vwj17 = Spacer()
    self.vwj17 = vwj17
    local vwj18 = mCommOper(3, "66")
    self.vwj18 = vwj18
    __module.addSubModule(self, self.vwj18)
    self.vwj14:children({ self.vwj15._view, self.vwj16._view, self.vwj17, self.vwj18._view })
    return self
end
function mOperLayout_class:updateData()
    self = __module.weakSelf(self)
    self.vwj15:update(self, 1, "20")
    self.vwj16:update(self, 2, "259")
    self.vwj18:update(self, 3, "66")
end
ui_class = __module.defModule("ui")
function ui_class:init(uiSuper)
    self._view = uiSuper
    self = __module.weakSelf(self)
    local vwj19 = mCommLayout()
    self.vwj19 = vwj19
    __module.addSubModule(self, self.vwj19)
    self._view:addView(self.vwj19._view)
    local vwj20 = mOperLayout()
    self.vwj20 = vwj20
    self.vwj20:paddingLeft(72)
    self.vwj20:marginTop(12)
    __module.addSubModule(self, self.vwj20)
    self._view:addView(self.vwj20._view)
    return self
end
function ui_class:updateData(uiSuper)
    self = __module.weakSelf(self)
    self.vwj19:update(self)
    self.vwj20:update(self)
end
kvar1 = ui(window)
kvar1:update(nil, window)

