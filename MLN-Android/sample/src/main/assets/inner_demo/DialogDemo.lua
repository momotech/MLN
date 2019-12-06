

dialog =  Dialog()

dialog:dialogDisAppear(function()
print("我隐藏啦，dialog！！！")
end)

dialog:cancelable(true)

--baseV = View(Rect(0,0,500,460))
--baseV:bgColor(Color(45,7,122,1.0))
--window:addView(baseV)

local screen_w = window:width()
local screen_h = window:height()

baseView = LinearLayout(LinearType.VERTICAL)
baseView:setPositionAdjustForKeyboard(true)
baseView:width(screen_w - 80):height(MeasurementType.WRAP_CONTENT)
baseView:setGravity(Gravity.CENTER)
baseView:bgColor(Color(255,255,255,1.0))
baseView:cornerRadius(7)
baseView:clipToBounds(true)

--window:addView(baseView)
dialog:setContent(baseView)

t11 = Label()
t11:text('X')
t11:width(40):height(40)
t11:textAlign(TextAlign.CENTER)
t11:setGravity(Gravity.RIGHT)
baseView:addView(t11)

linear1 = LinearLayout(LinearType.HORIZONTAL)
linear1:width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT)
container1 = LinearLayout(LinearType.VERTICAL)
container1:width((screen_w - 80)/3)
container1:setGravity(Gravity.CENTER_VERTICAL)
container2 = LinearLayout(LinearType.VERTICAL)
container2:width((screen_w - 80)/3):height((MeasurementType.WRAP_CONTENT))
container3 = LinearLayout(LinearType.VERTICAL)
container3:width((screen_w - 80)/3)
container3:setGravity(Gravity.CENTER_VERTICAL)

lin1 = View()
lin1:priority(500)
lin1:setGravity(Gravity.CENTER)
lin1:width(50):height(1)
lin1:bgColor(Color():setColor("#F3F3F3"))
container1:addView(lin1)

lin2 = View()
lin2:priority(500)
lin2:setGravity(Gravity.CENTER)
lin2:width(50):height(1)
lin2:bgColor(Color():setColor("#F3F3F3"))
container3:addView(lin2)

titleL = Label()
titleL:priority(1000)
titleL:text("留言认识一下")
titleL:fontSize(12)
titleL:setGravity(Gravity.CENTER_HORIZONTAL)
titleL:textColor(Color():setColor("#333333"))
container2:addView(titleL)

titleS = Label():marginTop(5)
titleS:text("回复即可开始聊天")
titleS:setGravity(Gravity.CENTER_HORIZONTAL)
titleS:textColor(Color():setColor("#ACACAC"))
titleS:fontSize(11)
container2:addView(titleS)

linear1:addView(container1)
linear1:addView(container2)
linear1:addView(container3)

baseView:addView(linear1)


backView = View():marginLeft(33):marginTop(20):width(screen_w - 80 - 66):height(37)
editView = EditTextView()
editView:singleLine(true)
editView:placeholder("愿我们之间有故事~")
editView:marginLeft(10):marginRight(10):width(screen_w - 80 - 86):height(37)
editView:bgColor(Color():clear())
editView:fontSize(14)
editView:returnMode(ReturnType.Done)
backView:cornerRadius(7)
backView:bgColor(Color():setColor("#F2F2F2"))
backView:addView(editView)

editView:setReturnCallback(function()
editView:dismissKeyboard()
print("return callBack")
end)

baseView:addView(backView)

lineB = View()
lineB:marginTop(20):width(MeasurementType.MATCH_PARENT):height(1)
lineB:bgColor(Color():setColor("#F3F3F3"))

baseView:addView(lineB)

sureB = Label()
sureB:text("确认")
sureB:openRipple(true)
sureB:textAlign(TextAlign.CENTER)
sureB:marginTop(0):width(MeasurementType.MATCH_PARENT):height(49)

baseView:addView(sureB)

sureB:onClick(function()
print("输入了",editView:text())
disMiss()
end)

window:onClick(function()
dialog:show()
end)

t11:onClick(function()
disMiss()
end)

function disMiss()
dialog:dismiss()
end


tips = Label():marginTop(120):width(MeasurementType.MATCH_PARENT)
tips:textAlign(TextAlign.CENTER)

tips:text("点击屏幕可见Dialog")

window:addView(tips)

