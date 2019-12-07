
button =  ImageButton():marginTop(120):width(212.5):height(200):setGravity(Gravity.CENTER_HORIZONTAL)
button:onClick(function()
print('点我干嘛')
end)
button:bgColor(Color(123,123,5,1))
window:addView(button)

button:setImage("https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg","http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg")
button:cornerRadius(15)
button:clipToBounds(true)

label = Label():marginTop(330):width(300):height(30):setGravity(Gravity.CENTER_HORIZONTAL):bgColor(Color(121,45,12,1.0))
label:text("点击我给ImageButton设置padding")

label:onClick(function()
button:padding(20,30,40,50)
end)

window:addView(label)

