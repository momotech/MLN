imgView = ImageView():marginTop(120):width(350):height(350):marginLeft(20)
label = Label():marginTop(100):textColor(Color(121,45,121,1.0))
imgView:blurImage(10)
imgView:setImageUrl("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1553512788429&di=01209ac590dc682aa41ce478b321378a&imgtype=0&src=http%3A%2F%2Fpic29.nipic.com%2F20130601%2F12122227_123051482000_2.jpg")
window:addView(imgView)
window:addView(label)
count = 0
label:text("点击增加value:" .. count )
window:onClick(function()
 count = count + 1
 imgView:blurImage(count)
 label:text("点击增加value:" .. count )
end)

reload = Label():marginTop(100):marginLeft(200):bgColor(Color(121,45,121,1.0)):text('reload')
reload:onClick(function ()
 count = 0;
 imgView:blurImage(count)
 label:text("点击增加value:" .. count )
end)
window:addView(reload)