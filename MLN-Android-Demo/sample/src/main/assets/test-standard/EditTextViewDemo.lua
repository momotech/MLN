


toolLinear = LinearLayout():marginTop(84):width(MeasurementType.MATCH_PARENT):height(36)
window:addView(toolLinear)

dismiss = Label():height(MeasurementType.MATCH_PARENT):bgColor(Color(121,44,111,1.0)):marginLeft(5):marginRight(5)
dismiss:text("dismiss 第一个")
toolLinear:addView(dismiss)
dismiss:onClick(function()
    edit1:dismissKeyboard()
end)

show = Label():height(MeasurementType.MATCH_PARENT):bgColor(Color(121,44,111,1.0)):marginLeft(5):marginRight(5)
toolLinear:addView(show)
show:text("showKeyboard 第一个")
show:onClick(function()
    edit1:showKeyboard()
end)

cursor = Label():height(MeasurementType.MATCH_PARENT):bgColor(Color(121,44,111,1.0)):marginLeft(5):marginRight(5)
toolLinear:addView(cursor)
cursor:text("光标黄色")
cursor:onClick(function()
    edit1:setCursorColor(Color(255,255,0,1))
end)


scrollView = ScrollView():marginTop(120):width(MeasurementType.MATCH_PARENT):height(window:height() - 84)

linear = LinearLayout(LinearType.VERTICAL):marginTop(0):width(MeasurementType.MATCH_PARENT)

window:addView(scrollView)
scrollView:addView(linear)



edit1 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("我是提示文本啦")
linear:addView(edit1)

edit2 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("EditTextViewInputMode.Number")
linear:addView(edit2)
edit2:inputMode(EditTextViewInputMode.Number)


edit3 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("passwordMode")
linear:addView(edit3)
edit3:passwordMode(true)


linearH = LinearLayout(LinearType.HORIZONTAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT)
linear:addView(linearH)

edit4 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("singleLine:fales")
edit4:breakMode(BreakMode.TAIL)
linear:addView(edit4)
linearH:addView(edit4)

switch1 = Switch():width(50):height(30)
switch1:on(false)
switch1:setSwitchChangedCallback(function(isOn)
    edit4:singleLine(isOn)
    edit4:placeholder("singleLine:" .. tostring(isOn))
    Toast("singleLine:" .. tostring(isOn),2)
end)
linearH:addView(switch1)


edit5 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("状态测试")
linear:addView(edit5)

edit5:setBeginChangingCallback(function()
    Toast("状态测试:开始修改-"..edit5:text(),1)
end)

edit5:setDidChangingCallback(function()
    Toast("状态测试:已经修改-"..edit5:text(),1)
end)

edit5:setEndChangedCallback(function()
    Toast("状态测试:结束修改-"..edit5:text(),1)
end)

edit5:setReturnCallback(function()
    Toast("点击了return按钮-"..edit5:text(),1)
end)


linearH2 = LinearLayout(LinearType.HORIZONTAL):width(MeasurementType.MATCH_PARENT):height(MeasurementType.WRAP_CONTENT)
linear:addView(linearH2)

edit6 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300)
linear:addView(edit6)
linearH2:addView(edit6)

switch2 = Switch():width(50):height(30)
edit6:setCanEdit(switch2:on())
edit6:placeholder("setCanEdit:".. tostring(switch2:on()))
switch2:setSwitchChangedCallback(function(isOn)
    edit6:setCanEdit(isOn)
    edit6:placeholder("setCanEdit:" .. tostring(isOn))
    Toast("setCanEdit:" .. tostring(isOn),2)
end)
linearH2:addView(switch2)


edit7 = EditTextView():marginTop(5):marginBottom(5):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,121,1.0)):width(300):placeholder("padding(20,20,20,20)")
linear:addView(edit7)
edit7:padding(20,20,20,20)