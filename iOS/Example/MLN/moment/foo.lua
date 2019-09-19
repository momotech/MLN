
print(window)

window:bgColor(Color(255,0,0))
view = View():bgColor(Color(123, 233, 233, 1))
view:marginLeft(0):marginTop(10):width(300):height(300)
window:addView(view)

window:onClick(function()
    --Navigator:closeSelf(0)
    view:removeFromSuper()
    --window:addView(view)
    view = View():bgColor(Color(123, 233, 233, 1))
    view:marginLeft(0):marginTop(10):width(300):height(300)
    window:addView(view)
end)

view:onClick(function()
animation = Animation()
animation:setTranslateX(0, 100)
animation:setDuration(3)
animation:setInterpolator(InterpolatorType.Bounce)
animation:start(view)
end)

view:touchMove(function(x, y)
print("touch move ---- "..x..", "..y)
end)

view:touchEnd(function(x, y)
print("touch end ---- "..x..", "..y)
end)


view:touchCancel(function(x, y)
print("touch cancel ---- "..x..", "..y)
end)

--[[
window:touchBegin(function(x, y)
print("window: touch begin ---- "..x..", "..y)
end)


window:touchMove(function(x, y)
print("window: touch move ---- "..x..", "..y)
end)


window:touchEnd(function(x, y)
print("window: touch end ---- "..x..", "..y)
end)


window:touchCancel(function(x, y)
print("window: touch cancel ---- "..x..", "..y)
end)
--]]

view:touchBeginExtension(function(dict)
print("touch began extension---- ", dict)
end)

view:touchMoveExtension(function(dict)
print("touch move extension---- ", dict)
end)

view:touchEndExtension(function(dict)
print("touch end extension---- ", dict)
end)


view:touchCancelExtension(function(dict)
print("touch cancel extension---- ", dict)
end)



