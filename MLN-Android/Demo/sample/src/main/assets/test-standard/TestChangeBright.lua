
screen_w = window:width()
screen_h = window:height()

local lineEdit = EditTextView():placeholder("输入亮度值 1 - 255 "):width(screen_w/2):fontSize(16):textAlign(TextAlign.CENTER):padding(5, 5, 5, 5)
lineEdit:x(100):y(100):bgColor(Color(211, 211, 211, 1)):textColor(Color(0, 0, 0, 1)):inputMode(EditTextViewInputMode.Number)

local reload = Label():text("开始改变亮度"):fontSize(16):textAlign(TextAlign.CENTER):setAutoFit(true):padding(5, 5, 5, 5)
reload:x(100):y(220):bgColor(Color(21, 21, 21, 1)):textColor(Color(255, 255, 255, 1))

local brights = Label():text("当前亮度值 = "..tostring(System:getBright())):fontSize(16):textAlign(TextAlign.CENTER):setAutoFit(true):padding(5, 5, 5, 5)
reload:x(160):y(260):bgColor(Color(21, 21, 21, 1)):textColor(Color(255, 255, 255, 1))



window:addView(lineEdit)
window:addView(reload)
window:addView(brights)

reload:onClick(function()

    local bright= System:getBright()

    print("bright =   "..tostring(bright))

    if string.len(lineEdit:text()) == 0 then
        Toast("请输入数值", 1)
    else
       System:changeBright( tonumber(lineEdit:text()))

       brights:text("当前亮度值 = "..tostring(System:getBright()))
    end

end)
