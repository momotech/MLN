local view = LinearLayout(LinearType.VERTICAL):frame(Rect(20, 30, 200, 200)):bgColor(Color(100, 50, 90, 1))
window:addView(view)

-- 橙色
local container1 = LinearLayout(LinearType.VERTICAL):bgColor(Color(200, 120, 120, 1)):width(100):height(68)
container1:y(68):x(0)
view:addView(container1)

local container2 = LinearLayout(LinearType.VERTICAL):bgColor(Color(20, 20, 20, 1)):width(100):height(68)
container2:y(0):x(0)
view:addView(container2)


local timer = Timer()
timer:interval(5)

current = container2


timer:start(function (completed)

    local currentContainer = current
    local nextContainer = container2

    if currentContainer == container2 then
        nextContainer = container1
        print("szq current 是2 next 是1")
    else
        print("szq current 是1 next 是2")
    end


--[[    currentContainer:y(0)
    nextContainer:y(68)]]

    current = nextContainer


    if not dismissAnime then
        dismissAnime = Animation()
        dismissAnime:setInterpolator(InterpolatorType.AccelerateDecelerate):setDuration(2)
    end

    dismissAnime:setTranslateY(0,-68):start(currentContainer)

    if not showAnime then
        showAnime = Animation()
        showAnime:setInterpolator(InterpolatorType.AccelerateDecelerate):setDuration(2)
    end


    showAnime:setTranslateY(0,-68):start(nextContainer)

    container1:superView():bgColor(Color(255, 255, 20, 40))

end)