-- 示例：TransX
local baseView = Label():text("TransX"):textColor(Color(0,0,0,1))
baseView:y(100):x(0):width(50):height(50)
baseView:bgColor(Color(0, 225, 225, 1))
baseView:fontSize(15)
window:addView(baseView)
isAnimating = false
animation = Animation()

animation:setStartCallback(function()
    print("|| Animation start!")
end)

animation:setEndCallback(function()
    print("|| Animation end!")
end)

baseView:onClick(function()
    animation:setTranslateX(30, 100)
    animation:setTranslateY(30, 100)
    animation:setRotate(45, 45)
    animation:setDuration(1)

     --animation:setRepeat(RepeatType.REVERSE,-2)
     --animation:setRepeat(RepeatType.NONE,0)

    animation:setRepeat(RepeatType.FROM_START, 0)

    -- animation:setAutoBack(true)

    -- animation:setInterpolator(InterpolatorType.AccelerateDecelerate)
    animation:start(baseView)
    isAnimating = true
end)

-- 示例：TransY
local baseView2 = Label():text("TransY"):textColor(Color(0,0,0,1))
--baseView2:y(180):x(100):width(MeasurementType.WRAP_CONTENT):height(50)
baseView2:y(180):x(100):width(50):height(50)
baseView2:bgColor(Color(0, 225, 225, 1))
baseView2:fontSize(15)

 baseView2:anchorPoint(1,1)

window:addView(baseView2)
isAnimating = false
animation2 = Animation()

animation2:setStartCallback(function()
    print("|| Animation start!")
end)

animation2:setEndCallback(function()
    print("|| Animation end!")
end)

baseView2:onClick(function()
    --animation2:setTranslateY(0, 100)
    animation2:setRotate(0, 180)
    animation2:setDuration(3)
    animation2:setRepeat(RepeatType.REVERSE, 2)
    animation2:start(baseView2)
    isAnimating = true


end)