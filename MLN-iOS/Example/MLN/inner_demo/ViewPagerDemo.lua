---数据
dataSource = { "http://s.momocdn.com/w/u/others/2019/01/16/1547610372024-01.png",
               "http://s.momocdn.com/w/u/others/2019/01/16/1547610372064-02.png",
               "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-3.png",
               "http://s.momocdn.com/w/u/others/2019/01/16/1547610372137-4.png",
               "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-5.png" }

local titles = Array()
titles:add("标题1")
titles:add("标题二")
titles:add("标题三")
titles:add("标题四")
titles:add("标题五")

tabSegment = TabSegmentView(Rect(0, 80, window:width() - 100, 50), titles)
tabSegment:bgColor(Color(0, 255, 1, 1.0))
tabSegment:setAlignment(TabSegmentAlignment.RIGHT)
tabSegment:cornerRadius(50)--:clipToBounds(true)
tabSegment:selectedColor(Color(255, 0, 0, 1))
tabSegment:tintColor(Color(0, 120, 120, 1))
window:addView(tabSegment)

adapter = ViewPagerAdapter()
adapter:getCount(function(section)
    return #dataSource
end)

adapter:initCell(function(cell, row)
    local contentView = cell.contentView
    contentView:bgColor(Color(255, 255, 255, 1))
    cell.imageView = ImageView()
    cell.imageView:width(width):height(height)
    contentView:addView(cell.imageView)
end)
adapter:fillCellData(function(cell, row)
    local contentView = cell.contentView
    local width = contentView:width()
    local height = contentView:height()
    cell.imageView:width(width):height(height)
    local item = dataSource[row]
    cell.imageView:image(item)
end)

viewPager = ViewPager()
window:addView(viewPager)
width = window:width()
height = window:height()
viewPager:marginTop(130):width(window:width() - 100):height(window:height() - 130)

--viewPager:autoScroll(false)
viewPager:showIndicator(true)

viewPager:adapter(adapter)

tabSegment:relatedToViewPager(viewPager, true)
window:addView(viewPager)
