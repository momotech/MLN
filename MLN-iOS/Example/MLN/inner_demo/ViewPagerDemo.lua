---数据
dataSource = { "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=619938825,3320299346&fm=26&gp=0.jpg",
               "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3388258119,3115603131&fm=26&gp=0.jpg",
               "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1062551846,664581458&fm=26&gp=0.jpg",
               "http://img4.imgtn.bdimg.com/it/u=2853553659,1775735885&fm=26&gp=0.jpg",
               "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2387449900,2074518915&fm=11&gp=0.jpg" }

local titles = Array()
titles:add("标题1")
titles:add("标题二")
titles:add("标题三")
titles:add("标题四")
titles:add("标题五")
local topHeight = 0
if System:iOS() then
    topHeight = window:statusBarHeight() + window:navBarHeight()
end
tabSegment = TabSegmentView(Rect(0, topHeight, window:width(), 50), titles)
tabSegment:bgColor(Color(120, 120, 120, 0.3))
tabSegment:setAlignment(TabSegmentAlignment.RIGHT)
tabSegment:selectedColor(Color(255, 0, 0, 1))
tabSegment:tintColor(Color(0, 120, 120, 1))
window:addView(tabSegment)

adapter = ViewPagerAdapter()
adapter:getCount(function(section)
    return #dataSource
end)

adapter:initCell(function(cell, row)
    cell.contentView:bgColor(Color(255, 255, 255, 1))
    cell.imageView = ImageView():width(MeasurementType.MATCH_PARENT):height(300)
    cell.imageView:contentMode(ContentMode.SCALE_TO_FILL)
    cell.contentView:addView(cell.imageView)
end)
adapter:fillCellData(function(cell, row)
    local item = dataSource[row]
    cell.imageView:image(item)
end)

viewPager = ViewPager():width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT):marginTop(topHeight + 60)
viewPager:showIndicator(true)

viewPager:adapter(adapter)

tabSegment:relatedToViewPager(viewPager, true)
window:addView(viewPager)
