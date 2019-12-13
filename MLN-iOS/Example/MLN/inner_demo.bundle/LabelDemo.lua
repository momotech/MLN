local topHeight = 0
if System:iOS() then
    topHeight = window:statusBarHeight() + window:navBarHeight()
end
linear = ScrollView(false, true):width(MeasurementType.MATCH_PARENT):marginTop(topHeight)
-- 默认状态，Label输入文字样式
action1 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
action1:width(200)
linear:addView(action1)
action1:text("默认状态 fontSize:14 TextAlign.LEFT")

-- 文本居中样式
action2c = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
linear:addView(action2c)
action2c:width(200)
action2c:textAlign(TextAlign.CENTER)
action2c:text("TextAlign.CENTER")

-- 文本居右样式
action2r = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
linear:addView(action2r)
action2r:width(200)
action2r:textAlign(TextAlign.RIGHT)
action2r:text("TextAlign.RIGHT")

-- 字体22
action3 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
action3:fontSize(22)
linear:addView(action3)
action3:text("fontSize:22")

-- 设置文本为红色
action4 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
linear:addView(action4)
action4:textColor(Color(255, 0, 0, 1.0))
action4:text("textColor(Color(255,0,0,1.0)) 红色")

--error:两端差异，iOS fontStyle(FontStyle.BOLD_ITALIC) 无效 且 setFontSizeForRange 起始位置不对 且 设置fontStyle后会导致字体尺寸都改变
action6 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL):setMaxWidth(100)
linear:addView(action6)
styleT = StyleString("我变22我是富文本啦(两端差异)"):setFontSizeForRange(22, 1, 4)
action6:styleText(styleT)

-- 粗体
action7 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
linear:addView(action7)
action7:setTextFontStyle(FontStyle.BOLD_ITALIC)
action7:text("setTextFontStyle FontStyle.BOLD_ITALIC")

-- 限制宽度，单行
action8 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL):setMaxWidth(140)
linear:addView(action8)
action8:text("setMaxWidth(140) 看我超出了吗")

action9 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL):setMinWidth(200)
linear:addView(action9)
action9:text("setMinWidth(200) 看我宽度")

linear11 = LinearLayout():width(MeasurementType.WRAP_CONTENT):height(MeasurementType.WRAP_CONTENT):setGravity(Gravity.CENTER_HORIZONTAL)
action11 = Label():marginTop(5):marginBottom(5):bgColor(Color(121, 45, 122, 1.0)):setGravity(Gravity.CENTER_HORIZONTAL):setMaxWidth(150):setMinHeight(100)
linear11:addView(action11)
linear:addView(linear11)
action11:text("setMinHeight(100) 我高不")

switch11 = Switch():width(100):height(50)
switch11:setSwitchChangedCallback(function(isOn)
    if isOn then
        action11:lines(1)
    else
        action11:lines(2)
    end
end)

linear11:addView(switch11)
window:addView(linear)