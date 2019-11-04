window:setStatusBarStyle(StatusBarStyle.Default)



contentV = nil

window:onClick(function()
    --contentV:windowLevel(0)
    contentV:marginTop(50)
    contentV:marginLeft(50)
    contentV:show()
    -- contentV:addView(label2)

end)



window:viewAppear(function()
    contentV = ContentWindow()

    contentV:bgColor(Color(121, 244, 11, 1.0))

    view = View():width(300):height(300):setGravity(Gravity.CENTER)
    --:setPositionAdjustForKeyboard(true)
    view:bgColor(Color(124, 45, 244, 1.0))

    editView = EditTextView():marginTop(20):width(300):height(50):placeholder("我是默认文本"):bgColor(Color(21, 1, 145, 1.0))
    view:addView(editView)

    view:onClick(function()

        contentV:dismiss()

    end)

    contentV:canEndEditing(true)

    contentV:setContent(view)

end)
