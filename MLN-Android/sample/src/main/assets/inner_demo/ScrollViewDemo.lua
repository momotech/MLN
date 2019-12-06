
local scrollview = ScrollView(true)
scrollview:bgColor(Color(173, 216, 230, 1))
scrollview:x(20):y(100)
scrollview:width(window:width() - 40)
scrollview:height(window:height() - 150)
scrollview:contentSize(Size(900, 400))
window:addView(scrollview)

for i = 1, 10 do
local label = Label():bgColor(Color(30, 144, 255, 1))
label:textColor(Color(255, 255, 255, 1))
label:text(string.format("%d", i))
label:x(i * 42):y(0):width(40):height(40)
scrollview:addView(label)
end


scrollview:setScrollBeginCallback(function()
print('begin scroll')
end)
scrollview:setScrollingCallback(function(x, y)
print('scrolling', x, y)
end)
scrollview:setScrollEndCallback(function()
print('end scroll')
end)
scrollview:setEndDraggingCallback(function (x, y)
print('end dragging', x, y)
end)
scrollview:setStartDeceleratingCallback(function (x, y)
print('dece', x, y)
end)

scrollview:scrollEnabled(true)


System:setTimeOut(function()
scrollview:contentOffset(Point(40, 0))
end, 3)
