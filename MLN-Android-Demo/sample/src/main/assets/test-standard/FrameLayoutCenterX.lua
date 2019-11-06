linearlayout = View()

linearlayout:width(MeasurementType.WRAP_CONTENT):height(MeasurementType.WRAP_CONTENT)
linearlayout:marginTop(200)
linearlayout:marginLeft(3)
linearlayout:bgColor(Color(200, 180, 250, 1))
linearlayout:alpha(0.5)
linearlayout:clipToBounds(true)


centerX = Label()
centerX:textColor(Color(0x73, 0x00, 0x00, 1)):fontSize(20):marginTop(20)
centerX:text('点击 获取 centerX 数值1')

centerX:onClick(function()
    centerX:text('centerX = ' .. tostring(centerX:centerX()) .. '   centerY = ' .. tostring(centerX:centerY()))
end)


centerX2 = Label()
centerX2:marginTop(50)
centerX2:textColor(Color(0x73, 0x00, 0x00, 1)):fontSize(20)
centerX2:text('点击 获取 centerX 数值2')

centerX2:onClick(function()
    centerX2:text('centerX = ' .. tostring(centerX2:centerX()) .. '   centerY = ' .. tostring(centerX2:centerY()))
end)




centerX3 = Label()
centerX3:marginTop(100)
centerX3:textColor(Color(0x73, 0x00, 0x00, 1)):fontSize(20)
centerX3:text('点击 获取 centerX 数值3')

centerX3:onClick(function()
    centerX3:text('centerX = ' .. tostring(centerX3:centerX()) .. '   centerY = ' .. tostring(centerX3:centerY()))
end)


linearlayout:addView(centerX)
linearlayout:addView(centerX2)
linearlayout:addView(centerX3)


window:addView(linearlayout)

