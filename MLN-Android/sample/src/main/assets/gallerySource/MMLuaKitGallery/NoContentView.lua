
local _class = {
    _name = "noContentView",
    _version = "1.0"
}

---@public
function _class:new()
    local o = {}
    setmetatable(o, {__index = self})
    return o
end


function _class:contentView()

    self.noContentView = View():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):setGravity(Gravity.CENTER)

    self.noContentLinear = LinearLayout(LinearType.VERTICAL):width(MeasurementType.WRAP_CONTENT):height(MeasurementType.WRAP_CONTENT)
                                                            :setGravity( Gravity.CENTER)

    self.noContentImage = ImageView():width(22):height(22)  --:marginLeft(20)
    self.noContentImage:image("http://cdnst.momocdn.com/w/u/others/2019/11/07/1573101273153-bv.png"):marginLeft(30)--:setGravity(Gravity.CENTER)
    self.noContentLinear:addView(self.noContentImage)


    self.attention = Label():text("没有内容")
                            :textColor(ColorConstants.Black):fontSize(15)
                            :borderWidth(1):borderColor(ColorConstants.White):padding(6, 12, 6, 12)
                            :cornerRadius(2)
    self.noContentLinear:addView(self.attention)

    self.noContentView:addView(self.noContentLinear)

    return self.noContentView
end



return _class