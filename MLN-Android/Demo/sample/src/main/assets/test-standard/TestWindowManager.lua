label = Label()
label:width(100)
label:height(100)

label:marginTop(150)

label:text('labelllllllll')




label2 = Label()
label2:width(100)
label2:height(100)

label2:marginTop(50)

label2:text('666666')




--[[wm = WindowManager(Rect(100, 50, 200, 200))
-- wm = WindowManager()
wm:cancelable(true)

wm:setContentView(label)

wm:contentWindowDisAppear(function()

    print('contentWindowDisAppear ----')
end)]]




window:setStatusBarStyle(StatusBarStyle.Default)


contentV = ContentWindow(Rect(0,0,300,500))
--contentV = ContentWindow()

-- contentV:width(MeasurementType.MATCH_PARENT)
-- contentV:height(MeasurementType.MATCH_PARENT)




contentV:bgColor(Color(121,244,11,1.0))


contentV:x(50)
contentV:y(100)


contentV:cancelable(true)
contentV:alpha(0.3)

view = View():marginTop(150):width(300):height(200)
view:bgColor(Color(124,45,244,1.0))

contentV:addView(view)
contentV:addView(label)


window:onClick(function()
    --contentV:windowLevel(0)
    contentV:show()
    contentV:addView(label2)
end)

view:onClick(function()

    contentV:dismiss()

end)



label5 = Label()
label5:width(200)
label5:height(300)

label5:marginTop(250)

label5:text('999933434f3f3f3f3ff3f3fg3ff3f3f3f3f33fdfdfdfdfdfdf')

label5:onClick(function()
    contentV:removeAllSubviews()
end)
window:addView(label5)