

baseView = View()
baseView:marginTop(80):padding(5,5,5,5)
baseView:bgColor(Color(14,23,212,1))
window:addView(baseView)

view = View()
view:width(100):height(100)
view:bgColor(Color(212,14,23,1))
view:onClick(function()
    local nu = 1
    local ani = Animator()
    ani:setDuration(1)
    ani:setRepeat(RepeatType.REVERSE,3)
    ani:setOnAnimationUpdateCallback(function(percentage)
        view:height(100 + 20 * (percentage)):width(100 + 20 * (percentage))
    end)
    ani:setStopCallback(function()
        view:height(100):width(100)
    end)
    ani:start()
end)
baseView:addView(view)


rotateView = View()
rotateView:marginTop(220):width(100):height(100)
rotateView:bgColor(Color(14,212,23,1))
window:addView(rotateView)


ani = Animator()
ani:setDuration(10)
ani:setRepeat(RepeatType.REVERSE, -2)
ani:setOnAnimationUpdateCallback(function(percentage)
    baseView:marginLeft((window:width() -110) * percentage)
    rotateView:rotation(360 * percentage)
end)


window:onClick(function()
    ani:start()
end)

