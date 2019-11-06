--local scrollview = ScrollView(false,true)

--local scrollview = ScrollView(ScrollDirection.VERTICAL)

--local scrollview = ScrollView(true,true)

-- local scrollview = ScrollView(true,false)
-- local scrollview = ScrollView(false,false)

-- local scrollview = ScrollView(true)
 local scrollview = ScrollView(false,true)

--local scrollview = ScrollView()

scrollview:width(300)
scrollview:height(400)
 --scrollview:contentSize(Size(200, 300))

scrollview:setScrollBeginCallback(function()
    print('begin scroll')
end)

scrollview:setScrollingCallback(function(x, y)
    print('scrolling', x, y)
end)

scrollview:setScrollEndCallback(function()
    print('end scroll')
end)

scrollview:setEndDraggingCallback(function(x, y)
    print('end dragging', x, y)
end)

scrollview:setStartDeceleratingCallback(function(x, y)
    print('dece', x, y)
end)

scrollview:scrollEnabled(true)

System:setTimeOut(function()
    scrollview:contentOffset(Point(100, 0))
end, 1)

local w = 100
local h = 200
local iv1 = ImageView()
iv1:width(w)
iv1:height(h)
iv1:image('http://pic24.photophoto.cn/20120730/0036036815619480_b.jpg')
local iv2 = ImageView()
iv2:width(w)
iv2:height(h)
iv2:image('http://pic24.photophoto.cn/20120730/0036036815619480_b.jpg')

local iv3 = ImageView()
iv3:width(w)
iv3:height(h)
iv3:image('http://pic24.photophoto.cn/20120730/0036036815619480_b.jpg')


local iv4 = ImageView()
iv4:width(w)
iv4:height(h)
iv4:image('http://pic24.photophoto.cn/20120730/0036036815619480_b.jpg')


local iv5 = ImageView()
iv5:width(w)
iv5:height(h)
iv5:image('http://pic24.photophoto.cn/20120730/0036036815619480_b.jpg')




iv1:cornerRadius(8)
iv2:cornerRadius(8)
iv3:cornerRadius(8)



scrollview:addView(iv1)
scrollview:addView(iv2)
scrollview:addView(iv3)
scrollview:addView(iv4)
scrollview:addView(iv5)


window:addView(scrollview)


canScrolls= true

window:onClick(function()

    scrollview:showsVerticalScrollIndicator(canScrolls)

    if canScrolls then
        canScrolls = false
    else
        canScrolls = true
    end

end)


