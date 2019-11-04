
local startTime
local endTime
local baseView3 = Label():text("ScaleX"):textColor(Color(0,0,0,1))
baseView3:y(260):x(50):width(80):height(50)
baseView3:bgColor(Color(0, 225, 225, 1))


window:addView(baseView3)


animation3 = Animation()


animation3:setStartCallback(function()
    print("|| Animation start! - time")
end)


animation3:setEndCallback(function()
    print("|| Animation end! - time")
end)



baseView3:onClick(function()

    animation3:setScaleX(0.5, 1.2)

    animation3:setScaleY(0.5, 1.2)

    animation3:setTranslateX(0, 100)
    animation3:setTranslateY(0, 100)
    animation3:setAlpha(1.0, 0.1)
    animation3:setDuration(3)

    -- animation3:setDelay(3)

    animation3:setAutoBack(true)

    -- animation3:setRepeat(RepeatType.REVERSE, 2)

    animation3:start(baseView3)


end)