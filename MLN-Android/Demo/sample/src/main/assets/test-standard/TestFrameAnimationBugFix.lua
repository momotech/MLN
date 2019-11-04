-- 使用FrameAnimation， EndCallback里如果再调用Animation:start造成安卓扫码卡死.

--复现代码


testView = View()
testView:frame(Rect(140, 140, 100, 100)):bgColor(Color(200, 120, 120, 1))

initYPosition = testView:y()
finalYPosition = 500

window:addView(testView)

outAnimation = FrameAnimation()
outAnimation:setDuration(3):setTranslateY(initYPosition, finalYPosition)

outAnimation:start(testView)

outAnimation:setEndCallback(function(finished)

    print("outAnimation end   "..tostring(finished))

    -- TimeManager:setTimeOut(function()

       -- print("TimeManager 开始执行")

        innerAnimation = FrameAnimation()
        innerAnimation:setDuration(3)
        innerAnimation:setTranslateY(finalYPosition,initYPosition)

        innerAnimation:start(testView)  --关键是这，EndCallback里如果再调用Animation:start

--    end, 3)


end)