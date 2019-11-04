label3 = Label():marginTop(170)
label3:bgColor(Color(230, 230, 230, 1))
label3:text("点击下方的 绿色view")
window:addView(label3)

baseView3 = View():width(MeasurementType.WRAP_CONTENT):height(MeasurementType.WRAP_CONTENT):marginTop(300)
baseView3:bgColor(Color(130, 130, 130, 1))
window:addView(baseView3)

count = 0
view = View():marginTop(200):marginLeft(100):width(250):height(250)
view:bgColor(Color(131, 175, 155, 1))
view:openRipple(true) -- 点击时的波纹效果
window:addView(view)
view:onClick(function ()
    count = count + 1
    local str = string.format("click count = %d", count)
    label_click:text(str)
end)

--[[view:onTouch(function (x, y)
    local str = string.format("x = %d, y = %d", x, y)
    label_touch:text(str)
end)]]


view:touchBegin(function (x, y)
    local str = string.format("begin x = %d, y = %d", x, y)
    label_touch:text(str)
end)


view:touchMove(function (x, y)
    local str = string.format("move x = %d, y = %d", x, y)
    label_touch:text(str)
end)


view:touchEnd(function (x, y)
    local str = string.format("end x = %d, y = %d", x, y)
    label_touch:text(str)
end)


view:touchCancel(function (x, y)
    local str = string.format("cancel x = %d, y = %d", x, y)
    label_touch:text(str)
end)




label_click = Label():marginTop(100):marginLeft(200)
label_click:fontSize(11)
label_click:bgColor(Color(230, 230, 230, 1))
window:addView(label_click)

label_touch = Label():marginTop(130):marginLeft(200)
label_touch:fontSize(11)
label_touch:bgColor(Color(230, 230, 230, 1))
window:addView(label_touch)