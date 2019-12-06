
linear = LinearLayout():bgColor(Color(121,22,111,1.0))
:width(150)
:height(MeasurementType.WRAP_CONTENT)
:setGravity(Gravity.CENTER)

window:addView(linear)

label1 = Label()
label1:text("标签一")

label2 = Label()
label2:bgColor(Color(0,255,255,1.0))
label2:text("点击屏幕我会被gone")
label2:priority(1)

label3 = Label()
label3:text("标签一")

linear:addView(label1)
:addView(label2)
:addView(label3)

window:onClick(function()
label2:gone(label2:gone() ~= true)
end)


