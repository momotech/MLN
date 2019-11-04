
baseView2 = View():width(200):height(100):marginLeft(10):marginTop(200):bgColor(Color(100, 20, 69, 1))
window:addView(baseView2)

view1 = View():marginLeft(5):marginRight(5):marginTop(5):marginBottom(5):width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
view1:bgColor(Color(100, 130, 90, 1))
view1:setGradientColor(Color(150, 130, 90, 1), Color(98, 230, 20, 1), false)
baseView2:addView(view1)

view1:anchorPoint(0, 0)
count = 0
baseView2:onClick(function()
    count = count + 1
    -- count变为6时更改anchorPoint
    if count == 6 then
        view1:anchorPoint(1, 1)
    end
    view1:transform(15, true)
end)