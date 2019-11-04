

-- 主工程中有  MixLabel (水滴表情Label,链接) 富文本

local editG = EditTextView():textColor(Color(0, 0, 0, 1)):y(120):x(150):height(60):width(300):bgColor(Color(123, 123, 123, 1))
editG:fontSize(16):placeholder("green")


window:addView(editG)




mixlabel = MixLabel()
mixlabel:marginTop(200)


label3 = Label():marginTop(170)
label3:bgColor(Color(230, 230, 230, 1))
label3:text("点击下方的 绿色view")

label3:onClick(function ()
    mixlabel:text('dfdf3334435dsfdf')
end)







window:addView(mixlabel)
window:addView(label3)


editG:setEndChangedCallback(function()
    print("textView:", editG:text())
    mixlabel:text( editG:text())
end)

