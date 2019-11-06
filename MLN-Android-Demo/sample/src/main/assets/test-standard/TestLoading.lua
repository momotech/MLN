-- 使用FrameAnimation， EndCallback里如果再调用Animation:start造成安卓扫码卡死.

--复现代码


testView = View()
testView:frame(Rect(140.56, 140.2345, 100.565, 100.00))

initYPosition = testView:y()
finalYPosition = 500

testView:setGradientColorWithDirection(Color(200, 120, 120, 1), Color(200, 180, 250, 1), GradientType.LEFT_TO_RIGHT)

window:addView(testView)

outAnimation = FrameAnimation()
outAnimation:setDuration(3):setTranslateY(initYPosition, finalYPosition)

outAnimation:start(testView)

outAnimation:repeatCount(0)

outAnimation:setEndCallback(function(finished)

    print("outAnimation end   " .. tostring(finished))

--[[    Loading:cancel(true)  -- 模式为false 不可取消
    Loading:show()

    Loading:setOnCancelCallBack(function()

        print("dialog 消失啦")
    end)

    TimeManager:setTimeOut(function()
        print("TimeManager 开始执行")

        Loading:hide()

    end, 10)]]

end)

showOrNot = true
testView:onClick(function()
    if showOrNot then
        Loading:show()
        showOrNot = false

    else
        Loading:hide()
        showOrNot = true
    end
end)

Application:setBackground2ForegroundCallback(
        function()

            Toast(" Background   2   Foreground   Callback  ",1)


        end

)

Application:setForeground2BackgroundCallback(
        function()

            Toast("  Foreground  2 Background  ",1)


        end

)